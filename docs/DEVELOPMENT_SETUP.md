# Development Setup Guide - Hopin App

## 🎯 Overview

This guide will help you set up your development environment for the Hopin ride-sharing application. Follow these steps to get your local development environment running.

---

## 📋 Prerequisites

### Required Software
- **Flutter SDK** (Latest stable version)
- **Dart SDK** (Comes with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)
- **Git** for version control
- **Node.js** (for Firebase CLI)

### Accounts Required
- **Google/Firebase Account** for backend services
- **FlutterFlow Account** for UI development
- **GitHub Account** for code repository
- **Paystack Account** for payment testing (sandbox)

---

## 🛠️ Environment Setup

### 1. Flutter Installation

#### macOS
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Windows
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add C:\src\flutter\bin to PATH

# Verify installation
flutter doctor
```

#### Ubuntu/Linux
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add to ~/.bashrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Install dependencies
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa

# Verify installation
flutter doctor
```

### 2. IDE Setup

#### VS Code (Recommended)
```bash
# Install VS Code extensions
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension ms-vscode.vscode-json
code --install-extension bradlc.vscode-tailwindcss
```

#### Android Studio
1. Download and install Android Studio
2. Install Flutter and Dart plugins
3. Configure Android SDK and emulator

### 3. Firebase Setup

#### Install Firebase CLI
```bash
# Install Node.js first, then:
npm install -g firebase-tools

# Login to Firebase
firebase login

# Verify installation
firebase --version
```

#### Configure Firebase for Flutter
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase project
flutterfire configure
```

---

## 🚀 Project Setup

### 1. Clone Repository
```bash
# Clone the project
git clone [REPOSITORY_URL]
cd hopin-app

# Create development branch
git checkout -b feature/your-feature-name
```

### 2. Install Dependencies
```bash
# Get Flutter dependencies
flutter pub get

# Install additional tools
flutter pub global activate rename
flutter pub global activate flutter_gen
```

### 3. Configure Environment Files

#### Create `.env` file
```bash
# Copy environment template
cp .env.example .env

# Edit with your configurations
vim .env
```

#### Environment Variables
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=hopin-dev
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id

# Payment Configuration
PAYSTACK_PUBLIC_KEY=pk_test_your_test_key
PAYSTACK_SECRET_KEY=sk_test_your_test_key

# App Configuration
APP_ENV=development
DEBUG_MODE=true
API_BASE_URL=https://api.hopin.co.za

# University Configuration
DEFAULT_UNIVERSITY=stellenbosch
UNIVERSITY_EMAIL_DOMAIN=sun.ac.za
```

### 4. Firebase Project Configuration

#### Development Project Structure
```
hopin-development/
├── Authentication
├── Firestore Database
├── Storage
├── Cloud Functions
├── Hosting
└── Analytics
```

#### Firestore Collections Setup
```bash
# Initialize Firestore collections
firebase firestore:import ./setup/firestore-seed.json
```

#### Security Rules Setup
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

---

## 🔧 FlutterFlow Integration

### 1. FlutterFlow Project Setup
1. Create new FlutterFlow project
2. Connect to Firebase project
3. Import design system and components
4. Configure authentication flow

### 2. Code Export Configuration
```yaml
# FlutterFlow export settings
flutter_flow:
  export:
    format: "dart"
    target_directory: "lib/generated"
    preserve_custom_code: true
    merge_strategy: "smart_merge"
```

### 3. Custom Code Integration
```dart
// lib/custom_code/
├── actions/          # Custom FlutterFlow actions
├── widgets/          # Custom widgets
└── functions/        # Helper functions
```

---

## 📱 Device Setup

### Android Development

#### Emulator Setup
```bash
# Create Android Virtual Device
flutter emulators --launch <emulator_id>

# Or use physical device
flutter devices
flutter run -d <device_id>
```

#### Physical Device Setup
1. Enable Developer Options
2. Enable USB Debugging
3. Install app: `flutter run`

### iOS Development (macOS only)

#### Simulator Setup
```bash
# List available simulators
xcrun simctl list devices

# Run on iOS simulator
flutter run -d iPhone
```

#### Physical Device Setup
1. Connect device via USB
2. Trust computer in device settings
3. Run: `flutter run`

---

## 🧪 Testing Setup

### Unit Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Integration Testing
```bash
# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Firebase Emulator Setup
```bash
# Install emulators
firebase setup:emulators:firestore
firebase setup:emulators:auth

# Start emulators
firebase emulators:start

# Run tests against emulators
flutter test integration_test/
```

---

## 🔍 Development Tools

### Code Quality Tools

#### Linting
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  
  errors:
    invalid_annotation_target: ignore
  
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
```

