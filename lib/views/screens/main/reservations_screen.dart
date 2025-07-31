import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../constants/app_constants.dart';
import 'tabs/reservations_tab.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options for reservations
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter options coming soon!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: const ReservationsTab(),
    );
  }
} 