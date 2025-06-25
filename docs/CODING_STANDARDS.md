# Coding Standards - Hopin App

## Overview

This document establishes coding standards and best practices for the Hopin ride-sharing application. All team members must follow these guidelines to ensure code consistency, maintainability, and quality.

---

## 🎯 Core Principles

### 1. Code Readability
- Code should be self-documenting
- Use descriptive names for variables, functions, and classes
- Write code that tells a story of what the application does

### 2. Consistency
- Follow established patterns throughout the codebase
- Use consistent naming conventions
- Maintain consistent file and folder structures

### 3. Maintainability
- Write modular, reusable code
- Keep functions and classes focused on single responsibilities
- Design for easy testing and debugging

### 4. Performance
- Optimize for mobile performance
- Minimize unnecessary re-renders and computations
- Use efficient data structures and algorithms

---

## 📁 File Organization

### Directory Structure
```
lib/
├── models/           # Data models and DTOs
├── services/         # Business logic and external API calls
├── repositories/     # Data access layer
├── utils/           # Utility functions and helpers
├── constants/       # App constants and configuration
├── widgets/         # Reusable UI components
├── pages/           # FlutterFlow pages
└── generated/       # Generated code (FlutterFlow exports)

assets/
├── images/          # App images and icons
├── fonts/           # Custom fonts
└── data/            # Static data files

docs/
├── api/             # API documentation
├── user-guides/     # User documentation
└── technical/       # Technical documentation
```

### File Naming Conventions
- **Dart Files:** `snake_case.dart`
- **Image Assets:** `kebab-case.png/jpg`
- **JSON Files:** `snake_case.json`
- **Documentation:** `UPPER_SNAKE_CASE.md`

### Examples
```
✅ Good
user_service.dart
ride_model.dart
payment_repository.dart
app_constants.dart

❌ Bad
UserService.dart
rideModel.dart
PaymentRepo.dart
constants.dart
```

---

## 🏗️ Code Architecture

### Layered Architecture Implementation

#### 1. Presentation Layer (Pages & Widgets)
```dart
// Pages should be thin and delegate to services
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RideService _rideService = RideService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Ride>>(
        stream: _rideService.getAvailableRides(),
        builder: (context, snapshot) {
          // UI logic only
          if (snapshot.hasData) {
            return RideList(rides: snapshot.data!);
          }
          return LoadingIndicator();
        },
      ),
    );
  }
}
```

#### 2. Service Layer (Business Logic)
```dart
class RideService {
  final RideRepository _repository = RideRepository();
  final NotificationService _notifications = NotificationService();
  
  /// Creates a new ride with validation and notifications
  Future<Ride> createRide(CreateRideRequest request) async {
    // Validate business rules
    if (!_isValidRoute(request.origin, request.destination)) {
      throw InvalidRouteException('Route must be within Stellenbosch area');
    }
    
    // Create ride
    final ride = await _repository.createRide(request.toRide());
    
    // Send notifications
    await _notifications.notifyNearbyRiders(ride);
    
    return ride;
  }
  
  bool _isValidRoute(GeoPoint origin, GeoPoint destination) {
    // Business logic for route validation
    return StellenboschBounds.contains(origin) && 
           StellenboschBounds.contains(destination);
  }
}
```

#### 3. Repository Layer (Data Access)
```dart
class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Creates a new ride in Firestore
  Future<Ride> createRide(Ride ride) async {
    try {
      final docRef = await _firestore.collection('rides').add(ride.toJson());
      return ride.copyWith(id: docRef.id);
    } catch (e) {
      throw DatabaseException('Failed to create ride: $e');
    }
  }
  
  /// Retrieves available rides as a stream
  Stream<List<Ride>> getAvailableRides() {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'active')
        .where('availableSeats', isGreaterThan: 0)
        .orderBy('departureTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ride.fromJson(doc.data()))
            .toList());
  }
}
```

---

## 📝 Naming Conventions

### Variables and Functions
```dart
// Use camelCase for variables and functions
final String userName = 'John Doe';
final int totalRides = 5;
bool isVerified = true;

// Function names should be verbs describing what they do
Future<void> createRide() async { }
bool validateUser(User user) { }
String formatCurrency(double amount) { }
```

### Classes and Types
```dart
// Use PascalCase for classes, interfaces, and types
class UserService { }
class RideModel { }
enum RideStatus { active, completed, cancelled }
typedef UserCallback = void Function(User user);
```

### Constants
```dart
// Use UPPER_SNAKE_CASE for constants
class AppConstants {
  static const String APP_NAME = 'Hopin';
  static const int MAX_SEATS_PER_RIDE = 6;
  static const Duration RIDE_TIMEOUT = Duration(hours: 24);
}
```

