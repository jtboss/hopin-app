import 'package:cloud_firestore/cloud_firestore.dart';

/// Passenger information for ride requests
class PassengerInfo {
  final String id;
  final String name;
  final double rating;
  final bool isVerified;
  final String? profileImageUrl;

  const PassengerInfo({
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

  factory PassengerInfo.fromMap(Map<String, dynamic> map) {
    return PassengerInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      isVerified: map['isVerified'] ?? false,
      profileImageUrl: map['profileImageUrl'],
    );
  }
}

/// Ride request status enumeration
enum RideRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled;

  String get displayName {
    switch (this) {
      case RideRequestStatus.pending:
        return 'Pending';
      case RideRequestStatus.accepted:
        return 'Accepted';
      case RideRequestStatus.rejected:
        return 'Rejected';
      case RideRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPending => this == RideRequestStatus.pending;
  bool get isAccepted => this == RideRequestStatus.accepted;
  bool get isRejected => this == RideRequestStatus.rejected;
  bool get isCancelled => this == RideRequestStatus.cancelled;
  bool get isResolved => isAccepted || isRejected;
}

/// Ride request model for passenger requests to join rides
class RideRequest {
  final String requestId;
  final String rideId;
  final String passengerId;
  final PassengerInfo passengerInfo;
  final RideRequestStatus status;
  final int seatsRequested;
  final String? message;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? rejectionReason;

  const RideRequest({
    required this.requestId,
    required this.rideId,
    required this.passengerId,
    required this.passengerInfo,
    required this.status,
    this.seatsRequested = 1,
    this.message,
    required this.requestedAt,
    this.respondedAt,
    this.rejectionReason,
  });

  /// Check if the request is still actionable
  bool get isActionable => status == RideRequestStatus.pending;

  /// Get response time if responded
  Duration? get responseTime => 
      respondedAt != null ? respondedAt!.difference(requestedAt) : null;

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'rideId': rideId,
      'passengerId': passengerId,
      'passengerInfo': passengerInfo.toMap(),
      'status': status.name,
      'seatsRequested': seatsRequested,
      'message': message,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'rejectionReason': rejectionReason,
    };
  }

  factory RideRequest.fromMap(Map<String, dynamic> map) {
    return RideRequest(
      requestId: map['requestId'] ?? '',
      rideId: map['rideId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      passengerInfo: PassengerInfo.fromMap(map['passengerInfo']),
      status: RideRequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RideRequestStatus.pending,
      ),
      seatsRequested: map['seatsRequested'] ?? 1,
      message: map['message'],
      requestedAt: (map['requestedAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null 
          ? (map['respondedAt'] as Timestamp).toDate() 
          : null,
      rejectionReason: map['rejectionReason'],
    );
  }

  factory RideRequest.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return RideRequest.fromMap({...data, 'requestId': snapshot.id});
  }

  /// Create a copy of the request with updated fields
  RideRequest copyWith({
    String? requestId,
    String? rideId,
    String? passengerId,
    PassengerInfo? passengerInfo,
    RideRequestStatus? status,
    int? seatsRequested,
    String? message,
    DateTime? requestedAt,
    DateTime? respondedAt,
    String? rejectionReason,
  }) {
    return RideRequest(
      requestId: requestId ?? this.requestId,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      passengerInfo: passengerInfo ?? this.passengerInfo,
      status: status ?? this.status,
      seatsRequested: seatsRequested ?? this.seatsRequested,
      message: message ?? this.message,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// Create ride request data transfer object
class CreateRideRequest {
  final String rideId;
  final int seatsRequested;
  final String? message;

  const CreateRideRequest({
    required this.rideId,
    this.seatsRequested = 1,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'seatsRequested': seatsRequested,
      'message': message,
    };
  }
}

/// Respond to ride request data transfer object
class RespondToRideRequest {
  final String requestId;
  final bool isAccepted;
  final String? rejectionReason;

  const RespondToRideRequest({
    required this.requestId,
    required this.isAccepted,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'isAccepted': isAccepted,
      'rejectionReason': rejectionReason,
    };
  }
}