import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/ride_service.dart';
import '../../models/ride_model.dart';
import '../../widgets/ride_card.dart';
import 'create_ride_screen.dart';
import 'ride_details_screen.dart';

/// Home feed screen showing available rides with Uber-style UX
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial rides
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRides();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRides() async {
    final rideService = Provider.of<RideService>(context, listen: false);
    await rideService.getAvailableRides();
  }

  Future<void> _onRefresh() async {
    await _loadRides();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Uber-style header
              _buildUberHeader(),
              
              // Destination search bar
              _buildDestinationSearch(),
              
              // Quick ride options
              _buildRideOptions(),
              
              // Available rides section
              _buildAvailableRidesSection(),
              
              // Ride list
              _buildRideList(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCreateRideFAB(),
    );
  }

  /// Uber-style header with user greeting and profile avatar
  Widget _buildUberHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, Student!', // TODO: Get from user service
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stellenbosch',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.surface,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Where are you going?" search bar
  Widget _buildDestinationSearch() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () {
            // TODO: Navigate to find ride screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Find Ride feature coming soon!')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Where are you going?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Quick ride options (HopinPool, HopinGo)
  Widget _buildRideOptions() {
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _buildRideOption(
              title: 'HopinPool',
              subtitle: 'Share with students',
              icon: Icons.groups,
              priceRange: 'R15-R25',
              eta: '5-10 min',
              color: AppColors.secondary,
            ),
            const SizedBox(width: 16),
            _buildRideOption(
              title: 'HopinGo',
              subtitle: 'Direct ride',
              icon: Icons.directions_car,
              priceRange: 'R25-R40',
              eta: '3-8 min',
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String priceRange,
    required String eta,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title feature coming soon!')),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
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
                    size: 20,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  eta,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              priceRange,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Available rides section header
  Widget _buildAvailableRidesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Text(
              'Available Rides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to all rides
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Live ride feed with real-time updates
  Widget _buildRideList() {
    return Consumer<RideService>(
      builder: (context, rideService, child) {
        if (rideService.isLoading && rideService.availableRides.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 300,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        if (rideService.error != null) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load rides',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rideService.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadRides,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.surface,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (rideService.availableRides.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
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
                  Text(
                    'Be the first to offer a ride!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreateRide(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Ride'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final ride = rideService.availableRides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: RideCard(
                  ride: ride,
                  onTap: () => _navigateToRideDetails(ride),
                ),
              );
            },
            childCount: rideService.availableRides.length,
          ),
        );
      },
    );
  }

  /// Floating Action Button for creating rides
  Widget _buildCreateRideFAB() {
    return FloatingActionButton(
      onPressed: _navigateToCreateRide,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.surface,
      child: const Icon(Icons.add),
    );
  }

  void _navigateToCreateRide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRideScreen(),
      ),
    );
  }

  void _navigateToRideDetails(RideModel ride) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RideDetailsScreen(ride: ride),
      ),
    );
  }
}