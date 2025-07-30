import 'package:flutter/material.dart';
import '../../../../constants/app_constants.dart';
import '../../../../widgets/custom_button.dart';

class ReservationsTab extends StatefulWidget {
  const ReservationsTab({super.key});

  @override
  State<ReservationsTab> createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<ReservationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with actual API call when backend is ready
      // final reservations = await _apiService.getUserReservations();
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // Handle error
      print('Error loading reservations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Reservations',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveReservations(),
          _buildUpcomingReservations(),
          _buildReservationHistory(),
        ],
      ),
    );
  }

  Widget _buildActiveReservations() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Load active reservations from API
    // TODO: Replace with actual API call when backend is ready
    final activeReservations = [
      {
        'id': '1',
        'parkingName': 'Central Parking',
        'address': '123 Main Street, City',
        'startTime': DateTime.now().subtract(const Duration(hours: 2)),
        'endTime': DateTime.now().add(const Duration(hours: 2)),
        'totalAmount': 20.0,
        'status': 'active',
      },
    ];

    if (activeReservations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.play_circle_outline,
        title: 'No Active Reservations',
        subtitle: 'You don\'t have any active parking reservations',
        actionText: 'Book Parking',
        onAction: () {
          Navigator.of(context).pushNamed(AppRoutes.map);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: activeReservations.length,
      itemBuilder: (context, index) {
        final reservation = activeReservations[index];
        return _buildReservationCard(reservation, 'active');
      },
    );
  }

  Widget _buildUpcomingReservations() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Load upcoming reservations from API
    // TODO: Replace with actual API call when backend is ready
    final upcomingReservations = [
      {
        'id': '2',
        'parkingName': 'Downtown Parking',
        'address': '456 Oak Avenue, City',
        'startTime': DateTime.now().add(const Duration(days: 1)),
        'endTime': DateTime.now().add(const Duration(days: 1, hours: 3)),
        'totalAmount': 15.0,
        'status': 'confirmed',
      },
      {
        'id': '3',
        'parkingName': 'Shopping Center Parking',
        'address': '789 Pine Street, City',
        'startTime': DateTime.now().add(const Duration(days: 3)),
        'endTime': DateTime.now().add(const Duration(days: 3, hours: 2)),
        'totalAmount': 10.0,
        'status': 'confirmed',
      },
    ];

    if (upcomingReservations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.schedule,
        title: 'No Upcoming Reservations',
        subtitle: 'You don\'t have any upcoming parking reservations',
        actionText: 'Book Parking',
        onAction: () {
          Navigator.of(context).pushNamed(AppRoutes.map);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: upcomingReservations.length,
      itemBuilder: (context, index) {
        final reservation = upcomingReservations[index];
        return _buildReservationCard(reservation, 'upcoming');
      },
    );
  }

  Widget _buildReservationHistory() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Load reservation history from API
    // TODO: Replace with actual API call when backend is ready
    final reservationHistory = [
      {
        'id': '4',
        'parkingName': 'Central Parking',
        'address': '123 Main Street, City',
        'startTime': DateTime.now().subtract(const Duration(days: 7)),
        'endTime': DateTime.now().subtract(const Duration(days: 7, hours: -3)),
        'totalAmount': 15.0,
        'status': 'completed',
      },
      {
        'id': '5',
        'parkingName': 'Downtown Parking',
        'address': '456 Oak Avenue, City',
        'startTime': DateTime.now().subtract(const Duration(days: 14)),
        'endTime': DateTime.now().subtract(const Duration(days: 14, hours: -2)),
        'totalAmount': 10.0,
        'status': 'completed',
      },
      {
        'id': '6',
        'parkingName': 'Shopping Center Parking',
        'address': '789 Pine Street, City',
        'startTime': DateTime.now().subtract(const Duration(days: 21)),
        'endTime': DateTime.now().subtract(const Duration(days: 21, hours: -4)),
        'totalAmount': 20.0,
        'status': 'cancelled',
      },
    ];

    if (reservationHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Reservation History',
        subtitle: 'Your parking history will appear here',
        actionText: 'Book Parking',
        onAction: () {
          Navigator.of(context).pushNamed(AppRoutes.map);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: reservationHistory.length,
      itemBuilder: (context, index) {
        final reservation = reservationHistory[index];
        return _buildReservationCard(reservation, 'history');
      },
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation, String type) {
    final status = reservation['status'] as String;
    final startTime = reservation['startTime'] as DateTime;
    final endTime = reservation['endTime'] as DateTime;
    final duration = endTime.difference(startTime);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'active':
        statusColor = AppColors.success;
        statusText = 'Active';
        statusIcon = Icons.play_circle;
        break;
      case 'confirmed':
        statusColor = AppColors.primary;
        statusText = 'Confirmed';
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = AppColors.textSecondary;
        statusText = 'Completed';
        statusIcon = Icons.done;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with parking name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reservation['parkingName'],
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            // Address
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reservation['address'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            // Time and duration
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDateTime(startTime)} - ${_formatDateTime(endTime)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${duration.inHours}h ${duration.inMinutes % 60}m',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${reservation['totalAmount']}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (type == 'active') ...[
                  CustomButton(
                    onPressed: () {
                      _extendReservation(reservation);
                    },
                    isOutlined: true,
                    child: const Text('Extend'),
                  ),
                ] else if (type == 'upcoming') ...[
                  CustomButton(
                    onPressed: () {
                      _cancelReservation(reservation);
                    },
                    isOutlined: true,
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.error,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomButton(
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _extendReservation(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extend Reservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many additional hours would you like to add?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _processExtension(reservation, 1);
                  },
                  child: const Text('1 Hour'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _processExtension(reservation, 2);
                  },
                  child: const Text('2 Hours'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _processExtension(reservation, 3);
                  },
                  child: const Text('3 Hours'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _processExtension(Map<String, dynamic> reservation, int hours) {
    // TODO: Implement actual extension logic when backend is ready
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reservation extended by $hours hour(s)'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _cancelReservation(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: const Text('Are you sure you want to cancel this reservation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processCancellation(reservation);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _processCancellation(Map<String, dynamic> reservation) {
    // TODO: Implement actual cancellation logic when backend is ready
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reservation cancelled successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
} 