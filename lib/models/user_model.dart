import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// User model representing a student user in the Hopin app
/// Based on the MVP database schema from the development context
class UserModel extends Equatable {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? studentNumber;
  final String? profileImageUrl;
  final VerificationStatus verificationStatus;
  final List<UserRole> roles;
  final DateTime createdAt;
  final DateTime lastActive;
  final UserPreferences? preferences;

  const UserModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.studentNumber,
    this.profileImageUrl,
    required this.verificationStatus,
    required this.roles,
    required this.createdAt,
    required this.lastActive,
    this.preferences,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      studentNumber: data['studentNumber'],
      profileImageUrl: data['profileImageUrl'],
      verificationStatus: VerificationStatus.fromMap(
        data['verificationStatus'] ?? {},
      ),
      roles: (data['roles'] as List<dynamic>? ?? [])
          .map((role) => UserRole.fromString(role.toString()))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      preferences: data['preferences'] != null
          ? UserPreferences.fromMap(data['preferences'])
          : null,
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'studentNumber': studentNumber,
      'profileImageUrl': profileImageUrl,
      'verificationStatus': verificationStatus.toMap(),
      'roles': roles.map((role) => role.toString()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'preferences': preferences?.toMap(),
    };
  }

  /// Get user's full name
  String get fullName => '$firstName $lastName';

  /// Get user's display name (first name + last initial)
  String get displayName => firstName.isNotEmpty 
      ? '$firstName ${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}'
      : email.split('@')[0];

  /// Check if user is fully verified
  bool get isFullyVerified => 
      verificationStatus.email && 
      verificationStatus.phone && 
      verificationStatus.studentId;

  /// Check if user has driver role
  bool get isDriver => roles.contains(UserRole.driver);

  /// Check if user has rider role
  bool get isRider => roles.contains(UserRole.rider);

  /// Create a copy with updated fields
  UserModel copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? studentNumber,
    String? profileImageUrl,
    VerificationStatus? verificationStatus,
    List<UserRole>? roles,
    DateTime? createdAt,
    DateTime? lastActive,
    UserPreferences? preferences,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentNumber: studentNumber ?? this.studentNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        firstName,
        lastName,
        phoneNumber,
        studentNumber,
        profileImageUrl,
        verificationStatus,
        roles,
        createdAt,
        lastActive,
        preferences,
      ];
}

/// User verification status
class VerificationStatus extends Equatable {
  final bool email;
  final bool phone;
  final bool studentId;

  const VerificationStatus({
    required this.email,
    required this.phone,
    required this.studentId,
  });

  factory VerificationStatus.fromMap(Map<String, dynamic> map) {
    return VerificationStatus(
      email: map['email'] ?? false,
      phone: map['phone'] ?? false,
      studentId: map['studentId'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'studentId': studentId,
    };
  }

  /// Create initial verification status (all false)
  factory VerificationStatus.initial() {
    return const VerificationStatus(
      email: false,
      phone: false,
      studentId: false,
    );
  }

  /// Create a copy with updated fields
  VerificationStatus copyWith({
    bool? email,
    bool? phone,
    bool? studentId,
  }) {
    return VerificationStatus(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
    );
  }

  @override
  List<Object> get props => [email, phone, studentId];
}

/// User roles in the system
enum UserRole {
  rider,
  driver;

  /// Convert from string to UserRole
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'rider':
        return UserRole.rider;
      case 'driver':
        return UserRole.driver;
      default:
        return UserRole.rider; // Default to rider
    }
  }

  @override
  String toString() {
    return name;
  }
}

/// User preferences and settings
class UserPreferences extends Equatable {
  final bool notifications;
  final bool shareLocation;
  final bool emailNotifications;
  final bool pushNotifications;
  final String language;

  const UserPreferences({
    required this.notifications,
    required this.shareLocation,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.language,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notifications: map['notifications'] ?? true,
      shareLocation: map['shareLocation'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,
      language: map['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'shareLocation': shareLocation,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'language': language,
    };
  }

  /// Create default preferences
  factory UserPreferences.defaultPreferences() {
    return const UserPreferences(
      notifications: true,
      shareLocation: true,
      emailNotifications: true,
      pushNotifications: true,
      language: 'en',
    );
  }

  UserPreferences copyWith({
    bool? notifications,
    bool? shareLocation,
    bool? emailNotifications,
    bool? pushNotifications,
    String? language,
  }) {
    return UserPreferences(
      notifications: notifications ?? this.notifications,
      shareLocation: shareLocation ?? this.shareLocation,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      language: language ?? this.language,
    );
  }

  @override
  List<Object> get props => [
        notifications,
        shareLocation,
        emailNotifications,
        pushNotifications,
        language,
      ];
}