import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';

/// Main navigation screen with bottom tab bar
/// Placeholder for Phase 1B development with ride functionality
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _trackScreenView();
  }

  void _trackScreenView() {
    final analytics = context.read<AnalyticsService>();
    analytics.trackScreenView('main_navigation', 'MainNavigation');
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Track tab navigation
    final analytics = context.read<AnalyticsService>();
    analytics.trackButtonClick('tab_$index', 'main_navigation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _MapTab(),
          _MyRidesTab(),
          _MessagesTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'My Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Home tab placeholder
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: AppColors.primaryGradient,
              ),
              child: const Center(
                child: Text(
                  'H',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const _PlaceholderContent(
        title: 'Welcome to Hopin! 🚗',
        subtitle: 'Phase 1A Complete',
        description: 'Authentication is working! Phase 1B will add:\n\n'
            '• Ride creation and browsing\n'
            '• Real-time ride matching\n'
            '• In-app messaging\n'
            '• Payment processing\n'
            '• Safety features',
        icon: Icons.check_circle,
        iconColor: AppColors.success,
      ),
    );
  }
}

/// Map tab placeholder
class _MapTab extends StatelessWidget {
  const _MapTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: _PlaceholderContent(
        title: 'Map View',
        subtitle: 'Coming in Phase 1B',
        description: 'Real-time ride tracking and location services will be available here.',
        icon: Icons.map,
        iconColor: AppColors.secondary,
      ),
    );
  }
}

/// My Rides tab placeholder
class _MyRidesTab extends StatelessWidget {
  const _MyRidesTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: _PlaceholderContent(
        title: 'My Rides',
        subtitle: 'Coming in Phase 1B',
        description: 'View your upcoming rides, ride history, and manage your bookings.',
        icon: Icons.calendar_today,
        iconColor: AppColors.primary,
      ),
    );
  }
}

/// Messages tab placeholder
class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: _PlaceholderContent(
        title: 'Messages',
        subtitle: 'Coming in Phase 1B',
        description: 'Chat with other students about rides and coordinate pickups.',
        icon: Icons.chat_bubble,
        iconColor: AppColors.accent,
      ),
    );
  }
}

/// Profile tab placeholder with actual user data
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          body: user != null 
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  child: Column(
                    children: [
                      // Profile header
                      Container(
                        padding: const EdgeInsets.all(AppConstants.largePadding),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                gradient: AppColors.primaryGradient,
                              ),
                              child: Center(
                                child: Text(
                                  user.firstName.isNotEmpty 
                                      ? user.firstName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: AppConstants.defaultPadding),
                            
                            // User name
                            Text(
                              user.fullName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            
                            const SizedBox(height: AppConstants.smallPadding),
                            
                            // User email
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            
                            const SizedBox(height: AppConstants.defaultPadding),
                            
                            // Verification status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildVerificationBadge(
                                  'Email',
                                  user.verificationStatus.email,
                                ),
                                const SizedBox(width: AppConstants.smallPadding),
                                _buildVerificationBadge(
                                  'Phone',
                                  user.verificationStatus.phone,
                                ),
                                const SizedBox(width: AppConstants.smallPadding),
                                _buildVerificationBadge(
                                  'Student',
                                  user.verificationStatus.studentId,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.largePadding),
                      
                      // Student info
                      Container(
                        padding: const EdgeInsets.all(AppConstants.largePadding),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Information',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            
                            const SizedBox(height: AppConstants.defaultPadding),
                            
                            _buildInfoRow('University', AppConstants.targetUniversity),
                            _buildInfoRow('Student Number', user.studentNumber ?? 'Not provided'),
                            _buildInfoRow('Phone Number', user.phoneNumber),
                            _buildInfoRow('Roles', user.roles.map((r) => r.toString().toUpperCase()).join(', ')),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const _PlaceholderContent(
                  title: 'Profile Loading',
                  subtitle: 'Please wait...',
                  description: 'Loading your profile information.',
                  icon: Icons.person,
                  iconColor: AppColors.primary,
                ),
        );
      },
    );
  }

  Widget _buildVerificationBadge(String label, bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: (isVerified ? AppColors.success : AppColors.warning).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(
          color: isVerified ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.pending,
            size: 12,
            color: isVerified ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isVerified ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable placeholder content widget
class _PlaceholderContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color iconColor;

  const _PlaceholderContent({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                size: 60,
                color: iconColor,
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}