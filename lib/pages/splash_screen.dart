import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import 'onboarding_screen.dart';
import 'auth/login_register_screen.dart';
import 'main_navigation.dart';

/// Splash screen that displays the Hopin logo and tagline
/// Handles app initialization and routing logic
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize fade-in and scale animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: AppConstants.longAnimationDuration),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  /// Initialize app services and determine next route
  Future<void> _initializeApp() async {
    try {
      // Track app open
      final analytics = context.read<AnalyticsService>();
      await analytics.trackAppOpen();

      // Initialize authentication service
      final authService = context.read<AuthService>();
      await authService.initialize();

      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      // Determine navigation route
      await _navigateToNextScreen();
    } catch (e) {
      debugPrint('Splash screen initialization error: $e');
      // On error, go to onboarding
      if (mounted) {
        await _navigateToOnboarding();
      }
    }
  }

  /// Determine and navigate to the appropriate next screen
  Future<void> _navigateToNextScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool(AppConstants.isFirstTimeUserKey) ?? true;
      final authService = context.read<AuthService>();

      if (isFirstTime) {
        // First time user - show onboarding
        await _navigateToOnboarding();
      } else if (authService.isAuthenticated) {
        // Returning user with valid session - go to main app
        await _navigateToMainApp();
      } else {
        // Returning user without session - go to login
        await _navigateToAuth();
      }
    } catch (e) {
      debugPrint('Navigation determination error: $e');
      await _navigateToOnboarding();
    }
  }

  /// Navigate to onboarding screen
  Future<void> _navigateToOnboarding() async {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionDuration: Duration(
          milliseconds: AppConstants.mediumAnimationDuration,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Navigate to authentication screen
  Future<void> _navigateToAuth() async {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginRegisterScreen(),
        transitionDuration: Duration(
          milliseconds: AppConstants.mediumAnimationDuration,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate to main app
  Future<void> _navigateToMainApp() async {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigation(),
        transitionDuration: Duration(
          milliseconds: AppConstants.mediumAnimationDuration,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(scale: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hopin Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'H',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.largePadding),
                      
                      // App Name
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.smallPadding),
                      
                      // Tagline
                      Text(
                        AppConstants.appTagline,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppConstants.extraLargePadding),
                      
                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}