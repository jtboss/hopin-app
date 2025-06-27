import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';
import '../widgets/ride_card.dart';
import 'ride_details_screen.dart';
import 'create_ride_screen.dart';
import 'find_ride_screen.dart';

/// Home feed screen with Uber-style design
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final RideService _rideService = RideService();
  
  // Mock current user data (in real app, this would come from auth service)
  final String _currentUserId = 'mock_user_id';
  final String _firstName = 'Student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildUberStyleHeader(),
            _buildDestinationSearchBar(),
            _buildRideOptionsCarousel(),
            Expanded(child: _buildNearbyRidesList()),
          ],
        ),
      ),
      floatingActionButton: _buildCreateRideFAB(),
    );
  }

  /// Build Uber-style header with greeting and profile
  Widget _buildUberStyleHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _firstName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Text(
                _firstName[0],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build destination search bar (Uber-style)
  Widget _buildDestinationSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FindRideScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Where are you going?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build ride options carousel (Uber-style)
  Widget _buildRideOptionsCarousel() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildRideOption(
              title: 'HopinPool',
              subtitle: 'Share with students',
              icon: Icons.people,
              priceRange: 'R15-R25',
              eta: '5-10 min',
              color: AppColors.secondary,
              onTap: () => _navigateToFindRide(rideType: 'HopinPool'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildRideOption(
              title: 'HopinGo',
              subtitle: 'Direct ride',
              icon: Icons.directions_car,
              priceRange: 'R25-R40',
              eta: '3-8 min',
              color: AppColors.primary,
              onTap: () => _navigateToFindRide(rideType: 'HopinGo'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual ride option
  Widget _buildRideOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String priceRange,
    required String eta,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    priceRange,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    eta,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build nearby rides list
  Widget _buildNearbyRidesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Text(
            'Available Rides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Ride>>(
            stream: _rideService.getAvailableRides(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              final rides = snapshot.data ?? [];

              if (rides.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // Account for FAB
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  return RideCard(
                    ride: ride,
                    onTap: () => _navigateToRideDetails(ride),
                    onRequestRide: () => _requestRide(ride),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading available rides...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load rides',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() {}), // Rebuild to retry
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'No rides available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to offer a ride!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateRide,
            icon: const Icon(Icons.add),
            label: const Text('Offer a Ride'),
          ),
        ],
      ),
    );
  }

  /// Build create ride floating action button
  Widget _buildCreateRideFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreateRide,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.add),
      label: const Text(
        'Offer Ride',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Get appropriate greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  /// Navigate to find ride screen with optional ride type filter
  void _navigateToFindRide({String? rideType}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FindRideScreen(initialRideType: rideType),
      ),
    );
  }

  /// Navigate to create ride screen
  void _navigateToCreateRide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRideScreen(),
      ),
    );
  }

  /// Navigate to ride details screen
  void _navigateToRideDetails(Ride ride) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RideDetailsScreen(ride: ride),
      ),
    );
  }

  /// Request to join a ride
  void _requestRide(Ride ride) {
    // TODO: Implement ride request logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Requesting to join ${ride.driverInfo.name}\'s ride...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}