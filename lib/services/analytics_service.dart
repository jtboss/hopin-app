import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../constants/app_constants.dart';

/// Analytics service for tracking user events and app usage
/// Follows privacy-first approach and tracks only necessary metrics
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Track app open event
  Future<void> trackAppOpen() async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      debugPrint('Analytics error - App Open: $e');
    }
  }

  /// Track user registration event
  Future<void> trackUserRegistered(UserModel user) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logSignUp(signUpMethod: 'email');
      
      // Set user properties
      await _analytics.setUserId(id: user.userId);
      await _analytics.setUserProperty(
        name: 'university',
        value: AppConstants.universityCode,
      );
      await _analytics.setUserProperty(
        name: 'user_type',
        value: 'student',
      );
      
      // Track custom registration event
      await _analytics.logEvent(
        name: 'student_registered',
        parameters: {
          'registration_method': 'email',
          'university': AppConstants.universityCode,
          'has_phone': user.phoneNumber.isNotEmpty,
          'has_student_number': user.studentNumber?.isNotEmpty ?? false,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - User Registered: $e');
    }
  }

  /// Track user login event
  Future<void> trackUserLogin(UserModel user) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logLogin(loginMethod: 'email');
      
      // Update user ID if not set
      await _analytics.setUserId(id: user.userId);
      
      // Track custom login event
      await _analytics.logEvent(
        name: 'student_login',
        parameters: {
          'login_method': 'email',
          'is_verified': user.isFullyVerified,
          'verification_email': user.verificationStatus.email,
          'verification_phone': user.verificationStatus.phone,
          'verification_student_id': user.verificationStatus.studentId,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - User Login: $e');
    }
  }

  /// Track email verification event
  Future<void> trackEmailVerified(String userId) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'email_verified',
        parameters: {
          'user_id': userId,
          'verification_type': 'email',
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Email Verified: $e');
    }
  }

  /// Track phone verification event
  Future<void> trackPhoneVerified(String userId) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'phone_verified',
        parameters: {
          'user_id': userId,
          'verification_type': 'phone',
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Phone Verified: $e');
    }
  }

  /// Track onboarding completion
  Future<void> trackOnboardingCompleted(String userId) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'onboarding_completed',
        parameters: {
          'user_id': userId,
          'completion_time': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Onboarding Completed: $e');
    }
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName, String? screenClass) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('Analytics error - Screen View: $e');
    }
  }

  /// Track authentication error
  Future<void> trackAuthError(String errorType, String errorMessage) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'auth_error',
        parameters: {
          'error_type': errorType,
          'error_code': errorMessage.substring(0, 50), // Limit length
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Auth Error: $e');
    }
  }

  /// Track button click
  Future<void> trackButtonClick(String buttonName, String screenName) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'button_click',
        parameters: {
          'button_name': buttonName,
          'screen_name': screenName,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Button Click: $e');
    }
  }

  /// Track form submission
  Future<void> trackFormSubmission(String formName, bool isSuccessful) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'form_submission',
        parameters: {
          'form_name': formName,
          'success': isSuccessful,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Form Submission: $e');
    }
  }

  /// Track user session duration
  Future<void> trackSessionEnd(int sessionDurationMinutes) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'session_end',
        parameters: {
          'session_duration_minutes': sessionDurationMinutes,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Session End: $e');
    }
  }

  /// Track feature usage
  Future<void> trackFeatureUsed(String featureName, Map<String, Object>? parameters) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'feature_used',
        parameters: {
          'feature_name': featureName,
          ...?parameters,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Feature Used: $e');
    }
  }

  /// Track search query
  Future<void> trackSearch(String searchTerm, String searchType) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        parameters: {
          'search_type': searchType,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Search: $e');
    }
  }

  /// Track app performance metrics
  Future<void> trackPerformanceMetric(String metricName, double value) async {
    if (!AppConstants.enablePerformanceMonitoring) return;
    
    try {
      await _analytics.logEvent(
        name: 'performance_metric',
        parameters: {
          'metric_name': metricName,
          'value': value,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Performance Metric: $e');
    }
  }

  /// Track user retention event
  Future<void> trackUserRetention(String userId, int daysSinceFirstOpen) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'user_retention',
        parameters: {
          'user_id': userId,
          'days_since_first_open': daysSinceFirstOpen,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - User Retention: $e');
    }
  }

  /// Set user properties for segmentation
  Future<void> setUserProperties(UserModel user) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.setUserId(id: user.userId);
      
      await _analytics.setUserProperty(
        name: 'university',
        value: AppConstants.universityCode,
      );
      
      await _analytics.setUserProperty(
        name: 'user_type',
        value: 'student',
      );
      
      await _analytics.setUserProperty(
        name: 'is_verified',
        value: user.isFullyVerified.toString(),
      );
      
      await _analytics.setUserProperty(
        name: 'user_roles',
        value: user.roles.map((r) => r.toString()).join(','),
      );
      
    } catch (e) {
      debugPrint('Analytics error - Set User Properties: $e');
    }
  }

  /// Track critical errors for debugging
  Future<void> trackCriticalError(String errorType, String errorMessage, String? stackTrace) async {
    if (!AppConstants.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: 'critical_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage.substring(0, 100), // Limit length
          'has_stack_trace': stackTrace != null,
        },
      );
    } catch (e) {
      debugPrint('Analytics error - Critical Error: $e');
    }
  }
}