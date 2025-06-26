import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents location information for ride pickup/destination
class RideLocation {
  final String address;
  final GeoPoint coordinates;

  const RideLocation({
    required this.address,
    required this.coordinates,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates,
    };
  }

  factory RideLocation.fromJson(Map<String, dynamic> json) {
    return RideLocation(
      address: json['address'] as String,
      coordinates: json['coordinates'] as GeoPoint,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideLocation &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          coordinates == other.coordinates;

  @override
  int get hashCode => address.hashCode ^ coordinates.hashCode;
}

/// Represents route information for a ride
class RideRoute {
  final RideLocation origin;
  final RideLocation destination;

  const RideRoute({
    required this.origin,
    required this.destination,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin': origin.toJson(),
      'destination': destination.toJson(),
    };
  }

  factory RideRoute.fromJson(Map<String, dynamic> json) {
    return RideRoute(
      origin: RideLocation.fromJson(json['origin'] as Map<String, dynamic>),
      destination: RideLocation.fromJson(json['destination'] as Map<String, dynamic>),
    );
  }
}

/// Represents schedule information for a ride
class RideSchedule {
  final DateTime departureTime;
  final int estimatedDuration; // in minutes

  const RideSchedule({
    required this.departureTime,
    required this.estimatedDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'departureTime': Timestamp.fromDate(departureTime),
      'estimatedDuration': estimatedDuration,
    };
  }

  factory RideSchedule.fromJson(Map<String, dynamic> json) {
    return RideSchedule(
      departureTime: (json['departureTime'] as Timestamp).toDate(),
      estimatedDuration: json['estimatedDuration'] as int,
    );
  }
}

/// Represents pricing information for a ride
class RidePricing {
  final double pricePerSeat;
  final String currency;

  const RidePricing({
    required this.pricePerSeat,
    this.currency = 'ZAR',
  });

  Map<String, dynamic> toJson() {
    return {
      'pricePerSeat': pricePerSeat,
      'currency': currency,
    };
  }

  factory RidePricing.fromJson(Map<String, dynamic> json) {
    return RidePricing(
      pricePerSeat: (json['pricePerSeat'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ZAR',
    );
  }
}

/// Represents capacity information for a ride
class RideCapacity {
  final int totalSeats;
  final int availableSeats;

  const RideCapacity({
    required this.totalSeats,
    required this.availableSeats,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
    };
  }

  factory RideCapacity.fromJson(Map<String, dynamic> json) {
    return RideCapacity(
      totalSeats: json['totalSeats'] as int,
      availableSeats: json['availableSeats'] as int,
    );
  }

  /// Check if the ride has available seats
  bool get hasAvailableSeats => availableSeats > 0;

  /// Get the percentage of seats taken
  double get occupancyPercentage => 
      totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;
}

/// Represents driver information (denormalized for read efficiency)
class DriverInfo {
  final String name;
  final double rating;

  const DriverInfo({
    required this.name,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rating': rating,
    };
  }

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }
}

/// Enum for ride status
enum RideStatus {
  active,
  full,
  completed,
  cancelled;

  static RideStatus fromString(String status) {
    return RideStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => RideStatus.active,
    );
  }
}

/// Main Ride model representing a ride offer
class Ride {
  final String rideId;
  final String driverId;
  final DriverInfo driverInfo;
  final RideRoute route;
  final RideSchedule schedule;
  final RidePricing pricing;
  final RideCapacity capacity;
  final RideStatus status;
  final List<String> confirmedRiders;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? additionalNotes;

  const Ride({
    required this.rideId,
    required this.driverId,
    required this.driverInfo,
    required this.route,
    required this.schedule,
    required this.pricing,
    required this.capacity,
    required this.status,
    required this.confirmedRiders,
    required this.createdAt,
    required this.updatedAt,
    this.additionalNotes,
  });

  /// Convert Ride to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'driverInfo': driverInfo.toJson(),
      'route': route.toJson(),
      'schedule': schedule.toJson(),
      'pricing': pricing.toJson(),
      'capacity': capacity.toJson(),
      'status': status.name,
      'confirmedRiders': confirmedRiders,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (additionalNotes != null) 'additionalNotes': additionalNotes,
    };
  }

