import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home/home_feed_screen.dart';
import 'map/map_view_screen.dart';
import 'rides/my_rides_screen.dart';
import 'messaging/chat_list_screen.dart';
import 'profile/profile_screen.dart';

/// Main navigation screen with bottom tabs for the Hopin app
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // List of tab screens as specified in the roadmap
  final List<Widget> _screens = [
    const HomeFeedScreen(),     // Home tab - Live ride feed
    const MapViewScreen(),      // Map tab - Interactive map view
    const MyRidesScreen(),      // My Rides tab - Ride management
    const ChatListScreen(),     // Messages tab - In-app chat
    const ProfileScreen(),      // Profile tab - Enhanced profile
  ];

  // Tab configuration based on UI specification
  final List<NavigationTab> _tabs = [
    NavigationTab(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    NavigationTab(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      label: 'Map',
    ),
    NavigationTab(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      label: 'My Rides',
    ),
    NavigationTab(
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      label: 'Messages',
    ),
    NavigationTab(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = index == _currentIndex;

                return GestureDetector(
                  onTap: () => _onTabTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? tab.selectedIcon : tab.icon,
                          color: isSelected 
                              ? AppColors.navActive 
                              : AppColors.navInactive,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isSelected 
                                ? AppColors.navActive 
                                : AppColors.navInactive,
                            fontSize: 12,
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

/// Data class for navigation tab configuration
class NavigationTab {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  NavigationTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}