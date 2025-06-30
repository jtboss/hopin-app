import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ride_model.dart';
import '../models/user_model.dart';

/// Service for managing ride operations and business logic
class RideService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  static const String _ridesCollection = 'rides';
  static const String _rideRequestsCollection = 'rideRequests';

  List<RideModel> _availableRides = [];
  List<RideModel> _userRides = [];
  List<RideRequestModel> _userRequests = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RideModel> get availableRides => _availableRides;
  List<RideModel> get userRides => _userRides;
  List<RideRequestModel> get userRequests => _userRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// CRUD Operations

  /// Creates a new ride
  Future<String> createRide(CreateRideRequest request) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate request
      _validateCreateRideRequest(request);

      // Generate ride ID
      final rideId = _uuid.v4();

      // Create ride model
      final ride = RideModel(
        rideId: rideId,
        driverId: request.driverId,
        driver: request.driver,
        route: request.route,
        departureTime: request.departureTime,
        availableSeats: request.totalSeats,
        totalSeats: request.totalSeats,
        pricePerSeat: request.pricePerSeat,
        status: RideStatus.active,
        passengerIds: [],
        requests: [],
        createdAt: DateTime.now(),
        preferences: request.preferences,
        notes: request.notes,
      );

      // Save to Firestore
      await _firestore.collection(_ridesCollection).doc(rideId).set(ride.toJson());

      // Update local cache
      _availableRides.insert(0, ride);
      notifyListeners();

      return rideId;
    } catch (e) {
      _setError('Failed to create ride: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Gets available rides with optional filtering
  Future<List<RideModel>> getAvailableRides({
    LocationPoint? origin,
    LocationPoint? destination,
    DateTime? date,
    int? minSeats,
    double? maxPrice,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      Query query = _firestore
          .collection(_ridesCollection)
          .where('status', isEqualTo: 'active')
          .where('availableSeats', isGreaterThan: 0)
          .orderBy('departureTime')
          .limit(limit);

      // Apply filters
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .where('departureTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('departureTime', isLessThan: Timestamp.fromDate(endOfDay));
      }

      if (maxPrice != null) {
        query = query.where('pricePerSeat', isLessThanOrEqualTo: maxPrice);
      }

      final snapshot = await query.get();
      final rides = snapshot.docs.map((doc) => RideModel.fromFirestore(doc)).toList();

      // Apply location and seat filters (client-side for now)
      List<RideModel> filteredRides = rides;

      if (minSeats != null) {
        filteredRides = filteredRides.where((ride) => ride.availableSeats >= minSeats).toList();
      }

      if (origin != null) {
        filteredRides = filteredRides.where((ride) {
          return _calculateDistance(ride.route.pickup, origin) <= 5.0; // 5km radius
        }).toList();
      }

      if (destination != null) {
        filteredRides = filteredRides.where((ride) {
          return _calculateDistance(ride.route.destination, destination) <= 5.0; // 5km radius
        }).toList();
      }

      _availableRides = filteredRides;
      notifyListeners();

      return filteredRides;
    } catch (e) {
      _setError('Failed to fetch rides: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Gets a specific ride by ID
  Future<RideModel?> getRideById(String rideId) async {
    try {
      final doc = await _firestore.collection(_ridesCollection).doc(rideId).get();
      if (doc.exists) {
        return RideModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('Failed to fetch ride: $e');
      return null;
    }
  }

  /// Updates a ride (driver only)
  Future<bool> updateRide(String rideId, UpdateRideRequest request) async {
    try {
      _setLoading(true);
      _clearError();

      final updateData = <String, dynamic>{};

      if (request.departureTime != null) {
        updateData['departureTime'] = Timestamp.fromDate(request.departureTime!);
      }
      if (request.pricePerSeat != null) {
        updateData['pricePerSeat'] = request.pricePerSeat;
      }
      if (request.notes != null) {
        updateData['notes'] = request.notes;
      }
      if (request.preferences != null) {
        updateData['preferences'] = request.preferences!.toJson();
      }

      updateData['updatedAt'] = Timestamp.now();

      await _firestore.collection(_ridesCollection).doc(rideId).update(updateData);

      // Update local cache
      final index = _availableRides.indexWhere((ride) => ride.rideId == rideId);
      if (index != -1) {
        // Refresh the ride from Firestore
        final updatedRide = await getRideById(rideId);
        if (updatedRide != null) {
          _availableRides[index] = updatedRide;
          notifyListeners();
        }
      }

      return true;
    } catch (e) {
      _setError('Failed to update ride: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancels a ride (driver only)
  Future<bool> cancelRide(String rideId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore.collection(_ridesCollection).doc(rideId).update({
        'status': RideStatus.cancelled.name,
        'updatedAt': Timestamp.now(),
      });

      // Remove from available rides
      _availableRides.removeWhere((ride) => ride.rideId == rideId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to cancel ride: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Request Management

  /// Requests to join a ride
  Future<String> requestRide(String rideId, int seatsRequested, String? message) async {
    try {
      _setLoading(true);
      _clearError();

      // Get current user ID (this would come from AuthService in real implementation)
      final currentUserId = 'current_user_id'; // TODO: Get from AuthService
      
      // Check if ride exists and has available seats
      final ride = await getRideById(rideId);
      if (ride == null) {
        throw Exception('Ride not found');
      }

      if (ride.availableSeats < seatsRequested) {
        throw Exception('Not enough available seats');
      }

      if (ride.driverId == currentUserId) {
        throw Exception('Cannot request your own ride');
      }

      // Check if user already has a pending request
      final existingRequest = ride.requests.firstWhere(
        (req) => req.passengerId == currentUserId && req.status == RequestStatus.pending,
        orElse: () => RideRequestModel(
          requestId: '',
          rideId: '',
          passengerId: '',
          passenger: UserModel(
            uid: '',
            email: '',
            firstName: '',
            lastName: '',
            university: '',
            verificationStatus: const VerificationStatus(),
            preferences: const UserPreferences(),
            roles: const [],
            createdAt: DateTime(2000),
            lastActive: DateTime(2000),
          ),
          seatsRequested: 0,
          status: RequestStatus.cancelled,
          requestedAt: DateTime(2000),
        ),
      );

      if (existingRequest.requestId.isNotEmpty) {
        throw Exception('You already have a pending request for this ride');
      }

      // Create ride request
      final requestId = _uuid.v4();
      final request = RideRequestModel(
        requestId: requestId,
        rideId: rideId,
        passengerId: currentUserId,
        passenger: UserModel(
          uid: currentUserId,
          email: 'current@user.com', // TODO: Get from AuthService
          firstName: 'Current',
          lastName: 'User',
          university: 'stellenbosch',
          verificationStatus: const VerificationStatus(emailVerified: true),
          preferences: const UserPreferences(),
          roles: [UserRole.rider],
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        ),
        seatsRequested: seatsRequested,
        status: RequestStatus.pending,
        requestedAt: DateTime.now(),
        message: message,
      );

      // Save to Firestore
      await _firestore.collection(_rideRequestsCollection).doc(requestId).set(request.toJson());

      // Update local cache
      _userRequests.add(request);
      notifyListeners();

      return requestId;
    } catch (e) {
      _setError('Failed to request ride: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Approves a ride request (driver only)
  Future<bool> approveRequest(String requestId) async {
    try {
      _setLoading(true);
      _clearError();

      // Get request
      final requestDoc = await _firestore.collection(_rideRequestsCollection).doc(requestId).get();
      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final request = RideRequestModel.fromFirestore(requestDoc);
      
      // Get ride
      final ride = await getRideById(request.rideId);
      if (ride == null) {
        throw Exception('Ride not found');
      }

      // Check if enough seats available
      if (ride.availableSeats < request.seatsRequested) {
        throw Exception('Not enough available seats');
      }

      // Use batch to update both documents atomically
      final batch = _firestore.batch();

      // Update request status
      batch.update(_firestore.collection(_rideRequestsCollection).doc(requestId), {
        'status': RequestStatus.accepted.name,
        'respondedAt': Timestamp.now(),
      });

      // Update ride with new passenger
      final newPassengerIds = [...ride.passengerIds, request.passengerId];
      final newAvailableSeats = ride.availableSeats - request.seatsRequested;
      final newStatus = newAvailableSeats <= 0 ? RideStatus.full : RideStatus.active;

      batch.update(_firestore.collection(_ridesCollection).doc(request.rideId), {
        'passengerIds': newPassengerIds,
        'availableSeats': newAvailableSeats,
        'status': newStatus.name,
        'updatedAt': Timestamp.now(),
      });

      await batch.commit();

      // Update local cache
      final rideIndex = _availableRides.indexWhere((r) => r.rideId == request.rideId);
      if (rideIndex != -1) {
        _availableRides[rideIndex] = _availableRides[rideIndex].copyWith(
          passengerIds: newPassengerIds,
          availableSeats: newAvailableSeats,
          status: newStatus,
        );
      }

      final requestIndex = _userRequests.indexWhere((r) => r.requestId == requestId);
      if (requestIndex != -1) {
        _userRequests[requestIndex] = _userRequests[requestIndex].copyWith(
          status: RequestStatus.accepted,
          respondedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to approve request: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Rejects a ride request (driver only)
  Future<bool> rejectRequest(String requestId, String? reason) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore.collection(_rideRequestsCollection).doc(requestId).update({
        'status': RequestStatus.rejected.name,
        'respondedAt': Timestamp.now(),
        'responseMessage': reason,
      });

      // Update local cache
      final requestIndex = _userRequests.indexWhere((r) => r.requestId == requestId);
      if (requestIndex != -1) {
        _userRequests[requestIndex] = _userRequests[requestIndex].copyWith(
          status: RequestStatus.rejected,
          respondedAt: DateTime.now(),
          responseMessage: reason,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to reject request: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Real-time Updates

  /// Watches available rides in real-time
  Stream<List<RideModel>> watchAvailableRides() {
    return _firestore
        .collection(_ridesCollection)
        .where('status', isEqualTo: 'active')
        .where('availableSeats', isGreaterThan: 0)
        .orderBy('departureTime')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RideModel.fromFirestore(doc)).toList());
  }

  /// Watches a specific ride in real-time
  Stream<RideModel> watchRide(String rideId) {
    return _firestore
        .collection(_ridesCollection)
        .doc(rideId)
        .snapshots()
        .map((doc) => RideModel.fromFirestore(doc));
  }

  /// Watches ride requests for a specific ride
  Stream<List<RideRequestModel>> watchRideRequests(String rideId) {
    return _firestore
        .collection(_rideRequestsCollection)
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RideRequestModel.fromFirestore(doc)).toList());
  }

  /// Search & Filtering

  /// Searches rides with advanced filters
  Future<List<RideModel>> searchRides(RideSearchFilter filter) async {
    try {
      _setLoading(true);
      _clearError();

      Query query = _firestore
          .collection(_ridesCollection)
          .where('status', isEqualTo: 'active')
          .where('availableSeats', isGreaterThan: 0);

      // Apply filters
      if (filter.date != null) {
        final startOfDay = DateTime(filter.date!.year, filter.date!.month, filter.date!.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .where('departureTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('departureTime', isLessThan: Timestamp.fromDate(endOfDay));
      }

      if (filter.maxPrice != null) {
        query = query.where('pricePerSeat', isLessThanOrEqualTo: filter.maxPrice);
      }

      // Apply sorting
      switch (filter.sortBy) {
        case RideSortBy.time:
          query = query.orderBy('departureTime');
          break;
        case RideSortBy.price:
          query = query.orderBy('pricePerSeat');
          break;
        case RideSortBy.seats:
          query = query.orderBy('availableSeats', descending: true);
          break;
        default:
          query = query.orderBy('departureTime');
      }

      final snapshot = await query.limit(filter.limit ?? 20).get();
      final rides = snapshot.docs.map((doc) => RideModel.fromFirestore(doc)).toList();

      return rides;
    } catch (e) {
      _setError('Failed to search rides: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Gets rides for a specific user
  Future<List<RideModel>> getUserRides(String userId) async {
    try {
      // Get rides where user is driver
      final driverQuery = await _firestore
          .collection(_ridesCollection)
          .where('driverId', isEqualTo: userId)
          .orderBy('departureTime', descending: true)
          .get();

      // Get rides where user is passenger
      final passengerQuery = await _firestore
          .collection(_ridesCollection)
          .where('passengerIds', arrayContains: userId)
          .orderBy('departureTime', descending: true)
          .get();

      final driverRides = driverQuery.docs.map((doc) => RideModel.fromFirestore(doc)).toList();
      final passengerRides = passengerQuery.docs.map((doc) => RideModel.fromFirestore(doc)).toList();

      // Combine and sort by departure time
      final allRides = [...driverRides, ...passengerRides];
      allRides.sort((a, b) => b.departureTime.compareTo(a.departureTime));

      _userRides = allRides;
      notifyListeners();

      return allRides;
    } catch (e) {
      _setError('Failed to fetch user rides: $e');
      return [];
    }
  }

  /// Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _validateCreateRideRequest(CreateRideRequest request) {
    if (request.route.pickup.address.isEmpty) {
      throw Exception('Pickup location is required');
    }
    if (request.route.destination.address.isEmpty) {
      throw Exception('Destination is required');
    }
    if (request.departureTime.isBefore(DateTime.now())) {
      throw Exception('Departure time must be in the future');
    }
    if (request.totalSeats < 1 || request.totalSeats > 6) {
      throw Exception('Seats must be between 1 and 6');
    }
    if (request.pricePerSeat < 0 || request.pricePerSeat > 100) {
      throw Exception('Price must be between R0 and R100');
    }
  }

  double _calculateDistance(LocationPoint point1, LocationPoint point2) {
    // Simplified distance calculation using Haversine formula
    // This is a basic implementation - in production, use a proper geolocation library
    const double earthRadius = 6371; // km

    final lat1Rad = point1.latitude * (pi / 180);
    final lat2Rad = point2.latitude * (pi / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}

/// Request model for creating a ride
class CreateRideRequest {
  final String driverId;
  final UserModel driver;
  final RouteInfo route;
  final DateTime departureTime;
  final int totalSeats;
  final double pricePerSeat;
  final RidePreferences preferences;
  final String? notes;

  const CreateRideRequest({
    required this.driverId,
    required this.driver,
    required this.route,
    required this.departureTime,
    required this.totalSeats,
    required this.pricePerSeat,
    required this.preferences,
    this.notes,
  });
}

/// Request model for updating a ride
class UpdateRideRequest {
  final DateTime? departureTime;
  final double? pricePerSeat;
  final RidePreferences? preferences;
  final String? notes;

  const UpdateRideRequest({
    this.departureTime,
    this.pricePerSeat,
    this.preferences,
    this.notes,
  });
}

/// Filter model for searching rides
class RideSearchFilter {
  final LocationPoint? origin;
  final LocationPoint? destination;
  final DateTime? date;
  final int? minSeats;
  final double? maxPrice;
  final RideSortBy sortBy;
  final int? limit;

  const RideSearchFilter({
    this.origin,
    this.destination,
    this.date,
    this.minSeats,
    this.maxPrice,
    this.sortBy = RideSortBy.time,
    this.limit,
  });
}

/// Enum for sorting ride search results
enum RideSortBy {
  time,
  price,
  seats,
  distance,
}