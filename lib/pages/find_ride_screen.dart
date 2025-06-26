import 'package:flutter/material.dart';
import 'dart:async';
import '../models/ride_model.dart';
import '../services/ride_service.dart';
import '../services/location_service.dart';
import '../widgets/ride_card.dart';
import '../widgets/location_picker.dart';
import '../constants/app_colors.dart';
import 'ride_details_screen.dart';

/// Enhanced search screen for finding rides with advanced filters
class FindRideScreen extends StatefulWidget {
  const FindRideScreen({Key? key}) : super(key: key);

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  final RideService _rideService = RideService();
  final LocationService _locationService = LocationService();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  List<Ride> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  Timer? _searchDebouncer;
  
  // Search filters
  LocationSuggestion? _originLocation;
  LocationSuggestion? _destinationLocation;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  double? _maxPrice;
  int? _minSeats;
  RideSortOption _sortOption = RideSortOption.departureTime;
  
  // UI state
  bool _showAdvancedFilters = false;
  SearchViewMode _viewMode = SearchViewMode.list;
  
  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _searchDebouncer?.cancel();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Build search criteria
      DateTime? fromDate;
      DateTime? toDate;
      
      if (_departureDate != null) {
        if (_departureTime != null) {
          // Specific date and time
          fromDate = DateTime(
            _departureDate!.year,
            _departureDate!.month,
            _departureDate!.day,
            _departureTime!.hour,
            _departureTime!.minute,
          );
          toDate = fromDate.add(const Duration(hours: 2)); // 2-hour window
        } else {
          // Entire day
          fromDate = DateTime(_departureDate!.year, _departureDate!.month, _departureDate!.day);
          toDate = DateTime(_departureDate!.year, _departureDate!.month, _departureDate!.day, 23, 59);
        }
      }

      // Get rides from service
      final rides = await _rideService.getAvailableRides(
        fromLocation: _originLocation?.address,
        toLocation: _destinationLocation?.address,
        fromDate: fromDate,
        toDate: toDate,
        maxPrice: _maxPrice,
        minSeats: _minSeats,
      ).first; // Convert stream to single result

      // Apply client-side filtering for more precise search
      List<Ride> filteredRides = List.from(rides);
      
      // Filter by origin if specified
      if (_originLocation != null) {
        filteredRides = filteredRides.where((ride) {
          return ride.route.origin.address.toLowerCase()
              .contains(_originLocation!.address.toLowerCase());
        }).toList();
      }
      
      // Filter by destination if specified
      if (_destinationLocation != null) {
        filteredRides = filteredRides.where((ride) {
          return ride.route.destination.address.toLowerCase()
              .contains(_destinationLocation!.address.toLowerCase());
        }).toList();
      }

      // Apply sorting
      _applySorting(filteredRides);

