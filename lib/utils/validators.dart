import '../constants/app_constants.dart';

/// Utility class for input validation
/// Contains all validation logic for forms and user inputs
class Validators {
  /// Validate Stellenbosch University student email
  static bool isValidStudentEmail(String email) {
    if (email.isEmpty) return false;
    
    // Check if email ends with @sun.ac.za
    final regex = RegExp(AppConstants.emailValidationRegex);
    return regex.hasMatch(email.toLowerCase());
  }

  /// Validate South African phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;
    
    // Remove all spaces and special characters except +
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check for South African format: +27xxxxxxxxx
    final regex = RegExp(AppConstants.phoneValidationRegex);
    return regex.hasMatch(cleanedPhone);
  }

  /// Validate Stellenbosch student number (8 digits)
  static bool isValidStudentNumber(String studentNumber) {
    if (studentNumber.isEmpty) return false;
    
    // Remove any spaces or special characters
    final cleanedNumber = studentNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's exactly 8 digits
    final regex = RegExp(AppConstants.studentNumberRegex);
    return regex.hasMatch(cleanedNumber);
  }

  /// Validate password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < AppConstants.minPasswordLength) {
      return AppConstants.passwordTooShortMessage;
    }
    
    if (password.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }
    
    return null; // Valid password
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return AppConstants.passwordsDontMatchMessage;
    }
    
    return null; // Passwords match
  }

  /// Validate name fields (first name, last name)
  static String? validateName(String name, String fieldName) {
    if (name.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (name.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    if (name.length > AppConstants.maxNameLength) {
      return '$fieldName is too long';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final regex = RegExp(r'^[a-zA-Z\s\-\']+$');
    if (!regex.hasMatch(name)) {
      return '$fieldName contains invalid characters';
    }
    
    return null; // Valid name
  }

  /// Validate first name
  static String? validateFirstName(String firstName) {
    return validateName(firstName, 'First name');
  }

  /// Validate last name
  static String? validateLastName(String lastName) {
    return validateName(lastName, 'Last name');
  }

  /// Validate email format (general email validation)
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Email is required';
    }
    
    if (!isValidStudentEmail(email)) {
      return AppConstants.invalidEmailMessage;
    }
    
    return null; // Valid email
  }

  /// Validate phone number with detailed error messages
  static String? validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    if (!isValidPhoneNumber(phoneNumber)) {
      return AppConstants.invalidPhoneMessage;
    }
    
    return null; // Valid phone number
  }

  /// Validate student number with detailed error messages
  static String? validateStudentNumber(String studentNumber) {
    if (studentNumber.trim().isEmpty) {
      return 'Student number is required';
    }
    
    if (!isValidStudentNumber(studentNumber)) {
      return AppConstants.invalidStudentNumberMessage;
    }
    
    return null; // Valid student number
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleaned.startsWith('+27') && cleaned.length == 12) {
      // Format as +27 XX XXX XXXX
      return '+27 ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
    }
    
    return phoneNumber; // Return original if can't format
  }

  /// Format student number for display
  static String formatStudentNumber(String studentNumber) {
    // Remove all non-digit characters
    final cleaned = studentNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 8) {
      // Format as XXXX XXXX
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4)}';
    }
    
    return studentNumber; // Return original if can't format
  }

  /// Clean phone number for storage (remove formatting)
  static String cleanPhoneNumber(String phoneNumber) {
    // Remove all characters except digits and +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it starts with +27 for South African numbers
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      cleaned = '+27${cleaned.substring(1)}';
    } else if (cleaned.startsWith('27') && cleaned.length == 11) {
      cleaned = '+$cleaned';
    }
    
    return cleaned;
  }

  /// Clean student number for storage (remove formatting)
  static String cleanStudentNumber(String studentNumber) {
    // Remove all non-digit characters
    return studentNumber.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Validate that email belongs to Stellenbosch University
  static bool isUniversityEmail(String email) {
    return email.toLowerCase().endsWith('@${AppConstants.universityEmailDomain}');
  }

  /// Extract student name from email (before @ symbol)
  static String extractNameFromEmail(String email) {
    if (email.contains('@')) {
      final username = email.split('@')[0];
      // Replace dots and numbers with spaces for better display
      return username.replaceAll(RegExp(r'[.\d]'), ' ').trim();
    }
    return email;
  }

  /// Check if string contains only alphanumeric characters and spaces
  static bool isAlphanumericWithSpaces(String input) {
    final regex = RegExp(r'^[a-zA-Z0-9\s]+$');
    return regex.hasMatch(input);
  }

  /// Check if string is a valid name (letters, spaces, hyphens, apostrophes)
  static bool isValidNameFormat(String name) {
    final regex = RegExp(r'^[a-zA-Z\s\-\']+$');
    return regex.hasMatch(name);
  }

  /// Validate emergency contact number
  static String? validateEmergencyContact(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) {
      return null; // Emergency contact is optional
    }
    
    return validatePhoneNumber(phoneNumber);
  }
}