import 'package:flutter/material.dart';
import 'dart:async';
import '../models/ride_model.dart';
import '../models/ride_request_model.dart';
import '../services/ride_service.dart';
import '../services/location_service.dart';
import '../widgets/ride_card.dart';
import '../constants/app_colors.dart';
import 'ride_details_screen.dart';
import 'create_ride_screen.dart';
import 'find_ride_screen.dart';

/// Home feed screen showing available rides with real-time updates
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final RideService _rideService = RideService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  
  late StreamSubscription<List<Ride>> _ridesSubscription;
  List<Ride> _allRides = [];
  List<Ride> _filteredRides = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _searchDebouncer;
  
  // Filter states
  RideTimeFilter _timeFilter = RideTimeFilter.all;
  double? _maxPrice;
  int? _minSeats;
  
  @override
  void initState() {
    super.initState();
    _initializeRideStream();
  }

  @override
  void dispose() {
    _ridesSubscription.cancel();
    _searchController.dispose();
    _searchDebouncer?.cancel();
    super.dispose();
  }

  void _initializeRideStream() {
    _ridesSubscription = _rideService.getAvailableRides().listen(
      (rides) {
        setState(() {
          _allRides = rides;
          _isLoading = false;
          _errorMessage = null;
        });
        _applyFilters();
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load rides: ${error.toString()}';
        });
      },
    );
  }

  void _applyFilters() {
    List<Ride> filtered = List.from(_allRides);
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((ride) {
        return ride.route.origin.address.toLowerCase().contains(query) ||
               ride.route.destination.address.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply time filter
    final now = DateTime.now();
    switch (_timeFilter) {
      case RideTimeFilter.now:
        final nextHour = now.add(const Duration(hours: 1));
        filtered = filtered.where((ride) {
          return ride.schedule.departureTime.isAfter(now) &&
                 ride.schedule.departureTime.isBefore(nextHour);
        }).toList();
        break;
      case RideTimeFilter.today:
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);
        filtered = filtered.where((ride) {
          return ride.schedule.departureTime.isAfter(now) &&
                 ride.schedule.departureTime.isBefore(endOfDay);
        }).toList();
        break;
      case RideTimeFilter.tomorrow:
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        final endOfTomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59);
        filtered = filtered.where((ride) {
          return ride.schedule.departureTime.isAfter(tomorrow) &&
                 ride.schedule.departureTime.isBefore(endOfTomorrow);
        }).toList();
        break;
      case RideTimeFilter.all:
        // No additional filtering
        break;
    }
    
    // Apply price filter
    if (_maxPrice != null) {
      filtered = filtered.where((ride) {
        return ride.pricing.pricePerSeat <= _maxPrice!;
      }).toList();
    }
    
    // Apply seats filter
    if (_minSeats != null) {
      filtered = filtered.where((ride) {
        return ride.capacity.availableSeats >= _minSeats!;
      }).toList();
    }
    
    // Sort by departure time
    filtered.sort((a, b) => a.schedule.departureTime.compareTo(b.schedule.departureTime));
    
    setState(() {
      _filteredRides = filtered;
    });
  }

  void _onSearchChanged(String query) {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  void _onTimeFilterChanged(RideTimeFilter filter) {
    setState(() {
      _timeFilter = filter;
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _timeFilter = RideTimeFilter.all;
      _maxPrice = null;
      _minSeats = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  Future<void> _refreshRides() async {
    setState(() {
      _isLoading = true;
    });
    // The stream will automatically update
  }

  void _navigateToRideDetails(Ride ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideDetailsScreen(rideId: ride.rideId),
      ),
    );
  }

  void _navigateToCreateRide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRideScreen(),
      ),
    );
  }

  void _navigateToFindRide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FindRideScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with greeting and location
            _buildHeader(),
            
            // Search bar
            _buildSearchBar(),
            
            // Filter chips
            _buildFilterChips(),
            
            // Rides list
            Expanded(
              child: _buildRidesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateRide,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Offer Ride'),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your ride around Stellenbosch',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _navigateToFindRide,
            icon: const Icon(Icons.search),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by location...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final hasActiveFilters = _timeFilter != RideTimeFilter.all || 
                            _maxPrice != null || 
                            _minSeats != null;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTimeFilterChip('All', RideTimeFilter.all),
          const SizedBox(width: 8),
          _buildTimeFilterChip('Now', RideTimeFilter.now),
          const SizedBox(width: 8),
          _buildTimeFilterChip('Today', RideTimeFilter.today),
          const SizedBox(width: 8),
          _buildTimeFilterChip('Tomorrow', RideTimeFilter.tomorrow),
          const SizedBox(width: 16),
          _buildPriceFilterChip(),
          const SizedBox(width: 8),
          _buildSeatsFilterChip(),
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            _buildClearFiltersChip(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, RideTimeFilter filter) {
    final isSelected = _timeFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onTimeFilterChanged(filter),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildPriceFilterChip() {
    return ActionChip(
      label: Text(_maxPrice != null ? 'Under R${_maxPrice!.toInt()}' : 'Price'),
      avatar: Icon(
        Icons.attach_money,
        size: 18,
        color: _maxPrice != null ? AppColors.primary : AppColors.textSecondary,
      ),
      onPressed: _showPriceFilter,
      backgroundColor: _maxPrice != null 
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.surface,
      labelStyle: TextStyle(
        color: _maxPrice != null ? AppColors.primary : AppColors.textSecondary,
        fontWeight: _maxPrice != null ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSeatsFilterChip() {
    return ActionChip(
      label: Text(_minSeats != null ? '${_minSeats}+ seats' : 'Seats'),
      avatar: Icon(
        Icons.people,
        size: 18,
        color: _minSeats != null ? AppColors.primary : AppColors.textSecondary,
      ),
      onPressed: _showSeatsFilter,
      backgroundColor: _minSeats != null 
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.surface,
      labelStyle: TextStyle(
        color: _minSeats != null ? AppColors.primary : AppColors.textSecondary,
        fontWeight: _minSeats != null ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildClearFiltersChip() {
    return ActionChip(
      label: const Text('Clear'),
      avatar: const Icon(Icons.clear, size: 18),
      onPressed: _clearFilters,
      backgroundColor: AppColors.accent.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRidesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshRides,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredRides.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshRides,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: _buildEmptyState(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshRides,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Space for FAB
        itemCount: _filteredRides.length,
        itemBuilder: (context, index) {
          final ride = _filteredRides[index];
          return RideCard(
            ride: ride,
            onTap: () => _navigateToRideDetails(ride),
            onBookPressed: () => _navigateToRideDetails(ride),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _timeFilter != RideTimeFilter.all || 
                      _maxPrice != null || 
                      _minSeats != null ||
                      _searchController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.directions_car_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No rides match your filters' : 'No rides available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters 
                ? 'Try adjusting your search criteria'
                : 'Be the first to offer a ride!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          if (hasFilters)
            OutlinedButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            )
          else
            ElevatedButton(
              onPressed: _navigateToCreateRide,
              child: const Text('Offer a Ride'),
            ),
        ],
      ),
    );
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _PriceFilterSheet(
        currentMaxPrice: _maxPrice,
        onPriceChanged: (price) {
          setState(() {
            _maxPrice = price;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showSeatsFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SeatsFilterSheet(
        currentMinSeats: _minSeats,
        onSeatsChanged: (seats) {
          setState(() {
            _minSeats = seats;
          });
          _applyFilters();
        },
      ),
    );
  }
}

enum RideTimeFilter { all, now, today, tomorrow }

class _PriceFilterSheet extends StatefulWidget {
  final double? currentMaxPrice;
  final Function(double?) onPriceChanged;

  const _PriceFilterSheet({
    required this.currentMaxPrice,
    required this.onPriceChanged,
  });

  @override
  State<_PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<_PriceFilterSheet> {
  late double _selectedPrice;

  @override
  void initState() {
    super.initState();
    _selectedPrice = widget.currentMaxPrice ?? 50.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Maximum Price',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  widget.onPriceChanged(null);
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'R${_selectedPrice.toInt()} per seat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedPrice,
            min: 10,
            max: 200,
            divisions: 19,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _selectedPrice = value;
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onPriceChanged(_selectedPrice);
                Navigator.pop(context);
              },
              child: const Text('Apply Filter'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatsFilterSheet extends StatelessWidget {
  final int? currentMinSeats;
  final Function(int?) onSeatsChanged;

  const _SeatsFilterSheet({
    required this.currentMinSeats,
    required this.onSeatsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Minimum Available Seats',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  onSeatsChanged(null);
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(4, (index) {
            final seats = index + 1;
            final isSelected = currentMinSeats == seats;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.people,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
                title: Text('${seats} or more seats'),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                selected: isSelected,
                selectedTileColor: AppColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {
                  onSeatsChanged(seats);
                  Navigator.pop(context);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}