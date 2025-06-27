import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Location picker widget for selecting pickup and destination locations
class LocationPicker extends StatefulWidget {
  final String? initialLocation;
  final String hintText;
  final ValueChanged<LocationSuggestion> onLocationSelected;
  final bool showCurrentLocation;

  const LocationPicker({
    Key? key,
    this.initialLocation,
    required this.hintText,
    required this.onLocationSelected,
    this.showCurrentLocation = true,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final LocationService _locationService = LocationService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialLocation ?? '';
    _loadInitialSuggestions();
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showSuggestions = true;
        });
        if (_suggestions.isEmpty) {
          _loadInitialSuggestions();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(),
        if (_showSuggestions) _buildSuggestionsList(),
      ],
    );
  }

  /// Build the search text field
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: _focusNode.hasFocus ? AppColors.primary : AppColors.border,
          width: _focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: _focusNode.hasFocus ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _isLoading 
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              : _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: _clearSearch,
                    )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// Build the suggestions list
  Widget _buildSuggestionsList() {
    return AnimatedContainer(
      duration: Duration(milliseconds: AppConstants.animationDurationMs),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          children: [
            if (widget.showCurrentLocation)
              _buildCurrentLocationTile(),
            ..._suggestions.map((suggestion) => _buildSuggestionTile(suggestion)),
            if (_suggestions.isEmpty && !_isLoading)
              _buildNoResultsTile(),
          ],
        ),
      ),
    );
  }

  /// Build current location tile
  Widget _buildCurrentLocationTile() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _useCurrentLocation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use current location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Get your precise location',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHint,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build suggestion tile
  Widget _buildSuggestionTile(LocationSuggestion suggestion) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectLocation(suggestion),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getLocationTypeColor(suggestion.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getLocationTypeIcon(suggestion.type),
                  color: _getLocationTypeColor(suggestion.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestion.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (suggestion.isCampusLocation)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Campus',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      suggestion.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (suggestion.description != null)
                      Text(
                        suggestion.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build no results tile
  Widget _buildNoResultsTile() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          const Text(
            'No locations found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try searching for a different location',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle search text changes
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _loadInitialSuggestions();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_controller.text == query) {
        _searchLocations(query);
      }
    });
  }

  /// Search for locations
  Future<void> _searchLocations(String query) async {
    try {
      final suggestions = await _locationService.searchLocations(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Load initial suggestions (campus and popular locations)
  Future<void> _loadInitialSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allLocations = await _locationService.getAllLocations();
      if (mounted) {
        setState(() {
          _suggestions = allLocations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Use current location
  Future<void> _useCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final coordinates = await _locationService.getCurrentLocation();
      final address = await _locationService.getAddressFromCoordinates(coordinates);

      final currentLocation = LocationSuggestion(
        id: 'current_location',
        name: 'Current Location',
        address: address,
        coordinates: coordinates,
        type: LocationType.other,
      );

      _selectLocation(currentLocation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Select a location
  void _selectLocation(LocationSuggestion location) {
    setState(() {
      _controller.text = location.name;
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    widget.onLocationSelected(location);
  }

  /// Clear search
  void _clearSearch() {
    setState(() {
      _controller.clear();
    });
    _loadInitialSuggestions();
  }

  /// Get location type icon
  IconData _getLocationTypeIcon(LocationType type) {
    switch (type) {
      case LocationType.campus:
        return Icons.school;
      case LocationType.residence:
        return Icons.home;
      case LocationType.shopping:
        return Icons.shopping_bag;
      case LocationType.transport:
        return Icons.directions_bus;
      case LocationType.entertainment:
        return Icons.local_movies;
      case LocationType.restaurant:
        return Icons.restaurant;
      case LocationType.other:
        return Icons.place;
    }
  }

  /// Get location type color
  Color _getLocationTypeColor(LocationType type) {
    switch (type) {
      case LocationType.campus:
        return AppColors.primary;
      case LocationType.residence:
        return AppColors.secondary;
      case LocationType.shopping:
        return AppColors.warning;
      case LocationType.transport:
        return AppColors.info;
      case LocationType.entertainment:
        return Colors.purple;
      case LocationType.restaurant:
        return Colors.orange;
      case LocationType.other:
        return AppColors.textSecondary;
    }
  }
}

/// Location selection screen (full screen)
class LocationSelectionScreen extends StatelessWidget {
  final String title;
  final String? initialLocation;
  final bool showCurrentLocation;

  const LocationSelectionScreen({
    Key? key,
    required this.title,
    this.initialLocation,
    this.showCurrentLocation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LocationPicker(
          initialLocation: initialLocation,
          hintText: 'Search for a location',
          showCurrentLocation: showCurrentLocation,
          onLocationSelected: (location) {
            Navigator.of(context).pop(location);
          },
        ),
      ),
    );
  }
}