import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../models/ride_request_model.dart';

/// Repository for handling all Firebase operations related to rides
class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _ridesCollection => _firestore.collection('rides');
  CollectionReference get _rideRequestsCollection => _firestore.collection('ride_requests');

  /// Create a new ride offer
  /// Returns the created ride with the generated ID
  Future<Ride> createRide(CreateRideRequest request) async {
    try {
      // Generate a new document reference to get the ID
      final docRef = _ridesCollection.doc();
      final ride = request.toRide(docRef.id);
      
      // Save to Firestore
      await docRef.set(ride.toJson());
      
      return ride;
    } catch (e) {
      throw Exception('Failed to create ride: $e');
    }
  }

  /// Get all available rides with optional filters
  Stream<List<Ride>> getAvailableRides({
    String? fromLocation,
    String? toLocation,
    DateTime? fromDate,
    DateTime? toDate,
    double? maxPrice,
    int? minSeats,
  }) {
    try {
      Query query = _ridesCollection.where('status', isEqualTo: 'active');
      
      // Apply date filter if provided
      if (fromDate != null) {
        query = query.where('schedule.departureTime', 
            isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }
      
      if (toDate != null) {
        query = query.where('schedule.departureTime', 
            isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }
      
      // Apply price filter if provided
      if (maxPrice != null) {
        query = query.where('pricing.pricePerSeat', isLessThanOrEqualTo: maxPrice);
      }
      
      // Apply seat filter if provided
      if (minSeats != null) {
        query = query.where('capacity.availableSeats', isGreaterThanOrEqualTo: minSeats);
      }
      
      // Order by departure time
      query = query.orderBy('schedule.departureTime');
      
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Ride.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw Exception('Failed to get available rides: $e');
    }
  }

  /// Get a specific ride by ID
  Future<Ride?> getRideById(String rideId) async {
    try {
      final doc = await _ridesCollection.doc(rideId).get();
      if (doc.exists) {
        return Ride.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get ride: $e');
    }
  }

  /// Get rides created by a specific driver
  Stream<List<Ride>> getRidesByDriver(String driverId) {
    try {
      return _ridesCollection
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Ride.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw Exception('Failed to get driver rides: $e');
    }
  }

  /// Get rides where user is a confirmed passenger
  Stream<List<Ride>> getRidesAsPassenger(String passengerId) {
    try {
      return _ridesCollection
          .where('confirmedRiders', arrayContains: passengerId)
          .orderBy('schedule.departureTime')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Ride.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw Exception('Failed to get passenger rides: $e');
    }
  }

  /// Update ride status
  Future<void> updateRideStatus(String rideId, RideStatus status) async {
    try {
      await _ridesCollection.doc(rideId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update ride status: $e');
    }
  }

  /// Update ride capacity (when passenger is added/removed)
  Future<void> updateRideCapacity(String rideId, int newAvailableSeats, List<String> confirmedRiders) async {
    try {
      await _ridesCollection.doc(rideId).update({
        'capacity.availableSeats': newAvailableSeats,
        'confirmedRiders': confirmedRiders,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update ride capacity: $e');
    }
  }

  /// Delete a ride (only by the driver)
  Future<void> deleteRide(String rideId) async {
    try {
      await _ridesCollection.doc(rideId).delete();
    } catch (e) {
      throw Exception('Failed to delete ride: $e');
    }
  }

  /// Search rides by location text
  Future<List<Ride>> searchRides(String searchQuery) async {
    try {
      // Note: This is a basic text search. For production, consider using
      // Algolia or other search services for better text search capabilities
      final snapshot = await _ridesCollection
          .where('status', isEqualTo: 'active')
          .get();
      
      final rides = snapshot.docs.map((doc) => Ride.fromFirestore(doc)).toList();
      
      // Filter by search query (case-insensitive)
      final filteredRides = rides.where((ride) {
        final searchLower = searchQuery.toLowerCase();
        return ride.route.origin.address.toLowerCase().contains(searchLower) ||
               ride.route.destination.address.toLowerCase().contains(searchLower);
      }).toList();
      
      return filteredRides;
    } catch (e) {
      throw Exception('Failed to search rides: $e');
    }
  }

  // === RIDE REQUEST OPERATIONS ===

  /// Create a ride request
  Future<RideRequest> createRideRequest(CreateRideRequestData requestData) async {
    try {
      final docRef = _rideRequestsCollection.doc();
      final rideRequest = requestData.toRideRequest(docRef.id);
      
      await docRef.set(rideRequest.toJson());
      
      return rideRequest;
    } catch (e) {
      throw Exception('Failed to create ride request: $e');
    }
  }

  /// Get ride requests for a specific ride (for drivers)
  Stream<List<RideRequest>> getRideRequestsForRide(String rideId) {
    try {
      return _rideRequestsCollection
          .where('rideId', isEqualTo: rideId)
          .orderBy('requestedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => RideRequest.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw Exception('Failed to get ride requests: $e');
    }
  }

  /// Get ride requests made by a specific passenger
  Stream<List<RideRequest>> getRideRequestsByPassenger(String passengerId) {
    try {
      return _rideRequestsCollection
          .where('passengerId', isEqualTo: passengerId)
          .orderBy('requestedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => RideRequest.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw Exception('Failed to get passenger requests: $e');
    }
  }

  /// Update ride request status (accept/reject)
  Future<void> updateRideRequestStatus(
    String requestId, 
    RideRequestStatus status,
    [String? responseMessage]
  ) async {
    try {
      final updateData = {
        'status': status.name,
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (responseMessage != null) {
        updateData['responseMessage'] = responseMessage;
      }
      
      await _rideRequestsCollection.doc(requestId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update ride request status: $e');
    }
  }

  /// Check if a passenger has already requested to join a ride
  Future<bool> hasExistingRequest(String rideId, String passengerId) async {
    try {
      final snapshot = await _rideRequestsCollection
          .where('rideId', isEqualTo: rideId)
          .where('passengerId', isEqualTo: passengerId)
          .where('status', isEqualTo: 'pending')
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check existing request: $e');
    }
  }

  /// Get pending ride requests count for a driver
  Future<int> getPendingRequestsCount(String driverId) async {
    try {
      // First get all rides by this driver
      final ridesSnapshot = await _ridesCollection
          .where('driverId', isEqualTo: driverId)
          .get();
      
      if (ridesSnapshot.docs.isEmpty) return 0;
      
      final rideIds = ridesSnapshot.docs.map((doc) => doc.id).toList();
      
      int totalCount = 0;
      
      // Get pending requests for each ride
      for (final rideId in rideIds) {
        final requestsSnapshot = await _rideRequestsCollection
            .where('rideId', isEqualTo: rideId)
            .where('status', isEqualTo: 'pending')
            .get();
        
        totalCount += requestsSnapshot.docs.length;
      }
      
      return totalCount;
    } catch (e) {
      throw Exception('Failed to get pending requests count: $e');
    }
  }

  /// Get ride request by ID
  Future<RideRequest?> getRideRequestById(String requestId) async {
    try {
      final doc = await _rideRequestsCollection.doc(requestId).get();
      if (doc.exists) {
        return RideRequest.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get ride request: $e');
    }
  }

  /// Cancel a ride request (by passenger)
  Future<void> cancelRideRequest(String requestId) async {
    try {
      await _rideRequestsCollection.doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to cancel ride request: $e');
    }
  }

  // === BATCH OPERATIONS ===

  /// Accept a ride request and update ride capacity
  Future<void> acceptRideRequest(String requestId, String rideId) async {
    try {
      final batch = _firestore.batch();
      
      // Update request status
      batch.update(_rideRequestsCollection.doc(requestId), {
        'status': RideRequestStatus.accepted.name,
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      // Get current ride data
      final rideDoc = await _ridesCollection.doc(rideId).get();
      if (!rideDoc.exists) {
        throw Exception('Ride not found');
      }
      
      final ride = Ride.fromFirestore(rideDoc);
      final request = await getRideRequestById(requestId);
      
      if (request == null) {
        throw Exception('Request not found');
      }
      
      // Update ride capacity and confirmed riders
      final newAvailableSeats = ride.capacity.availableSeats - 1;
      final updatedConfirmedRiders = [...ride.confirmedRiders, request.passengerId];
      
      batch.update(_ridesCollection.doc(rideId), {
        'capacity.availableSeats': newAvailableSeats,
        'confirmedRiders': updatedConfirmedRiders,
        'status': newAvailableSeats == 0 ? RideStatus.full.name : RideStatus.active.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to accept ride request: $e');
    }
  }

  /// Reject multiple ride requests at once
  Future<void> rejectMultipleRequests(List<String> requestIds, [String? reason]) async {
    try {
      final batch = _firestore.batch();
      
      for (final requestId in requestIds) {
        final updateData = {
          'status': RideRequestStatus.rejected.name,
          'respondedAt': Timestamp.fromDate(DateTime.now()),
        };
        
        if (reason != null) {
          updateData['responseMessage'] = reason;
        }
        
        batch.update(_rideRequestsCollection.doc(requestId), updateData);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reject requests: $e');
    }
  }

  /// Remove a passenger from a ride and update capacity
  Future<void> removePassengerFromRide(String rideId, String passengerId) async {
    try {
      final batch = _firestore.batch();
      
      // Get current ride data
      final rideDoc = await _ridesCollection.doc(rideId).get();
      if (!rideDoc.exists) {
        throw Exception('Ride not found');
      }
      
      final ride = Ride.fromFirestore(rideDoc);
      
      // Update ride capacity and confirmed riders
      final newAvailableSeats = ride.capacity.availableSeats + 1;
      final updatedConfirmedRiders = ride.confirmedRiders.where((id) => id != passengerId).toList();
      
      batch.update(_ridesCollection.doc(rideId), {
        'capacity.availableSeats': newAvailableSeats,
        'confirmedRiders': updatedConfirmedRiders,
        'status': RideStatus.active.name, // Reopen the ride
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove passenger: $e');
    }
  }
}