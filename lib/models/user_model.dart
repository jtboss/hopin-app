import 'package:cloud_firestore/cloud_firestore.dart';

/// User verification status
enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected;

  String get displayName {
    switch (this) {
      case VerificationStatus.unverified:
        return 'Unverified';
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isVerified => this == VerificationStatus.verified;
  bool get canRequestRides => this != VerificationStatus.rejected;
}

/// User preferences for ride-sharing
class UserPreferences {
  final bool allowSmoking;
  final bool allowPets;
  final bool preferQuietRides;
  final bool receiveNotifications;
  final bool shareContactInfo;

  const UserPreferences({
    this.allowSmoking = false,
    this.allowPets = false,
    this.preferQuietRides = false,
    this.receiveNotifications = true,
    this.shareContactInfo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'allowSmoking': allowSmoking,
      'allowPets': allowPets,
      'preferQuietRides': preferQuietRides,
      'receiveNotifications': receiveNotifications,
      'shareContactInfo': shareContactInfo,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      allowSmoking: map['allowSmoking'] ?? false,
      allowPets: map['allowPets'] ?? false,
      preferQuietRides: map['preferQuietRides'] ?? false,
      receiveNotifications: map['receiveNotifications'] ?? true,
      shareContactInfo: map['shareContactInfo'] ?? true,
    );
  }
}

/// User statistics for rides
class UserStats {
  final int ridesOffered;
  final int ridesTaken;
  final int completedRides;
  final int cancelledRides;
  final double totalEarnings;
  final double totalSpent;

  const UserStats({
    this.ridesOffered = 0,
    this.ridesTaken = 0,
    this.completedRides = 0,
    this.cancelledRides = 0,
    this.totalEarnings = 0.0,
    this.totalSpent = 0.0,
  });

  double get completionRate => 
      (ridesOffered + ridesTaken) > 0 
          ? completedRides / (ridesOffered + ridesTaken)
          : 0.0;

  double get cancellationRate => 
      (ridesOffered + ridesTaken) > 0 
          ? cancelledRides / (ridesOffered + ridesTaken)
          : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'ridesOffered': ridesOffered,
      'ridesTaken': ridesTaken,
      'completedRides': completedRides,
      'cancelledRides': cancelledRides,
      'totalEarnings': totalEarnings,
      'totalSpent': totalSpent,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      ridesOffered: map['ridesOffered'] ?? 0,
      ridesTaken: map['ridesTaken'] ?? 0,
      completedRides: map['completedRides'] ?? 0,
      cancelledRides: map['cancelledRides'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
    );
  }
}

/// Main user model for Hopin app
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String studentNumber;
  final VerificationStatus verificationStatus;
  final double driverRating;
  final double passengerRating;
  final int totalRatings;
  final String? profileImageUrl;
  final UserPreferences preferences;
  final UserStats stats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.studentNumber,
    this.verificationStatus = VerificationStatus.unverified,
    this.driverRating = 0.0,
    this.passengerRating = 0.0,
    this.totalRatings = 0,
    this.profileImageUrl,
    this.preferences = const UserPreferences(),
    this.stats = const UserStats(),
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get display name (first name + last initial)
  String get displayName => '$firstName ${lastName[0]}.';

  /// Check if user is verified student
  bool get isVerifiedStudent => verificationStatus.isVerified;

  /// Check if user can offer rides
  bool get canOfferRides => 
      isVerifiedStudent && 
      driverRating >= 3.0 && 
      stats.cancellationRate < 0.3;

  /// Check if user can request rides
  bool get canRequestRides => verificationStatus.canRequestRides;

  /// Get overall rating (average of driver and passenger ratings)
  double get overallRating => 
      totalRatings > 0 
          ? (driverRating + passengerRating) / 2
          : 0.0;

  /// Check if user is online (active within last 5 minutes)
  bool get isOnline => 
      lastActiveAt != null &&
      DateTime.now().difference(lastActiveAt!).inMinutes < 5;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'studentNumber': studentNumber,
      'verificationStatus': verificationStatus.name,
      'driverRating': driverRating,
      'passengerRating': passengerRating,
      'totalRatings': totalRatings,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences.toMap(),
      'stats': stats.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActiveAt': lastActiveAt != null 
          ? Timestamp.fromDate(lastActiveAt!) 
          : null,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'],
      studentNumber: map['studentNumber'] ?? '',
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == map['verificationStatus'],
        orElse: () => VerificationStatus.unverified,
      ),
      driverRating: (map['driverRating'] ?? 0.0).toDouble(),
      passengerRating: (map['passengerRating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      profileImageUrl: map['profileImageUrl'],
      preferences: map['preferences'] != null 
          ? UserPreferences.fromMap(map['preferences'])
          : const UserPreferences(),
      stats: map['stats'] != null 
          ? UserStats.fromMap(map['stats'])
          : const UserStats(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      lastActiveAt: map['lastActiveAt'] != null 
          ? (map['lastActiveAt'] as Timestamp).toDate() 
          : null,
    );
  }

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User.fromMap({...data, 'id': snapshot.id});
  }

  /// Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? studentNumber,
    VerificationStatus? verificationStatus,
    double? driverRating,
    double? passengerRating,
    int? totalRatings,
    String? profileImageUrl,
    UserPreferences? preferences,
    UserStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentNumber: studentNumber ?? this.studentNumber,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      driverRating: driverRating ?? this.driverRating,
      passengerRating: passengerRating ?? this.passengerRating,
      totalRatings: totalRatings ?? this.totalRatings,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}