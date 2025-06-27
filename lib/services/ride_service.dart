import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/ride_model.dart';
import '../models/ride_request_model.dart';
import '../models/user_model.dart';
import '../repositories/ride_repository.dart';
import '../repositories/ride_request_repository.dart';
import '../constants/app_constants.dart';

/// Service for managing ride business logic
class RideService {
  final RideRepository _rideRepository = RideRepository();
  final RideRequestRepository _requestRepository = RideRequestRepository();

  /// Create a new ride offer
  /// 
  /// Validates ride data and creates a new ride in the database.
  /// Throws an exception if validation fails or user cannot offer rides.
  Future<Ride> createRide({
    required Location origin,
    required Location destination,
    required DateTime departureTime,
    required int estimatedDurationMinutes,
    required double pricePerSeat,
    required int availableSeats,
    required User currentUser,
    String? notes,
  }) async {
    try {
      // Validate user can offer rides
      if (!currentUser.canOfferRides) {
        throw Exception('You must be a verified student with good ratings to offer rides');
      }

      // Validate ride data
      _validateRideData(
        origin: origin,
        destination: destination,
        departureTime: departureTime,
        pricePerSeat: pricePerSeat,
        availableSeats: availableSeats,
      );

      // Create ride object
      final ride = Ride(
        rideId: '', // Will be set by repository
        driverId: currentUser.id,
        driverInfo: DriverInfo(
          id: currentUser.id,
          name: currentUser.fullName,
          rating: currentUser.driverRating,
          isVerified: currentUser.isVerifiedStudent,
          profileImageUrl: currentUser.profileImageUrl,
        ),
        route: RideRoute(
          origin: origin,
          destination: destination,
        ),
        schedule: RideSchedule(
          departureTime: departureTime,
          estimatedDurationMinutes: estimatedDurationMinutes,
        ),
        pricing: RidePricing(
          pricePerSeat: pricePerSeat,
          currency: AppConstants.currency,
        ),
        capacity: RideCapacity(
          totalSeats: availableSeats,
          availableSeats: availableSeats,
        ),
        status: RideStatus.active,
        confirmedRiders: [],
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await _rideRepository.createRide(ride);
    } catch (e) {
      throw Exception('Failed to create ride: $e');
    }
  }

  /// Request to join a ride
  /// 
  /// Creates a ride request for a passenger to join a specific ride.
  /// Validates that the user can request rides and hasn't already requested this ride.
  Future<RideRequest> requestRide({
    required String rideId,
    required User currentUser,
    int seatsRequested = 1,
    String? message,
  }) async {
    try {
      // Validate user can request rides
      if (!currentUser.canRequestRides) {
        throw Exception('Your account is not eligible to request rides');
      }

      // Get the ride details
      final ride = await _rideRepository.getRideById(rideId);
      if (ride == null) {
        throw Exception('Ride not found');
      }

      // Validate ride is bookable
      if (!ride.isBookable) {
        throw Exception('This ride is no longer available for booking');
      }

      // Check if user is the driver
      if (ride.driverId == currentUser.id) {
        throw Exception('You cannot request your own ride');
      }

      // Check if user already requested this ride
      final alreadyRequested = await _requestRepository
          .hasPassengerRequestedRide(rideId, currentUser.id);
      if (alreadyRequested) {
        throw Exception('You have already requested this ride');
      }

      // Check if enough seats available
      if (ride.capacity.availableSeats < seatsRequested) {
        throw Exception('Not enough seats available');
      }

      // Create ride request
      final request = RideRequest(
        requestId: '', // Will be set by repository
        rideId: rideId,
        passengerId: currentUser.id,
        passengerInfo: PassengerInfo(
          id: currentUser.id,
          name: currentUser.fullName,
          rating: currentUser.passengerRating,
          isVerified: currentUser.isVerifiedStudent,
          profileImageUrl: currentUser.profileImageUrl,
        ),
        status: RideRequestStatus.pending,
        seatsRequested: seatsRequested,
        message: message,
        requestedAt: DateTime.now(),
      );

      return await _requestRepository.createRideRequest(request);
    } catch (e) {
      throw Exception('Failed to request ride: $e');
    }
  }

  /// Respond to a ride request (accept or reject)
  /// 
  /// Allows a driver to accept or reject a passenger's request to join their ride.
  Future<void> respondToRideRequest({
    required String requestId,
    required bool isAccepted,
    required String currentUserId,
    String? rejectionReason,
  }) async {
    try {
      // Get the ride request
      final request = await _requestRepository.getRideRequestById(requestId);
      if (request == null) {
        throw Exception('Ride request not found');
      }

      // Get the ride details
      final ride = await _rideRepository.getRideById(request.rideId);
      if (ride == null) {
        throw Exception('Ride not found');
      }

      // Validate user is the driver
      if (ride.driverId != currentUserId) {
        throw Exception('You can only respond to requests for your own rides');
      }

      // Validate request is still pending
      if (!request.isActionable) {
        throw Exception('This request has already been responded to');
      }

      if (isAccepted) {
        // Check if there are still available seats
        if (!ride.capacity.hasAvailableSeats) {
          throw Exception('No more seats available in this ride');
        }

        // Accept the request
        await _requestRepository.acceptRideRequest(requestId);
        
        // Add passenger to the ride
        await _rideRepository.addPassengerToRide(request.rideId, request.passengerId);
      } else {
        // Reject the request
        await _requestRepository.rejectRideRequest(requestId, rejectionReason);
      }
    } catch (e) {
      throw Exception('Failed to respond to ride request: $e');
    }
  }

  /// Cancel a ride request
  /// 
  /// Allows a passenger to cancel their pending ride request.
  Future<void> cancelRideRequest({
    required String requestId,
    required String currentUserId,
  }) async {
    try {
      // Get the ride request
      final request = await _requestRepository.getRideRequestById(requestId);
      if (request == null) {
        throw Exception('Ride request not found');
      }

      // Validate user is the passenger
      if (request.passengerId != currentUserId) {
        throw Exception('You can only cancel your own ride requests');
      }

      // Validate request is still actionable
      if (!request.isActionable) {
        throw Exception('This request cannot be cancelled');
      }

      await _requestRepository.cancelRideRequest(requestId);
    } catch (e) {
      throw Exception('Failed to cancel ride request: $e');
    }
  }

  /// Cancel a ride
  /// 
  /// Allows a driver to cancel their ride offer.
  Future<void> cancelRide({
    required String rideId,
    required String currentUserId,
  }) async {
    try {
      // Get the ride details
      final ride = await _rideRepository.getRideById(rideId);
      if (ride == null) {
        throw Exception('Ride not found');
      }

      // Validate user is the driver
      if (ride.driverId != currentUserId) {
        throw Exception('You can only cancel your own rides');
      }

      // Validate ride can be cancelled
      if (ride.status != RideStatus.active && ride.status != RideStatus.full) {
        throw Exception('This ride cannot be cancelled');
      }

      await _rideRepository.cancelRide(rideId);
    } catch (e) {
      throw Exception('Failed to cancel ride: $e');
    }
  }

  /// Get available rides with filters
  Stream<List<Ride>> getAvailableRides({
    String? originAddress,
    String? destinationAddress,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    int? minSeats,
  }) {
    return _rideRepository.getAvailableRidesStream(
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      startDate: startDate,
      endDate: endDate,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minSeats: minSeats,
    );
  }

  /// Get rides offered by current user
  Stream<List<Ride>> getMyOfferedRides(String userId) {
    return _rideRepository.getRidesByDriverStream(userId);
  }

  /// Get rides booked by current user
  Stream<List<Ride>> getMyBookedRides(String userId) {
    return _rideRepository.getRidesByPassengerStream(userId);
  }

  /// Get upcoming rides for current user
  Stream<List<Ride>> getUpcomingRides(String userId) {
    return _rideRepository.getUpcomingRidesStream(userId);
  }

  /// Get ride requests for a specific ride
  Stream<List<RideRequest>> getRideRequests(String rideId) {
    return _requestRepository.getRideRequestsForRideStream(rideId);
  }

  /// Get pending requests for current user's rides
  Stream<List<RideRequest>> getMyRideRequests(String userId) {
    return _requestRepository.getDriverRideRequestsStream(userId);
  }

  /// Get current user's ride requests
  Stream<List<RideRequest>> getMyRequests(String userId) {
    return _requestRepository.getRideRequestsByPassengerStream(userId);
  }

  /// Search rides by location
  Stream<List<Ride>> searchRides(String query) {
    return _rideRepository.searchRidesStream(query);
  }

  /// Get a specific ride by ID
  Future<Ride?> getRideById(String rideId) {
    return _rideRepository.getRideById(rideId);
  }

  /// Leave a ride (for passengers)
  Future<void> leaveRide({
    required String rideId,
    required String currentUserId,
  }) async {
    try {
      // Get the ride details
      final ride = await _rideRepository.getRideById(rideId);
      if (ride == null) {
        throw Exception('Ride not found');
      }

      // Validate user is a confirmed rider
      if (!ride.confirmedRiders.contains(currentUserId)) {
        throw Exception('You are not part of this ride');
      }

      // Remove passenger from the ride
      await _rideRepository.removePassengerFromRide(rideId, currentUserId);
    } catch (e) {
      throw Exception('Failed to leave ride: $e');
    }
  }

  /// Validate ride creation data
  void _validateRideData({
    required Location origin,
    required Location destination,
    required DateTime departureTime,
    required double pricePerSeat,
    required int availableSeats,
  }) {
    // Check departure time is in the future
    if (departureTime.isBefore(DateTime.now().add(
        Duration(minutes: AppConstants.minAdvanceBookingMinutes)))) {
      throw Exception('Departure time must be at least ${AppConstants.minAdvanceBookingMinutes} minutes in the future');
    }

    // Check departure time is not too far in the future
    if (departureTime.isAfter(DateTime.now().add(
        Duration(days: AppConstants.maxAdvanceBookingDays)))) {
      throw Exception('Departure time cannot be more than ${AppConstants.maxAdvanceBookingDays} days in the future');
    }

    // Validate price per seat
    if (pricePerSeat < AppConstants.minPricePerSeat ||
        pricePerSeat > AppConstants.maxPricePerSeat) {
      throw Exception('Price per seat must be between R${AppConstants.minPricePerSeat} and R${AppConstants.maxPricePerSeat}');
    }

    // Validate available seats
    if (availableSeats < AppConstants.minSeats ||
        availableSeats > AppConstants.maxSeats) {
      throw Exception('Available seats must be between ${AppConstants.minSeats} and ${AppConstants.maxSeats}');
    }

    // Validate origin and destination are different
    if (origin.address.toLowerCase() == destination.address.toLowerCase()) {
      throw Exception('Origin and destination must be different');
    }
  }
}