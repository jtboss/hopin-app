/// App constants for Hopin ride-sharing app
class AppConstants {
  // App Info
  static const String appName = 'Hopin';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Student ride-sharing for Stellenbosch University';
  
  // University Info
  static const String universityName = 'Stellenbosch University';
  static const String universityDomain = '@sun.ac.za';
  
  // Campus Locations
  static const List<String> campusLocations = [
    'Main Campus',
    'Welgevallen Campus',
    'Tygerberg Campus',
    'Medical Campus',
    'Bellville Park Campus',
  ];
  
  // Common Destinations
  static const List<String> popularDestinations = [
    'Main Campus',
    'Stellenbosch Central',
    'Eikestad Mall',
    'Welgevallen Campus',
    'Tygerberg Hospital',
    'Medical Campus',
    'Kayamandi',
    'Cloetesville',
    'Die Boord',
    'Paradyskloof',
  ];
  
  // Pricing
  static const double minPricePerSeat = 15.0;
  static const double maxPricePerSeat = 40.0;
  static const String currency = 'ZAR';
  static const String currencySymbol = 'R';
  
  // Ride Options
  static const List<String> rideTypes = ['HopinPool', 'HopinGo'];
  static const Map<String, String> rideTypeDescriptions = {
    'HopinPool': 'Share with students',
    'HopinGo': 'Direct ride',
  };
  
  // Capacity
  static const int minSeats = 1;
  static const int maxSeats = 6;
  
  // Time Constraints
  static const int maxAdvanceBookingDays = 7;
  static const int minAdvanceBookingMinutes = 30;
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  
  // Animation Durations
  static const int animationDurationMs = 300;
  static const int fastAnimationDurationMs = 150;
  static const int slowAnimationDurationMs = 500;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String ridesCollection = 'rides';
  static const String rideRequestsCollection = 'ride_requests';
  static const String ratingsCollection = 'ratings';
  
  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxNotesLength = 200;
  
  // Emergency Contacts
  static const String emergencyNumber = '10111';
  static const String campusSecurityNumber = '021 808 4444';
  
  // App URLs
  static const String privacyPolicyUrl = 'https://hopin.co.za/privacy';
  static const String termsOfServiceUrl = 'https://hopin.co.za/terms';
  static const String supportEmail = 'support@hopin.co.za';
}