#### Formatting
```bash
# Format code
dart format .

# Check formatting
dart format --set-exit-if-changed .
```

#### Code Generation
```bash
# Generate model classes
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Debugging Tools

#### VS Code Launch Configuration
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "hopin-app",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--flavor", "development"]
    },
    {
      "name": "hopin-app (profile mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile",
      "program": "lib/main.dart"
    }
  ]
}
```

#### Flutter Inspector
```bash
# Open Flutter Inspector
flutter inspector

# Performance monitoring
flutter run --trace-startup
```

---

## 🌐 API Integration

### Local Development Server
```bash
# Start Firebase emulators
firebase emulators:start --only functions,firestore,auth

# Test API endpoints
curl -X GET http://localhost:5001/hopin-dev/us-central1/api/rides
```

### Payment Gateway Testing

#### Paystack Test Cards
```javascript
// Test card numbers
const testCards = {
  successful: "4084084084084081",
  declined: "4084084084084085",
  insufficient: "4084084084084087"
};

// Test in sandbox mode
PAYSTACK_PUBLIC_KEY=pk_test_your_sandbox_key
```

---

## 📊 Monitoring Setup

### Firebase Analytics
```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  static Future<void> logAppOpen() async {
    await analytics.logAppOpen();
  }
}
```

### Crashlytics
```dart
// lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(MyApp());
}
```

### Performance Monitoring
```dart
// lib/services/performance_service.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static Future<T> trackOperation<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    final trace = FirebasePerformance.instance.newTrace(name);
    await trace.start();
    
    try {
      final result = await operation();
      trace.setMetric('success', 1);
      return result;
    } catch (e) {
      trace.setMetric('error', 1);
      rethrow;
    } finally {
      await trace.stop();
    }
  }
}
```

---

## 🔄 Git Workflow

### Branch Naming Convention
```bash
# Feature branches
git checkout -b feature/user-authentication
git checkout -b feature/ride-matching

# Bug fixes
git checkout -b bugfix/payment-validation

# Hotfixes
git checkout -b hotfix/critical-security-fix
```

### Commit Message Format
```
type(scope): subject

body

footer
```

#### Examples
```bash
feat(auth): add student email verification

- Implement @sun.ac.za domain validation
- Add SMS OTP verification
- Update user model with verification status

Closes #123
```

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      
  - repo: https://github.com/dart-lang/sdk
    rev: stable
    hooks:
      - id: dart-format
      - id: dart-analyze
```

---

## 🚨 Troubleshooting

### Common Issues

#### Flutter Doctor Issues
```bash
# Android license issues
flutter doctor --android-licenses

# iOS development setup
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### Firebase Connection Issues
```bash
# Re-configure Firebase
flutterfire configure

# Check Firebase project status
firebase projects:list
```

#### Build Issues
```bash
# Clean build
flutter clean
flutter pub get

# Reset CocoaPods (iOS)
cd ios && rm -rf Pods Podfile.lock && pod install
```

#### FlutterFlow Export Issues
```bash
# Clear FlutterFlow cache
rm -rf lib/generated
flutter packages pub run build_runner clean
```

### Performance Issues
```bash
# Profile app performance
flutter run --profile

# Analyze app size
flutter build apk --analyze-size
```

---

## 📚 Learning Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [FlutterFlow Documentation](https://docs.flutterflow.io/)
- [Dart Language Guide](https://dart.dev/guides)

### Video Tutorials
- Flutter Official YouTube Channel
- Firebase YouTube Channel
- FlutterFlow Academy

### Community
- Flutter Discord Server
- Stack Overflow (flutter tag)
- GitHub Flutter Community

---

## ✅ Setup Verification

### Checklist
- [ ] Flutter installed and configured
- [ ] IDE setup with required extensions
- [ ] Firebase project created and configured
- [ ] Repository cloned and dependencies installed
- [ ] Environment variables configured
- [ ] Test suite running successfully
- [ ] Development device/emulator working
- [ ] Firebase emulators running
- [ ] Payment gateway sandbox configured
- [ ] Git workflow configured

### Test Commands
```bash
# Verify Flutter setup
flutter doctor -v

# Verify project build
flutter build apk --debug

# Verify tests
flutter test

# Verify Firebase connection
firebase projects:list
```

---

## 🆘 Getting Help

### Internal Resources
- Check existing documentation in `/docs`
- Review code comments and README files
- Search project issues and pull requests

### External Resources
- Post questions with specific error messages
- Include Flutter doctor output
- Provide minimal reproducible examples
- Tag issues appropriately

### Emergency Contacts
- **Technical Lead:** [Contact Information]
- **Firebase Support:** Firebase Console Support
- **FlutterFlow Support:** support@flutterflow.io 