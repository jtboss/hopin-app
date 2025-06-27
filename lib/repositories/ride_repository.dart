import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../models/ride_request_model.dart';
import '../constants/app_constants.dart';

/// Repository for managing ride data in Firestore
class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new ride
  /// 
  /// Creates a new ride document in Firestore with the provided ride data.
  /// Returns the created ride with its generated ID.
  Future<Ride> createRide(Ride ride) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.ridesCollection)
          .add(ride.toMap());

      final createdRide = ride.copyWith(rideId: docRef.id);
      
      // Update the document with the generated ID
      await docRef.update({'rideId': docRef.id});
      
      return createdRide;
    } catch (e) {
      throw Exception('Failed to create ride: $e');
    }
  }

  /// Get a specific ride by ID
  Future<Ride?> getRideById(String rideId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId)
          .get();

      if (doc.exists) {
        return Ride.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get ride: $e');
    }
  }

  /// Update an existing ride
  Future<void> updateRide(Ride ride) async {
    try {
      await _firestore
          .collection(AppConstants.ridesCollection)
          .doc(ride.rideId)
          .update(ride.toMap());
    } catch (e) {
      throw Exception('Failed to update ride: $e');
    }
  }

  /// Delete a ride
  Future<void> deleteRide(String rideId) async {
    try {
      await _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete ride: $e');
    }
  }

  /// Get available rides stream with optional filters
  /// 
  /// Returns a real-time stream of available rides that can be filtered by:
  /// - Origin location
  /// - Destination location  
  /// - Date range
  /// - Price range
  /// - Available seats
  Stream<List<Ride>> getAvailableRidesStream({
    String? originAddress,
    String? destinationAddress,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    int? minSeats,
  }) {
    try {
      Query query = _firestore
          .collection(AppConstants.ridesCollection)
          .where('status', isEqualTo: RideStatus.active.name)
          .where('capacity.availableSeats', isGreaterThan: 0)
          .orderBy('capacity.availableSeats')
          .orderBy('schedule.departureTime');

      // Apply filters if provided
      if (startDate != null) {
        query = query.where('schedule.departureTime', 
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('schedule.departureTime', 
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (minPrice != null) {
        query = query.where('pricing.pricePerSeat', 
            isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('pricing.pricePerSeat', 
            isLessThanOrEqualTo: maxPrice);
      }

      if (minSeats != null) {
        query = query.where('capacity.availableSeats', 
            isGreaterThanOrEqualTo: minSeats);
      }

      return query.snapshots().map((snapshot) {
        final rides = snapshot.docs
            .map((doc) => Ride.fromSnapshot(doc))
            .toList();

        // Apply additional filters that can't be done in Firestore queries
        return rides.where((ride) {
          // Filter by origin address if provided
          if (originAddress != null && 
              !ride.route.origin.address.toLowerCase()
                  .contains(originAddress.toLowerCase())) {
            return false;
          }

          // Filter by destination address if provided
          if (destinationAddress != null && 
              !ride.route.destination.address.toLowerCase()
                  .contains(destinationAddress.toLowerCase())) {
            return false;
          }

          // Only return bookable rides
          return ride.isBookable;
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get available rides: $e');
    }
  }

  /// Get rides by driver ID
  Stream<List<Ride>> getRidesByDriverStream(String driverId) {
    try {
      return _firestore
          .collection(AppConstants.ridesCollection)
          .where('driverId', isEqualTo: driverId)
          .orderBy('schedule.departureTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Ride.fromSnapshot(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get driver rides: $e');
    }
  }

  /// Get rides by passenger ID (rides the user has booked)
  Stream<List<Ride>> getRidesByPassengerStream(String passengerId) {
    try {
      return _firestore
          .collection(AppConstants.ridesCollection)
          .where('confirmedRiders', arrayContains: passengerId)
          .orderBy('schedule.departureTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Ride.fromSnapshot(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get passenger rides: $e');
    }
  }

  /// Add a passenger to a ride
  Future<void> addPassengerToRide(String rideId, String passengerId) async {
    try {
      final rideRef = _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId);

      await _firestore.runTransaction((transaction) async {
        final rideDoc = await transaction.get(rideRef);
        
        if (!rideDoc.exists) {
          throw Exception('Ride not found');
        }

        final ride = Ride.fromSnapshot(rideDoc);
        
        if (!ride.capacity.hasAvailableSeats) {
          throw Exception('No available seats');
        }

        if (ride.confirmedRiders.contains(passengerId)) {
          throw Exception('Passenger already in ride');
        }

        // Update confirmed riders and available seats
        final updatedRiders = [...ride.confirmedRiders, passengerId];
        final updatedCapacity = ride.capacity.copyWith(
          availableSeats: ride.capacity.availableSeats - 1,
        );

        transaction.update(rideRef, {
          'confirmedRiders': updatedRiders,
          'capacity': updatedCapacity.toMap(),
          'updatedAt': Timestamp.now(),
        });

        // Update status to full if no more seats
        if (updatedCapacity.availableSeats == 0) {
          transaction.update(rideRef, {
            'status': RideStatus.full.name,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to add passenger to ride: $e');
    }
  }

  /// Remove a passenger from a ride
  Future<void> removePassengerFromRide(String rideId, String passengerId) async {
    try {
      final rideRef = _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId);

      await _firestore.runTransaction((transaction) async {
        final rideDoc = await transaction.get(rideRef);
        
        if (!rideDoc.exists) {
          throw Exception('Ride not found');
        }

        final ride = Ride.fromSnapshot(rideDoc);
        
        if (!ride.confirmedRiders.contains(passengerId)) {
          throw Exception('Passenger not in ride');
        }

        // Update confirmed riders and available seats
        final updatedRiders = ride.confirmedRiders
            .where((id) => id != passengerId)
            .toList();
        final updatedCapacity = ride.capacity.copyWith(
          availableSeats: ride.capacity.availableSeats + 1,
        );

        transaction.update(rideRef, {
          'confirmedRiders': updatedRiders,
          'capacity': updatedCapacity.toMap(),
          'updatedAt': Timestamp.now(),
        });

        // Update status back to active if was full
        if (ride.status == RideStatus.full) {
          transaction.update(rideRef, {
            'status': RideStatus.active.name,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to remove passenger from ride: $e');
    }
  }

  /// Cancel a ride
  Future<void> cancelRide(String rideId) async {
    try {
      await _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId)
          .update({
        'status': RideStatus.cancelled.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to cancel ride: $e');
    }
  }

  /// Complete a ride
  Future<void> completeRide(String rideId) async {
    try {
      await _firestore
          .collection(AppConstants.ridesCollection)
          .doc(rideId)
          .update({
        'status': RideStatus.completed.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to complete ride: $e');
    }
  }

  /// Search rides by location text
  Stream<List<Ride>> searchRidesStream(String searchQuery) {
    try {
      return _firestore
          .collection(AppConstants.ridesCollection)
          .where('status', isEqualTo: RideStatus.active.name)
          .snapshots()
          .map((snapshot) {
        final rides = snapshot.docs
            .map((doc) => Ride.fromSnapshot(doc))
            .where((ride) {
          final query = searchQuery.toLowerCase();
          return ride.route.origin.address.toLowerCase().contains(query) ||
                 ride.route.destination.address.toLowerCase().contains(query);
        }).toList();

        return rides..sort((a, b) => 
            a.schedule.departureTime.compareTo(b.schedule.departureTime));
      });
    } catch (e) {
      throw Exception('Failed to search rides: $e');
    }
  }

  /// Get upcoming rides for a user (both as driver and passenger)
  Stream<List<Ride>> getUpcomingRidesStream(String userId) {
    try {
      final now = DateTime.now();
      
      return _firestore
          .collection(AppConstants.ridesCollection)
          .where('schedule.departureTime', isGreaterThan: Timestamp.fromDate(now))
          .snapshots()
          .map((snapshot) {
        final rides = snapshot.docs
            .map((doc) => Ride.fromSnapshot(doc))
            .where((ride) => 
                ride.driverId == userId || 
                ride.confirmedRiders.contains(userId))
            .toList();

        return rides..sort((a, b) => 
            a.schedule.departureTime.compareTo(b.schedule.departureTime));
      });
    } catch (e) {
      throw Exception('Failed to get upcoming rides: $e');
    }
  }
}