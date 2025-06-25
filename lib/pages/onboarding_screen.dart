import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../services/analytics_service.dart';
import 'auth/login_register_screen.dart';

/// Onboarding screen with three pages introducing Hopin features
/// Based on UI specification with student-focused messaging
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _trackScreenView();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _trackScreenView() {
    final analytics = context.read<AnalyticsService>();
    analytics.trackScreenView('onboarding', 'OnboardingScreen');
  }

  /// Handle page change
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    
    // Track page view
    final analytics = context.read<AnalyticsService>();
    analytics.trackButtonClick(
      'onboarding_page_$page',
      'onboarding',
    );
  }

  /// Navigate to next page or complete onboarding
  void _nextPage() {
    if (_currentPage < AppConstants.onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: AppConstants.mediumAnimationDuration),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Skip to the end of onboarding
  void _skipOnboarding() {
    _pageController.animateToPage(
      AppConstants.onboardingPages.length - 1,
      duration: Duration(milliseconds: AppConstants.mediumAnimationDuration),
      curve: Curves.easeInOut,
    );
  }

  /// Complete onboarding and navigate to authentication
  Future<void> _completeOnboarding() async {
    try {
      // Mark onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isFirstTimeUserKey, false);

      // Track onboarding completion
      final analytics = context.read<AnalyticsService>();
      await analytics.trackOnboardingCompleted('anonymous');

      if (!mounted) return;

      // Navigate to authentication screen
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
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      // Still navigate even if prefs fail
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < AppConstants.onboardingPages.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: AppConstants.onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = AppConstants.onboardingPages[index];
                  return _OnboardingPage(
                    title: page.title,
                    description: page.description,
                    imagePath: page.imagePath,
                    pageIndex: index,
                  );
                },
              ),
            ),

            // Bottom section with indicator and button
            Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: AppConstants.onboardingPages.length,
                    effect: WormEffect(
                      dotColor: AppColors.disabled,
                      activeDotColor: AppColors.primary,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 16,
                      radius: 4,
                    ),
                  ),

                  const SizedBox(height: AppConstants.extraLargePadding),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                        ),
                      ),
                      child: Text(
                        _currentPage == AppConstants.onboardingPages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual onboarding page widget
class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final int pageIndex;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _getIllustration(pageIndex),
          ),

          const SizedBox(height: AppConstants.extraLargePadding),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get illustration widget for each page
  Widget _getIllustration(int pageIndex) {
    switch (pageIndex) {
      case 0:
        // Find Your Ride illustration
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: 80,
                  color: AppColors.primary,
                ),
                SizedBox(height: 16),
                Icon(
                  Icons.directions_car,
                  size: 60,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        );

      case 1:
        // Share the Journey illustration
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 80,
                  color: AppColors.secondary,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 40,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.share,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case 2:
        // Safe & Trusted illustration
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.success.withOpacity(0.1),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 80,
                  color: AppColors.success,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 40,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.school,
                      size: 40,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      default:
        return const Center(
          child: Icon(
            Icons.help_outline,
            size: 80,
            color: AppColors.disabled,
          ),
        );
    }
  }
}