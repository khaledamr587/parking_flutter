import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;
  
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.message = 'This feature is coming soon!',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 