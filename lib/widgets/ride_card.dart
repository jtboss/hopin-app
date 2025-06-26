import 'package:flutter/material.dart';
import '../models/ride_model.dart';

/// A card widget to display ride information
class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;
  final bool showBookButton;
  final VoidCallback? onBookPressed;
  final bool isLoading;

  const RideCard({
    Key? key,
    required this.ride,
    this.onTap,
    this.showBookButton = true,
    this.onBookPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with driver info and status
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _getPrimaryColor(context),
                    child: Text(
                      ride.driverInfo.name.isNotEmpty 
                          ? ride.driverInfo.name[0].toUpperCase()
                          : 'D',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driverInfo.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ride.driverInfo.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),

              const SizedBox(height: 16),

              // Route information
              _buildRouteInfo(context),

              const SizedBox(height: 16),

              // Time, price, and seats info
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.schedule,
                    label: ride.formattedDepartureTime,
                    color: _getPrimaryColor(context),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    icon: Icons.attach_money,
                    label: 'R${ride.pricing.pricePerSeat.toStringAsFixed(0)}',
                    color: _getSecondaryColor(context),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    icon: Icons.people,
                    label: _getSeatsText(),
                    color: ride.capacity.hasAvailableSeats 
                        ? _getSecondaryColor(context)
                        : Colors.red.shade600,
                  ),
                ],
              ),

              if (showBookButton && ride.isAvailable) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onBookPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPrimaryColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Request Ride',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getSecondaryColor(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.route.origin.address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(left: 6),
          child: Column(
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 22),
                  Text(
                    '${ride.schedule.estimatedDuration} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.route.destination.address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
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

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (ride.status) {
      case RideStatus.active:
        backgroundColor = _getSecondaryColor(context).withOpacity(0.1);
        textColor = _getSecondaryColor(context);
        statusText = 'Active';
        break;
      case RideStatus.full:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        statusText = 'Full';
        break;
      case RideStatus.completed:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        statusText = 'Completed';
        break;
      case RideStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getSeatsText() {
    final available = ride.capacity.availableSeats;
    final total = ride.capacity.totalSeats;
    
    if (available == 0) {
      return 'Full';
    } else if (available == 1) {
      return '1 seat left';
    } else {
      return '$available/$total seats';
    }
  }

  // Color theme helpers - these would typically come from app theme
  Color _getPrimaryColor(BuildContext context) {
    return const Color(0xFF2563EB); // Blue from implementation guide
  }

  Color _getSecondaryColor(BuildContext context) {
    return const Color(0xFF059669); // Green from implementation guide
  }
}

/// Compact version of RideCard for lists with many items
class CompactRideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;
  final bool isLoading;

  const CompactRideCard({
    Key? key,
    required this.ride,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Route column
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.route.origin.address,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ride.route.destination.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Time and price column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ride.formattedDepartureTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'R${ride.pricing.pricePerSeat.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getSecondaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // Status indicator
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: ride.isAvailable 
                      ? _getSecondaryColor(context)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPrimaryColor(BuildContext context) {
    return const Color(0xFF2563EB);
  }

  Color _getSecondaryColor(BuildContext context) {
    return const Color(0xFF059669);
  }
}