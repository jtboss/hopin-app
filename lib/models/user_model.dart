import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for the Hopin ride-sharing app
class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? studentNumber;
  final String university;
  final String? profileImageUrl;
  final VerificationStatus verificationStatus;
  final UserPreferences preferences;
  final List<UserRole> roles;
  final double rating;
  final int totalRides;
  final DateTime createdAt;
  final DateTime lastActive;
  final String? emergencyContact;
  final CarDetails? carDetails;

  const UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.studentNumber,
    required this.university,
    this.profileImageUrl,
    required this.verificationStatus,
    required this.preferences,
    required this.roles,
    this.rating = 0.0,
    this.totalRides = 0,
    required this.createdAt,
    required this.lastActive,
    this.emergencyContact,
    this.carDetails,
  });

  /// Creates a copy of this user with the given fields replaced
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? studentNumber,
    String? university,
    String? profileImageUrl,
    VerificationStatus? verificationStatus,
    UserPreferences? preferences,
    List<UserRole>? roles,
    double? rating,
    int? totalRides,
    DateTime? createdAt,
    DateTime? lastActive,
    String? emergencyContact,
    CarDetails? carDetails,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentNumber: studentNumber ?? this.studentNumber,
      university: university ?? this.university,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      preferences: preferences ?? this.preferences,
      roles: roles ?? this.roles,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      carDetails: carDetails ?? this.carDetails,
    );
  }

  /// Converts the model to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'studentNumber': studentNumber,
      'university': university,
      'profileImageUrl': profileImageUrl,
      'verificationStatus': verificationStatus.toJson(),
      'preferences': preferences.toJson(),
      'roles': roles.map((r) => r.name).toList(),
      'rating': rating,
      'totalRides': totalRides,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'emergencyContact': emergencyContact,
      'carDetails': carDetails?.toJson(),
    };
  }

  /// Creates a UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      studentNumber: json['studentNumber'],
      university: json['university'] ?? 'stellenbosch',
      profileImageUrl: json['profileImageUrl'],
      verificationStatus: VerificationStatus.fromJson(json['verificationStatus'] ?? {}),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      roles: (json['roles'] as List<dynamic>? ?? ['rider'])
          .map((r) => UserRole.values.firstWhere(
                (e) => e.name == r,
                orElse: () => UserRole.rider,
              ))
          .toList(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRides: json['totalRides'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastActive: (json['lastActive'] as Timestamp).toDate(),
      emergencyContact: json['emergencyContact'],
      carDetails: json['carDetails'] != null ? CarDetails.fromJson(json['carDetails']) : null,
    );
  }

  /// Creates a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['uid'] = doc.id;
    return UserModel.fromJson(data);
  }

  /// Get user's full name
  String get fullName => '$firstName $lastName';

  /// Check if user is verified
  bool get isVerified => verificationStatus.isFullyVerified;

  /// Check if user can drive
  bool get canDrive => roles.contains(UserRole.driver) && carDetails != null;

  /// Get user's display rating
  String get displayRating => rating > 0 ? rating.toStringAsFixed(1) : 'New';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $fullName, email: $email, verified: $isVerified)';
  }
}

/// User roles in the app
enum UserRole {
  rider,   // Can request rides
  driver,  // Can offer rides
  admin,   // Administrative access
}

/// User verification status
class VerificationStatus {
  final bool emailVerified;
  final bool phoneVerified;
  final bool studentIdVerified;
  final bool driverLicenseVerified;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final DateTime? studentIdVerifiedAt;
  final DateTime? driverLicenseVerifiedAt;

  const VerificationStatus({
    this.emailVerified = false,
    this.phoneVerified = false,
    this.studentIdVerified = false,
    this.driverLicenseVerified = false,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.studentIdVerifiedAt,
    this.driverLicenseVerifiedAt,
  });

  /// Check if user is fully verified (email, phone, student ID)
  bool get isFullyVerified => emailVerified && phoneVerified && studentIdVerified;

  /// Check if user can drive (includes driver license verification)
  bool get canDrive => isFullyVerified && driverLicenseVerified;

