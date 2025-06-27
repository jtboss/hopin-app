import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ride_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Uber-style ride card widget
class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;
  final VoidCallback? onRequestRide;
  final bool showRequestButton;

  const RideCard({
    Key? key,
    required this.ride,
    this.onTap,
    this.onRequestRide,
    this.showRequestButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDriverInfoRow(),
                const SizedBox(height: 16),
                _buildRouteInfo(),
                const SizedBox(height: 16),
                _buildBottomInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build driver information row
  Widget _buildDriverInfoRow() {
    return Row(
      children: [
        _buildDriverAvatar(),
        const SizedBox(width: 12),
        Expanded(child: _buildDriverDetails()),
        _buildPriceInfo(),
      ],
    );
  }

  /// Build driver avatar with gradient background
  Widget _buildDriverAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          ride.driverInfo.name.isNotEmpty 
              ? ride.driverInfo.name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Build driver details with name and rating
  Widget _buildDriverDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ride.driverInfo.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              ride.driverInfo.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            if (ride.driverInfo.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Build price information
  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${AppConstants.currencySymbol}${ride.pricing.pricePerSeat.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Text(
          'per seat',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build route information with origin and destination
  Widget _buildRouteInfo() {
    return Row(
      children: [
        _buildRouteIndicator(),
        const SizedBox(width: 16),
        Expanded(child: _buildRouteAddresses()),
        _buildRouteTime(),
      ],
    );
  }

  /// Build route indicator with dots and line
  Widget _buildRouteIndicator() {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Container(
          width: 2,
          height: 24,
          color: AppColors.textHint,
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  /// Build route addresses
  Widget _buildRouteAddresses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ride.route.origin.address,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Text(
          ride.route.destination.address,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Build route time information
  Widget _buildRouteTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTime(ride.schedule.departureTime),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${ride.capacity.availableSeats} seat${ride.capacity.availableSeats != 1 ? 's' : ''} left',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build bottom information row
  Widget _buildBottomInfo() {
    return Row(
      children: [
        _buildStatusChip(),
        const Spacer(),
        if (ride.notes != null && ride.notes!.isNotEmpty)
          _buildNotesIndicator(),
        if (showRequestButton && ride.isBookable)
          _buildRequestButton(),
      ],
    );
  }

  /// Build status chip
  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (ride.status) {
      case RideStatus.active:
        chipColor = AppColors.success;
        statusText = 'Available';
        break;
      case RideStatus.full:
        chipColor = AppColors.warning;
        statusText = 'Full';
        break;
      case RideStatus.completed:
        chipColor = AppColors.textSecondary;
        statusText = 'Completed';
        break;
      case RideStatus.cancelled:
        chipColor = AppColors.error;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  /// Build notes indicator
  Widget _buildNotesIndicator() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.note_outlined,
        size: 16,
        color: AppColors.info,
      ),
    );
  }

  /// Build request ride button
  Widget _buildRequestButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: AppConstants.animationDurationMs),
      child: ElevatedButton(
        onPressed: onRequestRide,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
        child: const Text(
          'Request',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final rideDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeFormat = DateFormat('HH:mm');

    if (rideDate == today) {
      return 'Today ${timeFormat.format(dateTime)}';
    } else if (rideDate == tomorrow) {
      return 'Tomorrow ${timeFormat.format(dateTime)}';
    } else {
      final dateFormat = DateFormat('MMM d');
      return '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)}';
    }
  }
}

/// Compact version of ride card for lists
class CompactRideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;

  const CompactRideCard({
    Key? key,
    required this.ride,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      ride.driverInfo.name.isNotEmpty 
                          ? ride.driverInfo.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ride.route.origin.address} → ${ride.route.destination.address}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(ride.schedule.departureTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${AppConstants.currencySymbol}${ride.pricing.pricePerSeat.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final rideDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeFormat = DateFormat('HH:mm');

    if (rideDate == today) {
      return 'Today ${timeFormat.format(dateTime)}';
    } else if (rideDate == tomorrow) {
      return 'Tomorrow ${timeFormat.format(dateTime)}';
    } else {
      final dateFormat = DateFormat('MMM d');
      return '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)}';
    }
  }
}