  /// Create Ride from Firestore JSON
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      rideId: json['rideId'] as String,
      driverId: json['driverId'] as String,
      driverInfo: DriverInfo.fromJson(json['driverInfo'] as Map<String, dynamic>),
      route: RideRoute.fromJson(json['route'] as Map<String, dynamic>),
      schedule: RideSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
      pricing: RidePricing.fromJson(json['pricing'] as Map<String, dynamic>),
      capacity: RideCapacity.fromJson(json['capacity'] as Map<String, dynamic>),
      status: RideStatus.fromString(json['status'] as String),
      confirmedRiders: List<String>.from(json['confirmedRiders'] as List),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      additionalNotes: json['additionalNotes'] as String?,
    );
  }

  /// Create Ride from Firestore DocumentSnapshot
  factory Ride.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ride.fromJson({
      ...data,
      'rideId': doc.id,
    });
  }

  /// Create a copy of the ride with updated fields
  Ride copyWith({
    String? rideId,
    String? driverId,
    DriverInfo? driverInfo,
    RideRoute? route,
    RideSchedule? schedule,
    RidePricing? pricing,
    RideCapacity? capacity,
    RideStatus? status,
    List<String>? confirmedRiders,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? additionalNotes,
  }) {
    return Ride(
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      driverInfo: driverInfo ?? this.driverInfo,
      route: route ?? this.route,
      schedule: schedule ?? this.schedule,
      pricing: pricing ?? this.pricing,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      confirmedRiders: confirmedRiders ?? this.confirmedRiders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  /// Check if the ride is available for booking
  bool get isAvailable => status == RideStatus.active && capacity.hasAvailableSeats;

  /// Check if the ride is in the future
  bool get isFuture => schedule.departureTime.isAfter(DateTime.now());

  /// Check if a user is confirmed for this ride
  bool isUserConfirmed(String userId) => confirmedRiders.contains(userId);

  /// Get formatted departure time
  String get formattedDepartureTime {
    final now = DateTime.now();
    final departure = schedule.departureTime;
    
    if (departure.day == now.day && departure.month == now.month && departure.year == now.year) {
      return 'Today ${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}';
    } else if (departure.day == now.day + 1 && departure.month == now.month && departure.year == now.year) {
      return 'Tomorrow ${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}';
    } else {
      return '${departure.day}/${departure.month} ${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Get estimated arrival time
  DateTime get estimatedArrivalTime => 
      schedule.departureTime.add(Duration(minutes: schedule.estimatedDuration));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ride && runtimeType == other.runtimeType && rideId == other.rideId;

  @override
  int get hashCode => rideId.hashCode;

  @override
  String toString() => 'Ride(rideId: $rideId, from: ${route.origin.address}, to: ${route.destination.address})';
}

/// Request model for creating a new ride
class CreateRideRequest {
  final String driverId;
  final String driverName;
  final double driverRating;
  final RideLocation origin;
  final RideLocation destination;
  final DateTime departureTime;
  final int estimatedDuration;
  final double pricePerSeat;
  final int totalSeats;
  final String? additionalNotes;

  const CreateRideRequest({
    required this.driverId,
    required this.driverName,
    required this.driverRating,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.estimatedDuration,
    required this.pricePerSeat,
    required this.totalSeats,
    this.additionalNotes,
  });

  /// Convert to Ride model
  Ride toRide(String rideId) {
    final now = DateTime.now();
    return Ride(
      rideId: rideId,
      driverId: driverId,
      driverInfo: DriverInfo(name: driverName, rating: driverRating),
      route: RideRoute(origin: origin, destination: destination),
      schedule: RideSchedule(departureTime: departureTime, estimatedDuration: estimatedDuration),
      pricing: RidePricing(pricePerSeat: pricePerSeat),
      capacity: RideCapacity(totalSeats: totalSeats, availableSeats: totalSeats),
      status: RideStatus.active,
      confirmedRiders: [],
      createdAt: now,
      updatedAt: now,
      additionalNotes: additionalNotes,
    );
  }
}