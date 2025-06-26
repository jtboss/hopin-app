import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';
import '../services/location_service.dart';
import '../widgets/location_picker.dart';
import '../constants/app_colors.dart';

/// Screen for drivers to create new ride offers
class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({Key? key}) : super(key: key);

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final RideService _rideService = RideService();
  final LocationService _locationService = LocationService();
  
  // Form controllers
  final TextEditingController _notesController = TextEditingController();
  
  // Form state
  LocationSuggestion? _originLocation;
  LocationSuggestion? _destinationLocation;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  int _estimatedDuration = 30;
  double _pricePerSeat = 25.0;
  int _totalSeats = 2;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createRide() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_originLocation == null) {
      _showError('Please select a pickup location');
      return;
    }

    if (_destinationLocation == null) {
      _showError('Please select a destination');
      return;
    }

    if (_departureDate == null || _departureTime == null) {
      _showError('Please select departure date and time');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Combine date and time
      final departureDateTime = DateTime(
        _departureDate!.year,
        _departureDate!.month,
        _departureDate!.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );

      // Create the ride request
      final request = CreateRideRequest(
        driverId: 'current_user_id', // TODO: Get from auth service
        driverName: 'Current User', // TODO: Get from auth service
        driverRating: 4.5, // TODO: Get from user profile
        origin: RideLocation(
          address: _originLocation!.address,
          coordinates: _originLocation!.coordinates ?? 
              const GeoPoint(-33.9316, 18.8648), // Default to main campus
        ),
        destination: RideLocation(
          address: _destinationLocation!.address,
          coordinates: _destinationLocation!.coordinates ?? 
              const GeoPoint(-33.9316, 18.8648), // Default to main campus
        ),
        departureTime: departureDateTime,
        estimatedDuration: _estimatedDuration,
        pricePerSeat: _pricePerSeat,
        totalSeats: _totalSeats,
        additionalNotes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      final result = await _rideService.createRide(request);
      
      if (result.isSuccess) {
        // Show success message
        _showSuccessDialog();
      } else {
        _showError(result.error!);
      }
    } catch (e) {
      _showError('Failed to create ride: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Ride Created!'),
          ],
        ),
        content: const Text(
          'Your ride offer has been created successfully. Students can now find and request to join your ride.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _departureDate ?? now;
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _departureDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final initialTime = _departureTime ?? 
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
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
        title: const Text('Offer a Ride'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Text(
              'Create your ride offer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help fellow students get around Stellenbosch',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Route Section
            _buildSectionHeader('Route', Icons.route),
            const SizedBox(height: 16),
            
            LocationPicker(
              labelText: 'Pickup Location',
              hintText: 'Where will you pick up passengers?',
              prefixIcon: Icons.my_location,
              onLocationSelected: (location) {
                setState(() {
                  _originLocation = location;
                });
              },
              validator: (value) {
                if (_originLocation == null) {
                  return 'Please select a pickup location';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            LocationPicker(
              labelText: 'Destination',
              hintText: 'Where are you going?',
              prefixIcon: Icons.place,
              onLocationSelected: (location) {
                setState(() {
                  _destinationLocation = location;
                });
              },
              validator: (value) {
                if (_destinationLocation == null) {
                  return 'Please select a destination';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Schedule Section
            _buildSectionHeader('Schedule', Icons.schedule),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeSelector(
                    label: 'Date',
                    value: _departureDate != null ? _formatDate(_departureDate!) : null,
                    hint: 'Select date',
                    icon: Icons.calendar_today,
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateTimeSelector(
                    label: 'Time',
                    value: _departureTime != null ? _formatTime(_departureTime!) : null,
                    hint: 'Select time',
                    icon: Icons.access_time,
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildDurationSelector(),

            const SizedBox(height: 24),

            // Pricing & Capacity Section
            _buildSectionHeader('Pricing & Capacity', Icons.people),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildPriceSelector(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSeatsSelector(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Additional Notes Section
            _buildSectionHeader('Additional Notes', Icons.note),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: 'Any additional information for passengers? (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            // Create Ride Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                        'Create Ride Offer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value != null 
                          ? AppColors.textPrimary 
                          : AppColors.textTertiary,
                      fontWeight: value != null 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Duration',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_estimatedDuration} minutes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: _estimatedDuration.toDouble(),
          min: 10,
          max: 180,
          divisions: 17,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _estimatedDuration = value.round();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '10 min',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '3 hours',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price per Seat',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surface,
          ),
          child: Column(
            children: [
              Text(
                'R${_pricePerSeat.toInt()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _pricePerSeat,
                min: 10,
                max: 100,
                divisions: 18,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _pricePerSeat = value;
                  });
                },
              ),
              Text(
                'R15-R30 recommended',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Seats',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surface,
          ),
          child: Column(
            children: [
              Text(
                '$_totalSeats seats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final seatNumber = index + 1;
                  final isSelected = _totalSeats == seatNumber;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _totalSeats = seatNumber;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary 
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Text(
                        '$seatNumber',
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}