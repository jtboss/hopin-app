import 'package:cloud_firestore/cloud_firestore.dart';

/// Location data structure for ride routes
class Location {
  final String address;
  final GeoPoint coordinates;

  const Location({
    required this.address,
    required this.coordinates,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'coordinates': coordinates,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      address: map['address'] ?? '',
      coordinates: map['coordinates'] ?? const GeoPoint(0, 0),
    );
  }
}

/// Route information for a ride
class RideRoute {
  final Location origin;
  final Location destination;

  const RideRoute({
    required this.origin,
    required this.destination,
  });

  Map<String, dynamic> toMap() {
    return {
      'origin': origin.toMap(),
      'destination': destination.toMap(),
    };
  }

  factory RideRoute.fromMap(Map<String, dynamic> map) {
    return RideRoute(
      origin: Location.fromMap(map['origin']),
      destination: Location.fromMap(map['destination']),
    );
  }
}

/// Schedule information for a ride
class RideSchedule {
  final DateTime departureTime;
  final int estimatedDurationMinutes;

  const RideSchedule({
    required this.departureTime,
    required this.estimatedDurationMinutes,
  });

  DateTime get estimatedArrivalTime => 
      departureTime.add(Duration(minutes: estimatedDurationMinutes));

  Map<String, dynamic> toMap() {
    return {
      'departureTime': Timestamp.fromDate(departureTime),
      'estimatedDuration': estimatedDurationMinutes,
    };
  }

  factory RideSchedule.fromMap(Map<String, dynamic> map) {
    return RideSchedule(
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      estimatedDurationMinutes: map['estimatedDuration'] ?? 0,
    );
  }
}

/// Pricing information for a ride
class RidePricing {
  final double pricePerSeat;
  final String currency;

  const RidePricing({
    required this.pricePerSeat,
    this.currency = 'ZAR',
  });

  Map<String, dynamic> toMap() {
    return {
      'pricePerSeat': pricePerSeat,
      'currency': currency,
    };
  }

  factory RidePricing.fromMap(Map<String, dynamic> map) {
    return RidePricing(
      pricePerSeat: (map['pricePerSeat'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'ZAR',
    );
  }
}

/// Capacity information for a ride
class RideCapacity {
  final int totalSeats;
  final int availableSeats;

  const RideCapacity({
    required this.totalSeats,
    required this.availableSeats,
  });

  int get bookedSeats => totalSeats - availableSeats;
  bool get isFull => availableSeats <= 0;
  bool get hasAvailableSeats => availableSeats > 0;

  Map<String, dynamic> toMap() {
    return {
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
    };
  }

  factory RideCapacity.fromMap(Map<String, dynamic> map) {
    return RideCapacity(
      totalSeats: map['totalSeats'] ?? 0,
      availableSeats: map['availableSeats'] ?? 0,
    );
  }
}

/// Driver information for a ride
class DriverInfo {
  final String id;
  final String name;
  final double rating;
  final bool isVerified;
  final String? profileImageUrl;

  const DriverInfo({
    required this.id,
    required this.name,
    required this.rating,
    this.isVerified = false,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory DriverInfo.fromMap(Map<String, dynamic> map) {
    return DriverInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      isVerified: map['isVerified'] ?? false,
      profileImageUrl: map['profileImageUrl'],
    );
  }
}

/// Ride status enumeration
enum RideStatus {
  active,
  full,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case RideStatus.active:
        return 'Active';
      case RideStatus.full:
        return 'Full';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Main ride model
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
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if the ride is bookable
  bool get isBookable => 
      status == RideStatus.active && 
      capacity.hasAvailableSeats &&
      schedule.departureTime.isAfter(DateTime.now());

  /// Get total earnings for the driver
  double get totalEarnings => 
      pricing.pricePerSeat * capacity.bookedSeats;

  /// Get time until departure
  Duration get timeUntilDeparture => 
      schedule.departureTime.difference(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'driverInfo': driverInfo.toMap(),
      'route': route.toMap(),
      'schedule': schedule.toMap(),
      'pricing': pricing.toMap(),
      'capacity': capacity.toMap(),
      'status': status.name,
      'confirmedRiders': confirmedRiders,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      rideId: map['rideId'] ?? '',
      driverId: map['driverId'] ?? '',
      driverInfo: DriverInfo.fromMap(map['driverInfo']),
      route: RideRoute.fromMap(map['route']),
      schedule: RideSchedule.fromMap(map['schedule']),
      pricing: RidePricing.fromMap(map['pricing']),
      capacity: RideCapacity.fromMap(map['capacity']),
      status: RideStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RideStatus.active,
      ),
      confirmedRiders: List<String>.from(map['confirmedRiders'] ?? []),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory Ride.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Ride.fromMap({...data, 'rideId': snapshot.id});
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
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}