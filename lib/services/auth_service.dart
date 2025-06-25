import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../constants/app_constants.dart';
import '../utils/validators.dart';
import 'analytics_service.dart';

/// Authentication service following layered architecture
/// Handles all authentication-related business logic
class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analytics = AnalyticsService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize auth service and check current user state
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _loadUserProfile(user.uid);
      }
    } catch (e) {
      _setError('Failed to initialize authentication');
      debugPrint('Auth initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new student user with email and password
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String studentNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate inputs
      final validationError = _validateRegistrationInputs(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        studentNumber: studentNumber,
      );

      if (validationError != null) {
        _setError(validationError);
        return null;
      }

      // Create Firebase Auth user
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user == null) {
        _setError('Failed to create user account');
        return null;
      }

      // Create user profile in Firestore
      final userModel = UserModel(
        userId: credential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        studentNumber: studentNumber,
        verificationStatus: VerificationStatus.initial(),
        roles: [UserRole.rider], // Default to rider role
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        preferences: UserPreferences.defaultPreferences(),
      );

      await _saveUserProfile(userModel);

      // Send email verification
      await credential.user!.sendEmailVerification();

      _currentUser = userModel;
      
      // Track registration event
      await _analytics.trackUserRegistered(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      return null;
    } catch (e) {
      _setError(AppConstants.genericErrorMessage);
      debugPrint('Registration error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in existing user with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate inputs
      if (!Validators.isValidStudentEmail(email)) {
        _setError(AppConstants.invalidEmailMessage);
        return null;
      }

      if (password.length < AppConstants.minPasswordLength) {
        _setError(AppConstants.passwordTooShortMessage);
        return null;
      }

      // Sign in with Firebase
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (credential.user == null) {
        _setError('Failed to sign in');
        return null;
      }

      // Load user profile
      await _loadUserProfile(credential.user!.uid);

      if (_currentUser != null) {
        // Update last active timestamp
        await _updateLastActiveTimestamp();
        
        // Track login event
        await _analytics.trackUserLogin(_currentUser!);
      }

      return _currentUser;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      return null;
    } catch (e) {
      _setError(AppConstants.genericErrorMessage);
      debugPrint('Sign in error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Send email verification to current user
  Future<bool> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to send email verification');
      debugPrint('Email verification error: $e');
      return false;
    }
  }

  /// Check if email is verified and update user status
  Future<bool> checkEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified && _currentUser != null) {
          // Update verification status in Firestore
          final updatedStatus = _currentUser!.verificationStatus.copyWith(
            email: true,
          );
          
          final updatedUser = _currentUser!.copyWith(
            verificationStatus: updatedStatus,
          );
          
          await _saveUserProfile(updatedUser);
          _currentUser = updatedUser;
          notifyListeners();
          
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Check email verification error: $e');
      return false;
    }
  }

  /// Send phone verification code
  Future<void> sendPhoneVerification({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          await _verifyPhoneWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(_handleAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      verificationFailed('Failed to send verification code');
      debugPrint('Phone verification error: $e');
    }
  }

  /// Verify phone number with SMS code
  Future<bool> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      return await _verifyPhoneWithCredential(credential);
    } catch (e) {
      _setError('Invalid verification code');
      debugPrint('Phone code verification error: $e');
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userTokenKey);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
      debugPrint('Sign out error: $e');
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updatedUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        lastActive: DateTime.now(),
      );

      await _saveUserProfile(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to update profile');
      debugPrint('Profile update error: $e');
      return false;
    }
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load user profile error: $e');
      throw Exception('Failed to load user profile');
    }
  }

  /// Save user profile to Firestore
  Future<void> _saveUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.userId)
          .set(user.toFirestore());
    } catch (e) {
      debugPrint('Save user profile error: $e');
      throw Exception('Failed to save user profile');
    }
  }

  /// Update last active timestamp
  Future<void> _updateLastActiveTimestamp() async {
    if (_currentUser == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_currentUser!.userId)
          .update({'lastActive': Timestamp.now()});
    } catch (e) {
      debugPrint('Update last active error: $e');
    }
  }

  /// Verify phone credential and update user status
  Future<bool> _verifyPhoneWithCredential(PhoneAuthCredential credential) async {
    try {
      if (_currentUser != null) {
        // Update verification status
        final updatedStatus = _currentUser!.verificationStatus.copyWith(
          phone: true,
        );
        
        final updatedUser = _currentUser!.copyWith(
          verificationStatus: updatedStatus,
        );
        
        await _saveUserProfile(updatedUser);
        _currentUser = updatedUser;
        notifyListeners();
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Phone credential verification error: $e');
      return false;
    }
  }

  /// Validate registration inputs
  String? _validateRegistrationInputs({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String studentNumber,
  }) {
    if (!Validators.isValidStudentEmail(email)) {
      return AppConstants.invalidEmailMessage;
    }

    if (password.length < AppConstants.minPasswordLength) {
      return AppConstants.passwordTooShortMessage;
    }

    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return 'Please enter your full name';
    }

    if (!Validators.isValidPhoneNumber(phoneNumber)) {
      return AppConstants.invalidPhoneMessage;
    }

    if (!Validators.isValidStudentNumber(studentNumber)) {
      return AppConstants.invalidStudentNumberMessage;
    }

    return null;
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return e.message ?? AppConstants.genericErrorMessage;
    }
  }
}