### Collections and Fields
```dart
// Firestore collection names: lowercase with underscores
const String USERS_COLLECTION = 'users';
const String RIDES_COLLECTION = 'rides';
const String RIDE_REQUESTS_COLLECTION = 'ride_requests';

// Field names: camelCase
class UserModel {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime createdAt;
}
```

---

## 🔧 Code Style Guidelines

### Formatting
```dart
// Use 2-space indentation
class Example {
  final String property;
  
  Example({
    required this.property,
  });
}

// Line length: 80 characters max
String longMessage = 'This is a very long message that should be '
    'broken into multiple lines for better readability';

// Trailing commas for better diffs
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('First item'),
      Text('Second item'),
      Text('Third item'), // trailing comma
    ],
  );
}
```

### Comments and Documentation
```dart
/// Service for managing user authentication and profiles.
/// 
/// This service handles user registration, login, profile updates,
/// and student verification workflows.
class AuthService {
  
  /// Registers a new user with email and password.
  /// 
  /// Throws [AuthException] if registration fails.
  /// Returns the newly created [User] object.
  Future<User> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Implementation details...
  }
  
  // Private helper method - brief comment explaining purpose
  bool _isValidStudentEmail(String email) {
    return email.endsWith('@sun.ac.za');
  }
}
```

### Error Handling
```dart
// Use specific exception types
class AuthException implements Exception {
  final String message;
  final String? code;
  
  AuthException(this.message, {this.code});
  
  @override
  String toString() => 'AuthException: $message';
}

// Proper try-catch with specific handling
Future<User> loginUser(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    
    return User.fromFirebaseUser(credential.user!);
    
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        throw AuthException('No user found with this email');
      case 'wrong-password':
        throw AuthException('Incorrect password');
      default:
        throw AuthException('Login failed: ${e.message}');
    }
  } catch (e) {
    throw AuthException('Unexpected error during login');
  }
}
```

---

## 🧪 Testing Standards

### Test Organization
```
test/
├── unit/
│   ├── services/
│   │   ├── auth_service_test.dart
│   │   ├── ride_service_test.dart
│   │   └── payment_service_test.dart
│   ├── models/
│   │   ├── user_model_test.dart
│   │   └── ride_model_test.dart
│   └── utils/
│       └── validators_test.dart
├── widget/
│   ├── pages/
│   └── components/
└── integration/
    ├── firebase/
    └── payment/
```

### Test Naming
```dart
// Test files: {class_name}_test.dart
// Test groups: describe the class or feature being tested
// Test cases: describe the specific behavior being tested

void main() {
  group('AuthService', () {
    late AuthService authService;
    
    setUp(() {
      authService = AuthService();
    });
    
    group('registerUser', () {
      test('should register user with valid credentials', () async {
        // Arrange
        const email = 'test@sun.ac.za';
        const password = 'SecurePass123';
        
        // Act
        final user = await authService.registerUser(
          email: email,
          password: password,
          firstName: 'John',
          lastName: 'Doe',
        );
        
        // Assert
        expect(user.email, equals(email));
        expect(user.isVerified, isFalse);
      });
      
      test('should throw AuthException for invalid email domain', () {
        // Arrange
        const invalidEmail = 'test@gmail.com';
        
        // Act & Assert
        expect(
          () => authService.registerUser(
            email: invalidEmail,
            password: 'password',
            firstName: 'John',
            lastName: 'Doe',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });
}
```

### Mocking
```dart
// Use mockito for mocking dependencies
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('AuthService with mocks', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    
    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockAuth);
    });
    
    test('should handle Firebase auth errors', () async {
      // Arrange
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(
        code: 'weak-password',
        message: 'Password is too weak',
      ));
      
      // Act & Assert
      expect(
        () => authService.registerUser(
          email: 'test@sun.ac.za',
          password: '123',
          firstName: 'John',
          lastName: 'Doe',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
```

---

## 🔒 Security Guidelines

### Data Validation
```dart
class UserValidator {
  static bool isValidEmail(String email) {
    // Student email validation
    if (!email.endsWith('@sun.ac.za')) {
      return false;
    }
    
    // Email format validation
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
  
  static bool isValidPhoneNumber(String phone) {
    // South African phone number validation
    return RegExp(r'^\+27[0-9]{9}$').hasMatch(phone);
  }
  
  static bool isValidStudentNumber(String studentNumber) {
    // Stellenbosch student number format
    return RegExp(r'^[0-9]{8}$').hasMatch(studentNumber);
  }
}
```

### Sensitive Data Handling
```dart
// Never log sensitive information
class PaymentService {
  Future<void> processPayment(PaymentDetails details) async {
    // ❌ Never log payment details
    // print('Processing payment: $details');
    
    // ✅ Log non-sensitive information only
    logger.info('Processing payment for user: ${details.userId}');
    
    try {
      await paymentGateway.charge(details);
      logger.info('Payment successful for user: ${details.userId}');
    } catch (e) {
      // ❌ Don't log the full exception (might contain sensitive data)
      // logger.error('Payment failed: $e');
      
      // ✅ Log safe error information
      logger.error('Payment failed for user: ${details.userId}, reason: ${e.runtimeType}');
    }
  }
}
```

