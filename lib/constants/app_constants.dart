import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Parking App';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart parking solution for modern cities';
  
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String apiVersion = 'v1';
  static const int apiTimeout = 30; // seconds
  
  // Database Configuration
  static const String databaseName = 'khaled_db';
  
  // Payment Configuration
  static const String stripePublishableKey = 'pk_test_your_stripe_key_here';
  static const String currency = 'EUR';
  static const String currencySymbol = '€';
  
  // Map Configuration
  static const double defaultMapZoom = 15.0;
  static const double defaultSearchRadius = 5.0; // km
  static const double maxSearchRadius = 50.0; // km
  
  // Location Configuration
  static const double defaultLatitude = 48.8566; // Paris coordinates
  static const double defaultLongitude = 2.3522;
  
  // Reservation Configuration
  static const int minReservationDuration = 1; // hours
  static const int maxReservationDuration = 24; // hours
  static const int maxAdvanceBookingDays = 30; // days
  
  // Notification Configuration
  static const int notificationReminderMinutes = 15;
  static const int notificationExpiryMinutes = 5;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 50.0;
  static const double inputHeight = 50.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Cache Configuration
  static const int cacheExpiryHours = 24;
  static const int maxCacheSize = 50; // MB
  
  // File Upload Configuration
  static const int maxImageSize = 5; // MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String authenticationErrorMessage = 'Authentication failed. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String unknownErrorMessage = 'An unexpected error occurred.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registrationSuccessMessage = 'Registration successful!';
  static const String reservationSuccessMessage = 'Reservation created successfully!';
  static const String paymentSuccessMessage = 'Payment processed successfully!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  
  // Validation Messages
  static const String emailRequiredMessage = 'Email is required';
  static const String emailInvalidMessage = 'Please enter a valid email address';
  static const String passwordRequiredMessage = 'Password is required';
  static const String passwordMinLengthMessage = 'Password must be at least 8 characters';
  static const String firstNameRequiredMessage = 'First name is required';
  static const String lastNameRequiredMessage = 'Last name is required';
  static const String phoneInvalidMessage = 'Please enter a valid phone number';
  
  // Status Messages
  static const String loadingMessage = 'Loading...';
  static const String processingMessage = 'Processing...';
  static const String savingMessage = 'Saving...';
  static const String searchingMessage = 'Searching...';
  static const String bookingMessage = 'Booking...';
  static const String payingMessage = 'Processing payment...';
}

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFE0B2);
  
  // Accent Colors
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentDark = Color(0xFF388E3C);
  static const Color accentLight = Color(0xFFC8E6C9);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Parking Status Colors
  static const Color available = Color(0xFF4CAF50);
  static const Color occupied = Color(0xFFF44336);
  static const Color reserved = Color(0xFFFF9800);
  static const Color maintenance = Color(0xFF9E9E9E);
  
  // Reservation Status Colors
  static const Color pending = Color(0xFFFF9800);
  static const Color confirmed = Color(0xFF2196F3);
  static const Color active = Color(0xFF4CAF50);
  static const Color completed = Color(0xFF9E9E9E);
  static const Color cancelled = Color(0xFFF44336);
}

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Input Text
  static const TextStyle input = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );
  
  // Caption Text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Overline Text
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );
}

class AppIcons {
  // Navigation Icons
  static const String home = 'assets/icons/home.svg';
  static const String search = 'assets/icons/search.svg';
  static const String map = 'assets/icons/map.svg';
  static const String profile = 'assets/icons/profile.svg';
  static const String bookings = 'assets/icons/bookings.svg';
  
  // Action Icons
  static const String add = 'assets/icons/add.svg';
  static const String edit = 'assets/icons/edit.svg';
  static const String delete = 'assets/icons/delete.svg';
  static const String share = 'assets/icons/share.svg';
  static const String favorite = 'assets/icons/favorite.svg';
  static const String location = 'assets/icons/location.svg';
  static const String time = 'assets/icons/time.svg';
  static const String price = 'assets/icons/price.svg';
  
  // Status Icons
  static const String check = 'assets/icons/check.svg';
  static const String warning = 'assets/icons/warning.svg';
  static const String error = 'assets/icons/error.svg';
  static const String info = 'assets/icons/info.svg';
  
  // Payment Icons
  static const String card = 'assets/icons/card.svg';
  static const String wallet = 'assets/icons/wallet.svg';
  static const String paypal = 'assets/icons/paypal.svg';
  static const String applePay = 'assets/icons/apple_pay.svg';
  static const String googlePay = 'assets/icons/google_pay.svg';
  
  // Parking Icons
  static const String parking = 'assets/icons/parking.svg';
  static const String car = 'assets/icons/car.svg';
  static const String motorcycle = 'assets/icons/motorcycle.svg';
  static const String truck = 'assets/icons/truck.svg';
  static const String disabled = 'assets/icons/disabled.svg';
  static const String electric = 'assets/icons/electric.svg';
}

class AppRoutes {
  // Authentication Routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // Main App Routes
  static const String home = '/home';
  static const String map = '/map';
  static const String reservations = '/reservations';
  static const String search = '/search';
  static const String parkingDetails = '/parking-details';
  static const String booking = '/booking';
  static const String payment = '/payment';
  static const String payments = '/payments';
  static const String profile = '/profile';
  static const String bookings = '/bookings';
  static const String settings = '/settings';
  
  // Feature Routes
  static const String paymentMethods = '/payment-methods';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String support = '/support';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String parkings = '/parkings';
  static const String editProfile = '/edit-profile';
  static const String security = '/security';
  static const String language = '/language';
  static const String currency = '/currency';
  
  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminParkings = '/admin/parkings';
  static const String adminUsers = '/admin/users';
  static const String adminReservations = '/admin/reservations';
  static const String adminStatistics = '/admin/statistics';
  
  // Owner Routes
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerParkings = '/owner/parkings';
  static const String ownerReservations = '/owner/reservations';
  static const String ownerStatistics = '/owner/statistics';
} 