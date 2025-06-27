import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_request_model.dart';
import '../constants/app_constants.dart';

/// Repository for managing ride request data in Firestore
class RideRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new ride request
  /// 
  /// Creates a new ride request document in Firestore.
  /// Returns the created ride request with its generated ID.
  Future<RideRequest> createRideRequest(RideRequest request) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .add(request.toMap());

      final createdRequest = request.copyWith(requestId: docRef.id);
      
      // Update the document with the generated ID
      await docRef.update({'requestId': docRef.id});
      
      return createdRequest;
    } catch (e) {
      throw Exception('Failed to create ride request: $e');
    }
  }

  /// Get a specific ride request by ID
  Future<RideRequest?> getRideRequestById(String requestId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .doc(requestId)
          .get();

      if (doc.exists) {
        return RideRequest.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get ride request: $e');
    }
  }

  /// Update an existing ride request
  Future<void> updateRideRequest(RideRequest request) async {
    try {
      await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .doc(request.requestId)
          .update(request.toMap());
    } catch (e) {
      throw Exception('Failed to update ride request: $e');
    }
  }

  /// Delete a ride request
  Future<void> deleteRideRequest(String requestId) async {
    try {
      await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .doc(requestId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete ride request: $e');
    }
  }

  /// Get ride requests for a specific ride (for drivers)
  Stream<List<RideRequest>> getRideRequestsForRideStream(String rideId) {
    try {
      return _firestore
          .collection(AppConstants.rideRequestsCollection)
          .where('rideId', isEqualTo: rideId)
          .orderBy('requestedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RideRequest.fromSnapshot(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get ride requests: $e');
    }
  }

  /// Get pending ride requests for a specific ride
  Stream<List<RideRequest>> getPendingRequestsForRideStream(String rideId) {
    try {
      return _firestore
          .collection(AppConstants.rideRequestsCollection)
          .where('rideId', isEqualTo: rideId)
          .where('status', isEqualTo: RideRequestStatus.pending.name)
          .orderBy('requestedAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RideRequest.fromSnapshot(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get pending ride requests: $e');
    }
  }

  /// Get ride requests by passenger ID
  Stream<List<RideRequest>> getRideRequestsByPassengerStream(String passengerId) {
    try {
      return _firestore
          .collection(AppConstants.rideRequestsCollection)
          .where('passengerId', isEqualTo: passengerId)
          .orderBy('requestedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RideRequest.fromSnapshot(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get passenger ride requests: $e');
    }
  }

  /// Get pending ride requests by passenger ID
  Stream<List<RideRequest>> getPendingRequestsByPassengerStream(String passengerId) {
    try {
      return _firestore
          .collection(AppConstants.rideRequestsCollection)
          .where('passengerId', isEqualTo: passengerId)
          .where('status', isEqualTo: RideRequestStatus.pending.name)
          .orderBy('requestedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RideRequest.fromSnapshot(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get pending passenger requests: $e');
    }
  }

  /// Accept a ride request
  Future<void> acceptRideRequest(String requestId) async {
    try {
      await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .doc(requestId)
          .update({
        'status': RideRequestStatus.accepted.name,
        'respondedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to accept ride request: $e');
    }
  }

  /// Reject a ride request
  Future<void> rejectRideRequest(String requestId, String? reason) async {
    try {
      final updateData = {
        'status': RideRequestStatus.rejected.name,
        'respondedAt': Timestamp.now(),
      };

      if (reason != null) {
        updateData['rejectionReason'] = reason;
      }

      await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .doc(requestId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to reject ride request: $e');
    }
  }

  /// Cancel a ride request (by passenger)
  Future<void> cancelRideRequest(String requestId) async {
    try {
      await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .doc(requestId)
          .update({
        'status': RideRequestStatus.cancelled.name,
        'respondedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to cancel ride request: $e');
    }
  }

  /// Check if a passenger has already requested a specific ride
  Future<bool> hasPassengerRequestedRide(String rideId, String passengerId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .where('rideId', isEqualTo: rideId)
          .where('passengerId', isEqualTo: passengerId)
          .where('status', whereIn: [
            RideRequestStatus.pending.name,
            RideRequestStatus.accepted.name,
          ])
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check ride request status: $e');
    }
  }

  /// Get all ride requests for rides owned by a driver
  Stream<List<RideRequest>> getDriverRideRequestsStream(String driverId) {
    try {
      return _firestore
          .collection(AppConstants.rideRequestsCollection)
          .where('status', isEqualTo: RideRequestStatus.pending.name)
          .orderBy('requestedAt', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        final requests = snapshot.docs
            .map((doc) => RideRequest.fromSnapshot(doc))
            .toList();

        // Filter requests for rides owned by the driver
        final driverRequests = <RideRequest>[];
        
        for (final request in requests) {
          try {
            final rideDoc = await _firestore
                .collection(AppConstants.ridesCollection)
                .doc(request.rideId)
                .get();

            if (rideDoc.exists) {
              final rideData = rideDoc.data() as Map<String, dynamic>;
              if (rideData['driverId'] == driverId) {
                driverRequests.add(request);
              }
            }
          } catch (e) {
            // Skip this request if ride doesn't exist or error occurs
            continue;
          }
        }

        return driverRequests;
      });
    } catch (e) {
      throw Exception('Failed to get driver ride requests: $e');
    }
  }

  /// Get ride request statistics for a passenger
  Future<Map<String, int>> getPassengerRequestStats(String passengerId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .where('passengerId', isEqualTo: passengerId)
          .get();

      final stats = {
        'total': 0,
        'pending': 0,
        'accepted': 0,
        'rejected': 0,
        'cancelled': 0,
      };

      for (final doc in query.docs) {
        final request = RideRequest.fromSnapshot(doc);
        stats['total'] = stats['total']! + 1;
        stats[request.status.name] = stats[request.status.name]! + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get passenger request stats: $e');
    }
  }

  /// Get ride request statistics for a driver
  Future<Map<String, int>> getDriverRequestStats(String driverId) async {
    try {
      // First get all rides by the driver
      final ridesQuery = await _firestore
          .collection(AppConstants.ridesCollection)
          .where('driverId', isEqualTo: driverId)
          .get();

      final rideIds = ridesQuery.docs.map((doc) => doc.id).toList();

      if (rideIds.isEmpty) {
        return {
          'total': 0,
          'pending': 0,
          'accepted': 0,
          'rejected': 0,
          'cancelled': 0,
        };
      }

      // Get all requests for these rides
      final requestsQuery = await _firestore
          .collection(AppConstants.rideRequestsCollection)
          .where('rideId', whereIn: rideIds)
          .get();

      final stats = {
        'total': 0,
        'pending': 0,
        'accepted': 0,
        'rejected': 0,
        'cancelled': 0,
      };

      for (final doc in requestsQuery.docs) {
        final request = RideRequest.fromSnapshot(doc);
        stats['total'] = stats['total']! + 1;
        stats[request.status.name] = stats[request.status.name]! + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get driver request stats: $e');
    }
  }
}