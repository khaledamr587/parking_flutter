import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import 'controllers/auth_controller.dart';
import 'controllers/reservation_controller.dart';
import 'controllers/payment_controller.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'constants/app_constants.dart';
import 'views/screens/splash_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/register_screen.dart';
import 'views/screens/auth/forgot_password_screen.dart';
import 'views/screens/main/home_screen.dart';
import 'views/screens/main/map_screen.dart';
import 'views/screens/main/reservations_screen.dart';
import 'views/screens/main/search_screen.dart';
import 'views/screens/main/placeholder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = AppConstants.stripePublishableKey;
  await Stripe.instance.applySettings();
  
  // Initialize notifications
  await _initializeNotifications();
  
  // Request location permissions
  await _requestLocationPermissions();
  
  runApp(const ParkingApp());
}

Future<void> _initializeNotifications() async {
  final notificationService = NotificationService();
  await notificationService.initialize();
}

Future<void> _requestLocationPermissions() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  }
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final apiService = ApiService();
            final notificationService = NotificationService();
            return AuthController();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final apiService = ApiService();
            final notificationService = NotificationService();
            return ReservationController(apiService, notificationService);
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final apiService = ApiService();
            final notificationService = NotificationService();
            return PaymentController(apiService, notificationService);
          },
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const SplashScreen(),
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.map: (context) => const MapScreen(),
          AppRoutes.reservations: (context) => const ReservationsScreen(),
          AppRoutes.search: (context) => const SearchScreen(),
          // Placeholder routes for features coming soon
          AppRoutes.payments: (context) => const PlaceholderScreen(
            title: 'Payments',
            message: 'Payment management is coming soon!',
          ),
          AppRoutes.support: (context) => const PlaceholderScreen(
            title: 'Support',
            message: 'Customer support is coming soon!',
          ),
          AppRoutes.parkings: (context) => const PlaceholderScreen(
            title: 'All Parkings',
            message: 'Browse all parking spots coming soon!',
          ),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        hintStyle: AppTextStyles.inputHint,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        color: AppColors.card,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
