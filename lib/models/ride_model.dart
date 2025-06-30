import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// Core ride data structure for the Hopin ride-sharing app
class RideModel {
  final String rideId;
  final String driverId;
  final UserModel driver;
  final RouteInfo route;
  final DateTime departureTime;
  final int availableSeats;
  final int totalSeats;
  final double pricePerSeat;
  final RideStatus status;
  final List<String> passengerIds;
  final List<RideRequestModel> requests;
  final DateTime createdAt;
  final RidePreferences preferences;
  final String? notes;

  const RideModel({
    required this.rideId,
    required this.driverId,
    required this.driver,
    required this.route,
    required this.departureTime,
    required this.availableSeats,
    required this.totalSeats,
    required this.pricePerSeat,
    required this.status,
    required this.passengerIds,
    required this.requests,
    required this.createdAt,
    required this.preferences,
    this.notes,
  });

  /// Creates a copy of this ride with the given fields replaced
  RideModel copyWith({
    String? rideId,
    String? driverId,
    UserModel? driver,
    RouteInfo? route,
    DateTime? departureTime,
    int? availableSeats,
    int? totalSeats,
    double? pricePerSeat,
    RideStatus? status,
    List<String>? passengerIds,
    List<RideRequestModel>? requests,
    DateTime? createdAt,
    RidePreferences? preferences,
    String? notes,
  }) {
    return RideModel(
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      driver: driver ?? this.driver,
      route: route ?? this.route,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      status: status ?? this.status,
      passengerIds: passengerIds ?? this.passengerIds,
      requests: requests ?? this.requests,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      notes: notes ?? this.notes,
    );
  }

  /// Converts the model to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'driver': driver.toJson(),
      'route': route.toJson(),
      'departureTime': Timestamp.fromDate(departureTime),
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'pricePerSeat': pricePerSeat,
      'status': status.name,
      'passengerIds': passengerIds,
      'requests': requests.map((r) => r.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': preferences.toJson(),
      'notes': notes,
    };
  }

  /// Creates a RideModel from JSON data
  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      rideId: json['rideId'] ?? '',
      driverId: json['driverId'] ?? '',
      driver: UserModel.fromJson(json['driver'] ?? {}),
      route: RouteInfo.fromJson(json['route'] ?? {}),
      departureTime: (json['departureTime'] as Timestamp).toDate(),
      availableSeats: json['availableSeats'] ?? 0,
      totalSeats: json['totalSeats'] ?? 0,
      pricePerSeat: (json['pricePerSeat'] ?? 0.0).toDouble(),
      status: RideStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RideStatus.active,
      ),
      passengerIds: List<String>.from(json['passengerIds'] ?? []),
      requests: (json['requests'] as List<dynamic>? ?? [])
          .map((r) => RideRequestModel.fromJson(r))
          .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      preferences: RidePreferences.fromJson(json['preferences'] ?? {}),
      notes: json['notes'],
    );
  }

  /// Creates a RideModel from a Firestore DocumentSnapshot
  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['rideId'] = doc.id;
    return RideModel.fromJson(data);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideModel && other.rideId == rideId;
  }

  @override
  int get hashCode => rideId.hashCode;

  @override
  String toString() {
    return 'RideModel(rideId: $rideId, route: ${route.pickup.address} → ${route.destination.address}, departureTime: $departureTime, status: $status)';
  }
}

/// Enum for ride status tracking
enum RideStatus {
  active,      // Available for booking
  full,        // All seats taken
  inProgress,  // Currently happening
  completed,   // Finished successfully
  cancelled,   // Cancelled by driver
}

/// Route information including pickup and destination
class RouteInfo {
  final LocationPoint pickup;
  final LocationPoint destination;
  final double estimatedDistance;
  final Duration estimatedDuration;
  final List<LocationPoint>? waypoints;

  const RouteInfo({
    required this.pickup,
    required this.destination,
    required this.estimatedDistance,
    required this.estimatedDuration,
    this.waypoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup.toJson(),
      'destination': destination.toJson(),
      'estimatedDistance': estimatedDistance,
      'estimatedDuration': estimatedDuration.inMinutes,
      'waypoints': waypoints?.map((w) => w.toJson()).toList(),
    };
  }

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      pickup: LocationPoint.fromJson(json['pickup'] ?? {}),
      destination: LocationPoint.fromJson(json['destination'] ?? {}),
      estimatedDistance: (json['estimatedDistance'] ?? 0.0).toDouble(),
      estimatedDuration: Duration(minutes: json['estimatedDuration'] ?? 0),
      waypoints: (json['waypoints'] as List<dynamic>? ?? [])
          .map((w) => LocationPoint.fromJson(w))
          .toList(),
    );
  }

  RouteInfo copyWith({
    LocationPoint? pickup,
    LocationPoint? destination,
    double? estimatedDistance,
    Duration? estimatedDuration,
    List<LocationPoint>? waypoints,
  }) {
    return RouteInfo(
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      waypoints: waypoints ?? this.waypoints,
    );
  }
}