  Map<String, dynamic> toJson() {
    return {
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'studentIdVerified': studentIdVerified,
      'driverLicenseVerified': driverLicenseVerified,
      'emailVerifiedAt': emailVerifiedAt != null ? Timestamp.fromDate(emailVerifiedAt!) : null,
      'phoneVerifiedAt': phoneVerifiedAt != null ? Timestamp.fromDate(phoneVerifiedAt!) : null,
      'studentIdVerifiedAt': studentIdVerifiedAt != null ? Timestamp.fromDate(studentIdVerifiedAt!) : null,
      'driverLicenseVerifiedAt': driverLicenseVerifiedAt != null ? Timestamp.fromDate(driverLicenseVerifiedAt!) : null,
    };
  }

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      studentIdVerified: json['studentIdVerified'] ?? false,
      driverLicenseVerified: json['driverLicenseVerified'] ?? false,
      emailVerifiedAt: json['emailVerifiedAt'] != null ? (json['emailVerifiedAt'] as Timestamp).toDate() : null,
      phoneVerifiedAt: json['phoneVerifiedAt'] != null ? (json['phoneVerifiedAt'] as Timestamp).toDate() : null,
      studentIdVerifiedAt: json['studentIdVerifiedAt'] != null ? (json['studentIdVerifiedAt'] as Timestamp).toDate() : null,
      driverLicenseVerifiedAt: json['driverLicenseVerifiedAt'] != null ? (json['driverLicenseVerifiedAt'] as Timestamp).toDate() : null,
    );
  }

  VerificationStatus copyWith({
    bool? emailVerified,
    bool? phoneVerified,
    bool? studentIdVerified,
    bool? driverLicenseVerified,
    DateTime? emailVerifiedAt,
    DateTime? phoneVerifiedAt,
    DateTime? studentIdVerifiedAt,
    DateTime? driverLicenseVerifiedAt,
  }) {
    return VerificationStatus(
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      studentIdVerified: studentIdVerified ?? this.studentIdVerified,
      driverLicenseVerified: driverLicenseVerified ?? this.driverLicenseVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      studentIdVerifiedAt: studentIdVerifiedAt ?? this.studentIdVerifiedAt,
      driverLicenseVerifiedAt: driverLicenseVerifiedAt ?? this.driverLicenseVerifiedAt,
    );
  }
}

/// User preferences and settings
class UserPreferences {
  final bool allowNotifications;
  final bool shareLocation;
  final bool allowMessages;
  final bool autoAcceptRides;
  final String preferredLanguage;
  final bool darkMode;
  final double maxPrice;
  final int maxDistance;

  const UserPreferences({
    this.allowNotifications = true,
    this.shareLocation = true,
    this.allowMessages = true,
    this.autoAcceptRides = false,
    this.preferredLanguage = 'en',
    this.darkMode = false,
    this.maxPrice = 50.0,
    this.maxDistance = 25,
  });

  Map<String, dynamic> toJson() {
    return {
      'allowNotifications': allowNotifications,
      'shareLocation': shareLocation,
      'allowMessages': allowMessages,
      'autoAcceptRides': autoAcceptRides,
      'preferredLanguage': preferredLanguage,
      'darkMode': darkMode,
      'maxPrice': maxPrice,
      'maxDistance': maxDistance,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      allowNotifications: json['allowNotifications'] ?? true,
      shareLocation: json['shareLocation'] ?? true,
      allowMessages: json['allowMessages'] ?? true,
      autoAcceptRides: json['autoAcceptRides'] ?? false,
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      darkMode: json['darkMode'] ?? false,
      maxPrice: (json['maxPrice'] ?? 50.0).toDouble(),
      maxDistance: json['maxDistance'] ?? 25,
    );
  }

  UserPreferences copyWith({
    bool? allowNotifications,
    bool? shareLocation,
    bool? allowMessages,
    bool? autoAcceptRides,
    String? preferredLanguage,
    bool? darkMode,
    double? maxPrice,
    int? maxDistance,
  }) {
    return UserPreferences(
      allowNotifications: allowNotifications ?? this.allowNotifications,
      shareLocation: shareLocation ?? this.shareLocation,
      allowMessages: allowMessages ?? this.allowMessages,
      autoAcceptRides: autoAcceptRides ?? this.autoAcceptRides,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      darkMode: darkMode ?? this.darkMode,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }
}

/// Car details for drivers
class CarDetails {
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final int seats;
  final String? imageUrl;

  const CarDetails({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.seats,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'seats': seats,
      'imageUrl': imageUrl,
    };
  }

  factory CarDetails.fromJson(Map<String, dynamic> json) {
    return CarDetails(
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      color: json['color'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      seats: json['seats'] ?? 4,
      imageUrl: json['imageUrl'],
    );
  }

  CarDetails copyWith({
    String? make,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    int? seats,
    String? imageUrl,
  }) {
    return CarDetails(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      seats: seats ?? this.seats,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Get car display name
  String get displayName => '$year $make $model';

  @override
  String toString() => 'CarDetails(make: $make, model: $model, year: $year, seats: $seats)';
}