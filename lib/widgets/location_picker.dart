import 'package:flutter/material.dart';
import 'dart:async';
import '../services/location_service.dart';

/// A widget for picking locations with autocomplete functionality
class LocationPicker extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final String? labelText;
  final bool showCampusLocations;
  final Function(LocationSuggestion) onLocationSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const LocationPicker({
    Key? key,
    this.initialValue,
    this.hintText = 'Enter location',
    this.labelText,
    this.showCampusLocations = true,
    required this.onLocationSelected,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LocationService _locationService = LocationService();
  
  List<LocationSuggestion> _suggestions = [];
  List<LocationSuggestion> _campusLocations = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
    _loadCampusLocations();
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showSuggestions = true;
        if (_controller.text.isEmpty && widget.showCampusLocations) {
          _suggestions = _campusLocations;
        }
        setState(() {});
      } else {
        // Small delay to allow tap on suggestions
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _showSuggestions = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCampusLocations() async {
    if (widget.showCampusLocations) {
      try {
        final locations = await _locationService.getCampusLocations();
        setState(() {
          _campusLocations = locations;
        });
      } catch (e) {
        // Handle error silently for now
      }
    }
  }

  void _onTextChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = widget.showCampusLocations ? _campusLocations : [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _searchLocations(query);
    });
  }

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

  void _selectLocation(LocationSuggestion location) {
    _controller.text = location.address;
    _focusNode.unfocus();
    widget.onLocationSelected(location);
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null 
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _suggestions = widget.showCampusLocations 
                                ? _campusLocations 
                                : [];
                          });
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: _onTextChanged,
          validator: widget.validator,
        ),
        
        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Card(
              elevation: 4,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return _buildSuggestionItem(suggestion);
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestionItem(LocationSuggestion suggestion) {
    return InkWell(
      onTap: () => _selectLocation(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getLocationTypeColor(suggestion.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getLocationTypeIcon(suggestion.type),
                size: 20,
                color: _getLocationTypeColor(suggestion.type),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.address,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (suggestion.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (suggestion.isCampusLocation)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Campus',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getLocationTypeIcon(LocationType type) {
    switch (type) {
      case LocationType.campus:
        return Icons.school;
      case LocationType.residence:
        return Icons.home;
      case LocationType.academic:
        return Icons.menu_book;
      case LocationType.shopping:
        return Icons.shopping_bag;
      case LocationType.transport:
        return Icons.directions_bus;
      case LocationType.restaurant:
        return Icons.restaurant;
      case LocationType.other:
        return Icons.place;
    }
  }

  Color _getLocationTypeColor(LocationType type) {
    switch (type) {
      case LocationType.campus:
        return const Color(0xFF2563EB);
      case LocationType.residence:
        return const Color(0xFF059669);
      case LocationType.academic:
        return const Color(0xFF7C3AED);
      case LocationType.shopping:
        return const Color(0xFFEA580C);
      case LocationType.transport:
        return const Color(0xFF0891B2);
      case LocationType.restaurant:
        return const Color(0xFFDC2626);
      case LocationType.other:
        return const Color(0xFF6B7280);
    }
  }
}

/// Simple location input field without autocomplete
class SimpleLocationInput extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final String? labelText;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const SimpleLocationInput({
    Key? key,
    this.initialValue,
    this.hintText = 'Enter location',
    this.labelText,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<SimpleLocationInput> createState() => _SimpleLocationInputState();
}

class _SimpleLocationInputState extends State<SimpleLocationInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null 
            ? Icon(widget.prefixIcon)
            : null,
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}

/// Quick location selection buttons for common destinations
class QuickLocationButtons extends StatelessWidget {
  final Function(LocationSuggestion) onLocationSelected;
  final LocationService _locationService = LocationService();

  QuickLocationButtons({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LocationSuggestion>>(
      future: _locationService.getPopularDestinations(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final destinations = snapshot.data!.take(6).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular Destinations',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: destinations.map((destination) {
                return ActionChip(
                  onPressed: () => onLocationSelected(destination),
                  label: Text(
                    destination.address.length > 20
                        ? '${destination.address.substring(0, 20)}...'
                        : destination.address,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}