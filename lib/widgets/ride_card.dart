import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/ride_model.dart';

/// Reusable ride card widget for displaying ride information
class RideCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback? onTap;
  final bool showRequestButton;
  final bool isCompact;

  const RideCard({
    super.key,
    required this.ride,
    this.onTap,
    this.showRequestButton = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver info and ride status
              _buildDriverHeader(),
              
              const SizedBox(height: 12),
              
              // Route information
              _buildRouteInfo(),
              
              const SizedBox(height: 12),
              
              // Ride details (time, price, seats)
              _buildRideDetails(),
              
              if (!isCompact) ...[
                const SizedBox(height: 12),
                
                // Action buttons
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverHeader() {
    return Row(
      children: [
        // Driver avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.getAvatarColor(ride.driver.uid),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              _getInitials(ride.driver.firstName, ride.driver.lastName),
              style: const TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Driver name and rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride.driver.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 14,
                    color: AppColors.ratingStar,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ride.driver.displayRating,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (ride.driver.isVerified)
                    Icon(
                      Icons.verified,
                      size: 14,
                      color: AppColors.verified,
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // Ride status badge
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final Color statusColor = AppColors.getRideStatusColor(ride.status.name);
    final String statusText = _getStatusText(ride.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Column(
      children: [
        // Pickup location
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.mapPickup,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.route.pickup.address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Route line
        Row(
          children: [
            const SizedBox(width: 4),
            Container(
              width: 1,
              height: 20,
              color: AppColors.divider,
            ),
            const SizedBox(width: 11),
            Text(
              '${ride.route.estimatedDuration.inMinutes} min • ${ride.route.estimatedDistance.toStringAsFixed(1)} km',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Destination location
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.mapDestination,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.route.destination.address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRideDetails() {
    final departureTime = DateFormat('HH:mm').format(ride.departureTime);
    final departureDate = DateFormat('MMM dd').format(ride.departureTime);
    
    return Row(
      children: [
        // Time
        _buildDetailItem(
          icon: Icons.schedule,
          label: departureTime,
          subtitle: departureDate,
        ),
        
        const SizedBox(width: 16),
        
        // Price
        _buildDetailItem(
          icon: Icons.payment,
          label: 'R${ride.pricePerSeat.toStringAsFixed(0)}',
          subtitle: 'per seat',
        ),
        
        const SizedBox(width: 16),
        
        // Available seats
        _buildDetailItem(
          icon: Icons.airline_seat_recline_normal,
          label: '${ride.availableSeats}',
          subtitle: 'seats left',
        ),
        
        const Spacer(),
        
        // Car info (if available)
        if (ride.driver.carDetails != null)
          _buildCarInfo(),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCarInfo() {
    final car = ride.driver.carDetails!;
    return Column(
      children: [
        Icon(
          Icons.directions_car,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          car.make,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          car.color,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (!showRequestButton) return const SizedBox.shrink();

    return Row(
      children: [
        // Message driver button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messaging feature coming soon!')),
              );
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: 16,
            ),
            label: const Text('Message'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Request ride button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: ride.availableSeats > 0 ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request ride feature coming soon!')),
              );
            } : null,
            icon: const Icon(
              Icons.add,
              size: 16,
            ),
            label: Text(
              ride.availableSeats > 0 ? 'Request' : 'Full',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              disabledBackgroundColor: AppColors.disabled,
              disabledForegroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.active:
        return 'Active';
      case RideStatus.full:
        return 'Full';
      case RideStatus.inProgress:
        return 'In Progress';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}