/// Geographic location with address and metadata
class LocationPoint {
  final String address;
  final double latitude;
  final double longitude;
  final String? name;
  final LocationType type;

  const LocationPoint({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.name,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'type': type.name,
    };
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      name: json['name'],
      type: LocationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LocationType.other,
      ),
    );
  }

  LocationPoint copyWith({
    String? address,
    double? latitude,
    double? longitude,
    String? name,
    LocationType? type,
  }) {
    return LocationPoint(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationPoint &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'LocationPoint(address: $address, type: $type)';
}

/// Enum for location categorization
enum LocationType {
  campus,      // University locations
  residence,   // Student housing
  shopping,    // Malls, stores
  transport,   // Bus/taxi stations
  other,       // Custom locations
}

/// Ride preferences and settings
class RidePreferences {
  final bool allowSmoking;
  final String musicPreference;
  final bool petFriendly;
  final bool allowLuggage;
  final bool chatty;
  final bool quickStops;

  const RidePreferences({
    this.allowSmoking = false,
    this.musicPreference = 'any',
    this.petFriendly = false,
    this.allowLuggage = true,
    this.chatty = true,
    this.quickStops = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'allowSmoking': allowSmoking,
      'musicPreference': musicPreference,
      'petFriendly': petFriendly,
      'allowLuggage': allowLuggage,
      'chatty': chatty,
      'quickStops': quickStops,
    };
  }

  factory RidePreferences.fromJson(Map<String, dynamic> json) {
    return RidePreferences(
      allowSmoking: json['allowSmoking'] ?? false,
      musicPreference: json['musicPreference'] ?? 'any',
      petFriendly: json['petFriendly'] ?? false,
      allowLuggage: json['allowLuggage'] ?? true,
      chatty: json['chatty'] ?? true,
      quickStops: json['quickStops'] ?? false,
    );
  }

  RidePreferences copyWith({
    bool? allowSmoking,
    String? musicPreference,
    bool? petFriendly,
    bool? allowLuggage,
    bool? chatty,
    bool? quickStops,
  }) {
    return RidePreferences(
      allowSmoking: allowSmoking ?? this.allowSmoking,
      musicPreference: musicPreference ?? this.musicPreference,
      petFriendly: petFriendly ?? this.petFriendly,
      allowLuggage: allowLuggage ?? this.allowLuggage,
      chatty: chatty ?? this.chatty,
      quickStops: quickStops ?? this.quickStops,
    );
  }
}

/// Passenger ride request model
class RideRequestModel {
  final String requestId;
  final String rideId;
  final String passengerId;
  final UserModel passenger;
  final int seatsRequested;
  final RequestStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? message;
  final String? responseMessage;

  const RideRequestModel({
    required this.requestId,
    required this.rideId,
    required this.passengerId,
    required this.passenger,
    required this.seatsRequested,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.message,
    this.responseMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'rideId': rideId,
      'passengerId': passengerId,
      'passenger': passenger.toJson(),
      'seatsRequested': seatsRequested,
      'status': status.name,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'message': message,
      'responseMessage': responseMessage,
    };
  }

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    return RideRequestModel(
      requestId: json['requestId'] ?? '',
      rideId: json['rideId'] ?? '',
      passengerId: json['passengerId'] ?? '',
      passenger: UserModel.fromJson(json['passenger'] ?? {}),
      seatsRequested: json['seatsRequested'] ?? 1,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      requestedAt: (json['requestedAt'] as Timestamp).toDate(),
      respondedAt: json['respondedAt'] != null 
          ? (json['respondedAt'] as Timestamp).toDate() 
          : null,
      message: json['message'],
      responseMessage: json['responseMessage'],
    );
  }

  RideRequestModel copyWith({
    String? requestId,
    String? rideId,
    String? passengerId,
    UserModel? passenger,
    int? seatsRequested,
    RequestStatus? status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    String? message,
    String? responseMessage,
  }) {
    return RideRequestModel(
      requestId: requestId ?? this.requestId,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      passenger: passenger ?? this.passenger,
      seatsRequested: seatsRequested ?? this.seatsRequested,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
      responseMessage: responseMessage ?? this.responseMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideRequestModel && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;

  @override
  String toString() {
    return 'RideRequestModel(requestId: $requestId, status: $status, passengerId: $passengerId)';
  }
}

/// Enum for ride request status tracking
enum RequestStatus {
  pending,     // Waiting for driver response
  accepted,    // Driver approved
  rejected,    // Driver declined
  cancelled,   // Passenger cancelled
}