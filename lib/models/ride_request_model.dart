import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents passenger information (denormalized for read efficiency)
class PassengerInfo {
  final String name;

  const PassengerInfo({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      name: json['name'] as String,
    );
  }
}

/// Enum for ride request status
enum RideRequestStatus {
  pending,
  accepted,
  rejected;

  static RideRequestStatus fromString(String status) {
    return RideRequestStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => RideRequestStatus.pending,
    );
  }
}

/// Main RideRequest model representing a passenger's request to join a ride
class RideRequest {
  final String requestId;
  final String rideId;
  final String passengerId;
  final PassengerInfo passengerInfo;
  final RideRequestStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? message; // Optional message from passenger

  const RideRequest({
    required this.requestId,
    required this.rideId,
    required this.passengerId,
    required this.passengerInfo,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.message,
  });

  /// Convert RideRequest to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'rideId': rideId,
      'passengerId': passengerId,
      'passengerInfo': passengerInfo.toJson(),
      'status': status.name,
      'requestedAt': Timestamp.fromDate(requestedAt),
      if (respondedAt != null) 'respondedAt': Timestamp.fromDate(respondedAt!),
      if (message != null) 'message': message,
    };
  }

  /// Create RideRequest from Firestore JSON
  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      requestId: json['requestId'] as String,
      rideId: json['rideId'] as String,
      passengerId: json['passengerId'] as String,
      passengerInfo: PassengerInfo.fromJson(json['passengerInfo'] as Map<String, dynamic>),
      status: RideRequestStatus.fromString(json['status'] as String),
      requestedAt: (json['requestedAt'] as Timestamp).toDate(),
      respondedAt: json['respondedAt'] != null 
          ? (json['respondedAt'] as Timestamp).toDate() 
          : null,
      message: json['message'] as String?,
    );
  }

  /// Create RideRequest from Firestore DocumentSnapshot
  factory RideRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RideRequest.fromJson({
      ...data,
      'requestId': doc.id,
    });
  }

  /// Create a copy of the ride request with updated fields
  RideRequest copyWith({
    String? requestId,
    String? rideId,
    String? passengerId,
    PassengerInfo? passengerInfo,
    RideRequestStatus? status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return RideRequest(
      requestId: requestId ?? this.requestId,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      passengerInfo: passengerInfo ?? this.passengerInfo,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }

  /// Check if the request is pending
  bool get isPending => status == RideRequestStatus.pending;

  /// Check if the request is accepted
  bool get isAccepted => status == RideRequestStatus.accepted;

  /// Check if the request is rejected
  bool get isRejected => status == RideRequestStatus.rejected;

  /// Check if the request has been responded to
  bool get hasBeenResponded => status != RideRequestStatus.pending;

  /// Get time since request was made
  Duration get timeSinceRequest => DateTime.now().difference(requestedAt);

  /// Get formatted request time
  String get formattedRequestTime {
    final now = DateTime.now();
    final duration = now.difference(requestedAt);
    
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case RideRequestStatus.pending:
        return 'Pending';
      case RideRequestStatus.accepted:
        return 'Accepted';
      case RideRequestStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideRequest && 
      runtimeType == other.runtimeType && 
      requestId == other.requestId;

  @override
  int get hashCode => requestId.hashCode;

  @override
  String toString() => 'RideRequest(requestId: $requestId, status: $status, passenger: ${passengerInfo.name})';
}

/// Request model for creating a new ride request
class CreateRideRequestData {
  final String rideId;
  final String passengerId;
  final String passengerName;
  final String? message;

  const CreateRideRequestData({
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
    this.message,
  });

  /// Convert to RideRequest model
  RideRequest toRideRequest(String requestId) {
    return RideRequest(
      requestId: requestId,
      rideId: rideId,
      passengerId: passengerId,
      passengerInfo: PassengerInfo(name: passengerName),
      status: RideRequestStatus.pending,
      requestedAt: DateTime.now(),
      message: message,
    );
  }
}

/// Model for ride request filters
class RideRequestFilters {
  final RideRequestStatus? status;
  final String? rideId;
  final String? passengerId;
  final DateTime? fromDate;
  final DateTime? toDate;

  const RideRequestFilters({
    this.status,
    this.rideId,
    this.passengerId,
    this.fromDate,
    this.toDate,
  });

  /// Create a copy with updated filters
  RideRequestFilters copyWith({
    RideRequestStatus? status,
    String? rideId,
    String? passengerId,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return RideRequestFilters(
      status: status ?? this.status,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  /// Check if any filters are applied
  bool get hasFilters => 
      status != null || 
      rideId != null || 
      passengerId != null || 
      fromDate != null || 
      toDate != null;
}

/// Response model for ride request responses
class RideRequestResponse {
  final String requestId;
  final bool accepted;
  final String? responseMessage;

  const RideRequestResponse({
    required this.requestId,
    required this.accepted,
    this.responseMessage,
  });
}