### Firestore Security Rules
```javascript
// Always validate user permissions
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == userId &&
                        isValidUserData(request.resource.data);
    }
    
    // Validation functions
    function isValidUserData(data) {
      return data.keys().hasAll(['email', 'firstName', 'lastName']) &&
             data.email.matches('.*@sun\\.ac\\.za$');
    }
  }
}
```

---

## 🚀 Performance Guidelines

### Flutter Performance
```dart
// Use const constructors where possible
class RideCard extends StatelessWidget {
  const RideCard({
    Key? key,
    required this.ride,
  }) : super(key: key);
  
  final Ride ride;
  
  @override
  Widget build(BuildContext context) {
    return const Card( // const constructor
      child: ListTile(
        leading: const Icon(Icons.directions_car), // const widget
        title: Text(ride.destination),
      ),
    );
  }
}

// Use ListView.builder for large lists
Widget buildRideList(List<Ride> rides) {
  return ListView.builder(
    itemCount: rides.length,
    itemBuilder: (context, index) {
      return RideCard(ride: rides[index]);
    },
  );
}

// Avoid building widgets in build method
class BadExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ Creates new widget every build
    return Column(
      children: [
        Container(color: Colors.blue, height: 100),
        Container(color: Colors.red, height: 100),
      ],
    );
  }
}

class GoodExample extends StatelessWidget {
  // ✅ Widgets created once
  static const Widget blueContainer = Container(color: Colors.blue, height: 100);
  static const Widget redContainer = Container(color: Colors.red, height: 100);
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [blueContainer, redContainer],
    );
  }
}
```

### Firebase Performance
```dart
// Use pagination for large datasets
class RideRepository {
  static const int PAGE_SIZE = 20;
  
  Future<List<Ride>> getRides({DocumentSnapshot? lastDocument}) async {
    Query query = FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'active')
        .orderBy('departureTime')
        .limit(PAGE_SIZE);
    
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Ride.fromFirestore(doc)).toList();
  }
}

// Cache frequently accessed data
class UserService {
  static final Map<String, User> _userCache = {};
  
  Future<User> getUser(String userId) async {
    // Check cache first
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }
    
    // Fetch from Firestore if not cached
    final user = await _fetchUserFromFirestore(userId);
    _userCache[userId] = user;
    
    return user;
  }
}
```

---

## 📊 Logging and Monitoring

### Logging Standards
```dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }
  
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }
  
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }
}

// Usage in services
class RideService {
  Future<Ride> createRide(CreateRideRequest request) async {
    AppLogger.info('Creating ride for user: ${request.driverId}');
    
    try {
      final ride = await _repository.createRide(request.toRide());
      AppLogger.info('Ride created successfully: ${ride.id}');
      return ride;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create ride', e, stackTrace);
      rethrow;
    }
  }
}
```

### Analytics Events
```dart
class AnalyticsService {
  static Future<void> logRideCreated(Ride ride) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'ride_created',
      parameters: {
        'ride_id': ride.id,
        'origin': ride.originAddress,
        'destination': ride.destinationAddress,
        'price': ride.pricePerSeat,
        'seats': ride.totalSeats,
      },
    );
  }
  
  static Future<void> logRideCompleted(Ride ride) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'ride_completed',
      parameters: {
        'ride_id': ride.id,
        'duration_minutes': ride.actualDuration?.inMinutes,
        'rider_count': ride.confirmedRiders.length,
      },
    );
  }
}
```

---

## ✅ Code Review Checklist

### Before Submitting Code
- [ ] Code follows naming conventions
- [ ] Functions are single-responsibility and well-named
- [ ] Error handling is comprehensive
- [ ] Tests are written and passing
- [ ] Security considerations are addressed
- [ ] Performance impact is considered
- [ ] Documentation is updated
- [ ] No sensitive data in logs
- [ ] Firestore queries are optimized

### Review Criteria
- [ ] Code is readable and self-documenting
- [ ] Business logic is in service layer
- [ ] UI components are reusable
- [ ] Error messages are user-friendly
- [ ] Edge cases are handled
- [ ] No code duplication
- [ ] Consistent with existing patterns

---

## 🔄 Continuous Improvement

### Regular Reviews
- **Weekly:** Team code review sessions
- **Monthly:** Update coding standards based on learnings
- **Quarterly:** Architecture and performance review

### Learning Resources
- Flutter documentation and best practices
- Firebase documentation and limits
- Dart language updates and features
- FlutterFlow updates and capabilities

### Metrics to Track
- Code coverage percentage
- Build and test execution time
- Code review feedback patterns
- Performance benchmarks 