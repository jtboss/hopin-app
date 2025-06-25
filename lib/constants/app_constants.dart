/// App constants for Hopin - Student ride-sharing app
class AppConstants {
  // App Information
  static const String appName = 'Hopin';
  static const String appTagline = 'Student rides made simple';
  static const String appDescription = 'Student ride-sharing app for Stellenbosch University';
  static const String appVersion = '1.0.0';
  
  // University Information
  static const String targetUniversity = 'Stellenbosch University';
  static const String universityCode = 'stellenbosch';
  static const String universityEmailDomain = 'sun.ac.za';
  static const String universityLocation = 'Stellenbosch, South Africa';
  
  // Validation Constants
  static const String emailValidationRegex = r'^[a-zA-Z0-9._%+-]+@sun\.ac\.za$';
  static const String phoneValidationRegex = r'^\+27[0-9]{9}$';
  static const String studentNumberRegex = r'^[0-9]{8}$';
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 50;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  
  static const double defaultElevation = 2.0;
  static const double cardElevation = 4.0;
  
  // Animation Durations
  static const int shortAnimationDuration = 300;
  static const int mediumAnimationDuration = 600;
  static const int longAnimationDuration = 1000;
  
  // Onboarding Content
  static const List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      title: 'Find Your Ride',
      description: 'Connect with fellow students heading your way',
      imagePath: 'assets/illustrations/students_in_car_illustration.svg',
    ),
    OnboardingPage(
      title: 'Share the Journey',
      description: 'Offer rides and split fuel costs with your peers',
      imagePath: 'assets/illustrations/map_routes_illustration.svg',
    ),
    OnboardingPage(
      title: 'Safe & Trusted',
      description: 'Verified student community for secure travel',
      imagePath: 'assets/illustrations/safety_shield_illustration.svg',
    ),
  ];
  
  // Campus Locations
  static const List<String> campusLocations = [
    'Main Campus',
    'Welgevallen',
    'Tygerberg',
    'Medical Campus',
  ];
  
  // Quick Destinations
  static const List<String> quickDestinations = [
    'To Campus',
    'To Residence',
    'To Town',
    'To Airport',
    'To Train Station',
  ];
  
  // Ride Constants
  static const int maxSeatsPerRide = 6;
  static const int minPricePerSeat = 15;
  static const int maxPricePerSeat = 50;
  static const int maxRideDistanceKm = 100;
  
  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.hopin.co.za';
  static const String developmentBaseUrl = 'https://dev-api.hopin.co.za';
  static const String stagingBaseUrl = 'https://staging-api.hopin.co.za';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String ridesCollection = 'rides';
  static const String rideRequestsCollection = 'ride_requests';
  static const String universitiesCollection = 'universities';
  static const String paymentsCollection = 'payments';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';
  
  // Shared Preferences Keys
  static const String isFirstTimeUserKey = 'is_first_time_user';
  static const String userTokenKey = 'user_token';
  static const String userPreferencesKey = 'user_preferences';
  static const String lastLocationKey = 'last_location';
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String invalidEmailMessage = 'Please enter a valid @sun.ac.za email address.';
  static const String invalidPhoneMessage = 'Please enter a valid South African phone number.';
  static const String invalidStudentNumberMessage = 'Please enter a valid 8-digit student number.';
  static const String passwordTooShortMessage = 'Password must be at least 6 characters long.';
  static const String passwordsDontMatchMessage = 'Passwords do not match.';
  
  // Success Messages
  static const String registrationSuccessMessage = 'Account created successfully!';
  static const String loginSuccessMessage = 'Welcome back!';
  static const String emailVerificationSentMessage = 'Verification email sent. Please check your inbox.';
  static const String phoneVerificationSentMessage = 'Verification code sent to your phone.';
  
  // Feature Flags
  static const bool enableDebugMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;
}

/// Onboarding page data model
class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}