import 'dart:async';
import '../models/ride_model.dart';
import '../models/ride_request_model.dart';
import '../repositories/ride_repository.dart';

/// Service class containing business logic for ride operations
class RideService {
  final RideRepository _rideRepository;
  
  RideService({RideRepository? rideRepository}) 
      : _rideRepository = rideRepository ?? RideRepository();

  // === RIDE OPERATIONS ===

  /// Create a new ride offer with validation
  Future<Result<Ride>> createRide(CreateRideRequest request) async {
    try {
      // Validate ride request
      final validationResult = _validateCreateRideRequest(request);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.error!);
      }

      // Create the ride
      final ride = await _rideRepository.createRide(request);
      
      return Result.success(ride);
    } catch (e) {
      return Result.failure('Failed to create ride: ${e.toString()}');
    }
  }

  /// Get available rides with filters
  Stream<List<Ride>> getAvailableRides({
    String? fromLocation,
    String? toLocation,
    DateTime? fromDate,
    DateTime? toDate,
    double? maxPrice,
    int? minSeats,
  }) {
    return _rideRepository.getAvailableRides(
      fromLocation: fromLocation,
      toLocation: toLocation,
      fromDate: fromDate,
      toDate: toDate,
      maxPrice: maxPrice,
      minSeats: minSeats,
    );
  }

  /// Get a specific ride by ID
  Future<Result<Ride?>> getRideById(String rideId) async {
    try {
      if (rideId.isEmpty) {
        return Result.failure('Ride ID cannot be empty');
      }

      final ride = await _rideRepository.getRideById(rideId);
      return Result.success(ride);
    } catch (e) {
      return Result.failure('Failed to get ride: ${e.toString()}');
    }
  }

  /// Get rides created by a specific driver
  Stream<List<Ride>> getRidesByDriver(String driverId) {
    return _rideRepository.getRidesByDriver(driverId);
  }

  /// Get rides where user is a confirmed passenger
  Stream<List<Ride>> getRidesAsPassenger(String passengerId) {
    return _rideRepository.getRidesAsPassenger(passengerId);
  }

  /// Search rides by location text
  Future<Result<List<Ride>>> searchRides(String searchQuery) async {
    try {
      if (searchQuery.trim().isEmpty) {
        return Result.failure('Search query cannot be empty');
      }

      if (searchQuery.trim().length < 2) {
        return Result.failure('Search query must be at least 2 characters');
      }

      final rides = await _rideRepository.searchRides(searchQuery.trim());
      return Result.success(rides);
    } catch (e) {
      return Result.failure('Failed to search rides: ${e.toString()}');
    }
  }

  /// Cancel a ride (only by driver)
  Future<Result<void>> cancelRide(String rideId, String userId) async {
    try {
      // Get the ride first to validate ownership
      final rideResult = await getRideById(rideId);
      if (rideResult.isFailure) {
        return Result.failure(rideResult.error!);
      }

      final ride = rideResult.data;
      if (ride == null) {
        return Result.failure('Ride not found');
      }

      // Check if user is the driver
      if (ride.driverId != userId) {
        return Result.failure('Only the driver can cancel this ride');
      }

      // Check if ride can be cancelled (not in the past)
      if (ride.schedule.departureTime.isBefore(DateTime.now())) {
        return Result.failure('Cannot cancel a ride that has already started');
      }

      // Update ride status to cancelled
      await _rideRepository.updateRideStatus(rideId, RideStatus.cancelled);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to cancel ride: ${e.toString()}');
    }
  }

  /// Complete a ride (mark as completed)
  Future<Result<void>> completeRide(String rideId, String userId) async {
    try {
      final rideResult = await getRideById(rideId);
      if (rideResult.isFailure) {
        return Result.failure(rideResult.error!);
      }

      final ride = rideResult.data;
      if (ride == null) {
        return Result.failure('Ride not found');
      }

      if (ride.driverId != userId) {
        return Result.failure('Only the driver can complete this ride');
      }

      await _rideRepository.updateRideStatus(rideId, RideStatus.completed);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to complete ride: ${e.toString()}');
    }
  }

  // === RIDE REQUEST OPERATIONS ===

  /// Create a ride request with validation
  Future<Result<RideRequest>> requestRide(CreateRideRequestData requestData) async {
    try {
      // Validate the request
      final validationResult = _validateRideRequest(requestData);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.error!);
      }

      // Check if ride exists and is available
      final rideResult = await getRideById(requestData.rideId);
      if (rideResult.isFailure) {
        return Result.failure(rideResult.error!);
      }

      final ride = rideResult.data;
      if (ride == null) {
        return Result.failure('Ride not found');
      }

      if (!ride.isAvailable) {
        return Result.failure('This ride is no longer available');
      }

      // Check if user is trying to request their own ride
      if (ride.driverId == requestData.passengerId) {
        return Result.failure('You cannot request your own ride');
      }

      // Check if user already has a pending request for this ride
      final hasExisting = await _rideRepository.hasExistingRequest(
        requestData.rideId, 
        requestData.passengerId
      );
      
      if (hasExisting) {
        return Result.failure('You already have a pending request for this ride');
      }

      // Check if user is already confirmed for this ride
      if (ride.isUserConfirmed(requestData.passengerId)) {
        return Result.failure('You are already confirmed for this ride');
      }

      // Create the request
      final rideRequest = await _rideRepository.createRideRequest(requestData);
      
      return Result.success(rideRequest);
    } catch (e) {
      return Result.failure('Failed to request ride: ${e.toString()}');
    }
  }

  /// Get ride requests for a specific ride (for drivers)
  Stream<List<RideRequest>> getRideRequestsForRide(String rideId) {
    return _rideRepository.getRideRequestsForRide(rideId);
  }

  /// Get ride requests made by a specific passenger
  Stream<List<RideRequest>> getRideRequestsByPassenger(String passengerId) {
    return _rideRepository.getRideRequestsByPassenger(passengerId);
  }

  /// Accept a ride request
  Future<Result<void>> acceptRideRequest(String requestId, String driverId) async {
    try {
      // Get the request
      final request = await _rideRepository.getRideRequestById(requestId);
      if (request == null) {
        return Result.failure('Request not found');
      }

      // Get the ride to validate driver
      final rideResult = await getRideById(request.rideId);
      if (rideResult.isFailure) {
        return Result.failure(rideResult.error!);
      }

      final ride = rideResult.data;
      if (ride == null) {
        return Result.failure('Ride not found');
      }

      // Check if user is the driver
      if (ride.driverId != driverId) {
        return Result.failure('Only the driver can accept this request');
      }

      // Check if ride still has available seats
      if (!ride.capacity.hasAvailableSeats) {
        return Result.failure('This ride is already full');
      }

      // Check if request is still pending
      if (!request.isPending) {
        return Result.failure('This request has already been responded to');
      }

      // Accept the request (this will update both request and ride)
      await _rideRepository.acceptRideRequest(requestId, request.rideId);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to accept request: ${e.toString()}');
    }
  }

  /// Reject a ride request
  Future<Result<void>> rejectRideRequest(
    String requestId, 
    String driverId, 
    [String? reason]
  ) async {
    try {
      // Get the request to validate
      final request = await _rideRepository.getRideRequestById(requestId);
      if (request == null) {
        return Result.failure('Request not found');
      }

      // Get the ride to validate driver
      final rideResult = await getRideById(request.rideId);
      if (rideResult.isFailure) {
        return Result.failure(rideResult.error!);
      }

      final ride = rideResult.data;
      if (ride == null) {
        return Result.failure('Ride not found');
      }

      if (ride.driverId != driverId) {
        return Result.failure('Only the driver can reject this request');
      }

      if (!request.isPending) {
        return Result.failure('This request has already been responded to');
      }

      await _rideRepository.updateRideRequestStatus(
        requestId, 
        RideRequestStatus.rejected,
        reason
      );
      
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to reject request: ${e.toString()}');
    }
  }

  /// Cancel a ride request (by passenger)
  Future<Result<void>> cancelRideRequest(String requestId, String passengerId) async {
    try {
      final request = await _rideRepository.getRideRequestById(requestId);
      if (request == null) {
        return Result.failure('Request not found');
      }

      if (request.passengerId != passengerId) {
        return Result.failure('You can only cancel your own requests');
      }

      if (!request.isPending) {
        return Result.failure('Only pending requests can be cancelled');
      }

      await _rideRepository.cancelRideRequest(requestId);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to cancel request: ${e.toString()}');
    }
  }

  /// Remove a passenger from a confirmed ride
  Future<Result<void>> removePassengerFromRide(
    String rideId, 
    String passengerId, 
    String requesterId
  ) async {
    try {
      final rideResult = await getRideById(rideId);
      if (rideResult.isFailure) {
        return Result.failure(rideResult.error!);
      }

      final ride = rideResult.data;
      if (ride == null) {
        return Result.failure('Ride not found');
      }

      // Check if requester is either the driver or the passenger being removed
      if (ride.driverId != requesterId && passengerId != requesterId) {
        return Result.failure('You can only remove yourself or passengers from your own rides');
      }

      // Check if passenger is actually confirmed for this ride
      if (!ride.isUserConfirmed(passengerId)) {
        return Result.failure('This passenger is not confirmed for this ride');
      }

      await _rideRepository.removePassengerFromRide(rideId, passengerId);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to remove passenger: ${e.toString()}');
    }
  }

  /// Get pending requests count for a driver
  Future<Result<int>> getPendingRequestsCount(String driverId) async {
    try {
      final count = await _rideRepository.getPendingRequestsCount(driverId);
      return Result.success(count);
    } catch (e) {
      return Result.failure('Failed to get pending requests count: ${e.toString()}');
    }
  }

  // === VALIDATION METHODS ===

  /// Validate create ride request
  Result<void> _validateCreateRideRequest(CreateRideRequest request) {
    // Validate driver info
    if (request.driverId.isEmpty) {
      return Result.failure('Driver ID is required');
    }

    if (request.driverName.trim().isEmpty) {
      return Result.failure('Driver name is required');
    }

    if (request.driverRating < 0 || request.driverRating > 5) {
      return Result.failure('Driver rating must be between 0 and 5');
    }

    // Validate locations
    if (request.origin.address.trim().isEmpty) {
      return Result.failure('Origin address is required');
    }

    if (request.destination.address.trim().isEmpty) {
      return Result.failure('Destination address is required');
    }

    if (request.origin.address.trim() == request.destination.address.trim()) {
      return Result.failure('Origin and destination cannot be the same');
    }

    // Validate timing
    if (request.departureTime.isBefore(DateTime.now())) {
      return Result.failure('Departure time cannot be in the past');
    }

    if (request.estimatedDuration <= 0) {
      return Result.failure('Estimated duration must be greater than 0');
    }

    if (request.estimatedDuration > 720) { // 12 hours max
      return Result.failure('Estimated duration cannot exceed 12 hours');
    }

    // Validate pricing
    if (request.pricePerSeat <= 0) {
      return Result.failure('Price per seat must be greater than 0');
    }

    if (request.pricePerSeat > 500) { // R500 max per seat
      return Result.failure('Price per seat cannot exceed R500');
    }

    // Validate capacity
    if (request.totalSeats < 1 || request.totalSeats > 4) {
      return Result.failure('Total seats must be between 1 and 4');
    }

    return Result.success(null);
  }

  /// Validate ride request
  Result<void> _validateRideRequest(CreateRideRequestData requestData) {
    if (requestData.rideId.isEmpty) {
      return Result.failure('Ride ID is required');
    }

    if (requestData.passengerId.isEmpty) {
      return Result.failure('Passenger ID is required');
    }

    if (requestData.passengerName.trim().isEmpty) {
      return Result.failure('Passenger name is required');
    }

    if (requestData.message != null && requestData.message!.length > 200) {
      return Result.failure('Message cannot exceed 200 characters');
    }

    return Result.success(null);
  }
}

/// Result wrapper for service operations
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._(this.data, this.error, this.isSuccess);

  factory Result.success(T data) => Result._(data, null, true);
  factory Result.failure(String error) => Result._(null, error, false);

  bool get isFailure => !isSuccess;
}