      setState(() {
        _searchResults = filteredRides;
        _hasSearched = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Search failed: ${e.toString()}';
      });
    }
  }

  void _applySorting(List<Ride> rides) {
    switch (_sortOption) {
      case RideSortOption.departureTime:
        rides.sort((a, b) => a.schedule.departureTime.compareTo(b.schedule.departureTime));
        break;
      case RideSortOption.price:
        rides.sort((a, b) => a.pricing.pricePerSeat.compareTo(b.pricing.pricePerSeat));
        break;
      case RideSortOption.availableSeats:
        rides.sort((a, b) => b.capacity.availableSeats.compareTo(a.capacity.availableSeats));
        break;
      case RideSortOption.driverRating:
        rides.sort((a, b) => b.driverInfo.rating.compareTo(a.driverInfo.rating));
        break;
    }
  }

  void _clearSearch() {
    setState(() {
      _originController.clear();
      _destinationController.clear();
      _originLocation = null;
      _destinationLocation = null;
      _departureDate = null;
      _departureTime = null;
      _maxPrice = null;
      _minSeats = null;
      _sortOption = RideSortOption.departureTime;
      _searchResults = [];
      _hasSearched = false;
      _errorMessage = null;
    });
  }

  void _navigateToRideDetails(Ride ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideDetailsScreen(rideId: ride.rideId),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        _departureDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _departureTime = time;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Today';
    } else if (date.day == now.day + 1 && date.month == now.month && date.year == now.year) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find Rides'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear search',
          ),
          PopupMenuButton<SearchViewMode>(
            onSelected: (mode) {
              setState(() {
                _viewMode = mode;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SearchViewMode.list,
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('List View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SearchViewMode.map,
                child: Row(
                  children: [
                    Icon(Icons.map),
                    SizedBox(width: 8),
                    Text('Map View'),
                  ],
                ),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _viewMode == SearchViewMode.list ? Icons.list : Icons.map,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search form
          _buildSearchForm(),
          
          // Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Origin and destination
          Row(
            children: [
              Expanded(
                child: LocationPicker(
                  hintText: 'From where?',
                  prefixIcon: Icons.my_location,
                  onLocationSelected: (location) {
                    setState(() {
                      _originLocation = location;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LocationPicker(
                  hintText: 'To where?',
                  prefixIcon: Icons.place,
                  onLocationSelected: (location) {
                    setState(() {
                      _destinationLocation = location;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search button and advanced filters toggle
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Search Rides',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = !_showAdvancedFilters;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Icon(
                  _showAdvancedFilters 
                      ? Icons.keyboard_arrow_up 
                      : Icons.tune,
                ),
              ),
            ],
          ),
          
          // Advanced filters
          if (_showAdvancedFilters) ...[
            const SizedBox(height: 16),
            _buildAdvancedFilters(),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Filters',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Date and time filters
        Row(
          children: [
            Expanded(
              child: _buildFilterButton(
                label: 'Date',
                value: _departureDate != null ? _formatDate(_departureDate!) : null,
                hint: 'Any date',
                icon: Icons.calendar_today,
                onTap: _selectDate,
                onClear: () => setState(() => _departureDate = null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFilterButton(
                label: 'Time',
                value: _departureTime != null ? _formatTime(_departureTime!) : null,
                hint: 'Any time',
                icon: Icons.access_time,
                onTap: _selectTime,
                onClear: () => setState(() => _departureTime = null),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Price and seats filters
        Row(
          children: [
            Expanded(
              child: _buildFilterButton(
                label: 'Max Price',
                value: _maxPrice != null ? 'R${_maxPrice!.toInt()}' : null,
                hint: 'Any price',
                icon: Icons.attach_money,
                onTap: _showPriceFilter,
                onClear: () => setState(() => _maxPrice = null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFilterButton(
                label: 'Min Seats',
                value: _minSeats != null ? '${_minSeats}+ seats' : null,
                hint: 'Any seats',
                icon: Icons.people,
                onTap: _showSeatsFilter,
                onClear: () => setState(() => _minSeats = null),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Sort options
        _buildSortOptions(),
      ],
    );
  }

  Widget _buildFilterButton({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: value != null ? AppColors.primary : AppColors.borderLight,
              ),
              borderRadius: BorderRadius.circular(8),
              color: value != null 
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.surface,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: value != null ? AppColors.primary : AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value != null ? AppColors.primary : AppColors.textTertiary,
                      fontSize: 14,
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (value != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort by',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: RideSortOption.values.map((option) {
            final isSelected = _sortOption == option;
            return FilterChip(
              label: Text(_getSortOptionLabel(option)),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _sortOption = option;
                });
                if (_hasSearched) {
                  _applySorting(_searchResults);
                  setState(() {});
                }
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withOpacity(0.1),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
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
              'Search failed',
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
              onPressed: _performSearch,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildSearchPrompt();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    if (_viewMode == SearchViewMode.map) {
      return _buildMapView();
    }

    return _buildListView();
  }

  Widget _buildSearchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Find your perfect ride',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your pickup and destination to search for available rides',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No rides found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria or check back later',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showAdvancedFilters = true;
              });
            },
            child: const Text('Adjust Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Results header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${_searchResults.length} rides found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Sorted by ${_getSortOptionLabel(_sortOption).toLowerCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Results list
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final ride = _searchResults[index];
              return RideCard(
                ride: ride,
                onTap: () => _navigateToRideDetails(ride),
                onBookPressed: () => _navigateToRideDetails(ride),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Map View',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Map integration coming soon!\nFor now, showing ${_searchResults.length} rides in list format.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _viewMode = SearchViewMode.list;
              });
            },
            child: const Text('Switch to List View'),
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
        },
      ),
    );
  }

  String _getSortOptionLabel(RideSortOption option) {
    switch (option) {
      case RideSortOption.departureTime:
        return 'Departure Time';
      case RideSortOption.price:
        return 'Price';
      case RideSortOption.availableSeats:
        return 'Available Seats';
      case RideSortOption.driverRating:
        return 'Driver Rating';
    }
  }
}

enum RideSortOption {
  departureTime,
  price,
  availableSeats,
  driverRating,
}

enum SearchViewMode {
  list,
  map,
}

// Filter bottom sheets (reused from home feed)
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