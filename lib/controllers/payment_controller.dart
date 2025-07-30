import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/reservation.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../constants/app_constants.dart';

class PaymentController extends ChangeNotifier {
  final ApiService _apiService;
  final NotificationService _notificationService;

  bool _isLoading = false;
  String? _error;
  String? _paymentIntentClientSecret;

  PaymentController(this._apiService, this._notificationService);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get paymentIntentClientSecret => _paymentIntentClientSecret;

  // Initialize payment for a reservation
  Future<Map<String, dynamic>?> initializePayment(Reservation reservation) async {
    try {
      _setLoading(true);
      _clearError();

      // Get payment intent from backend
      final paymentData = await _apiService.getPaymentIntent(reservation.id ?? 0);
      _paymentIntentClientSecret = paymentData['client_secret'];

      return paymentData;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Process payment with Stripe
  Future<bool> processPayment({
    required Reservation reservation,
    required String paymentMethodId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Confirm payment with Stripe
      final paymentResult = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: _paymentIntentClientSecret!,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: reservation.userEmail ?? '',
              name: reservation.userName ?? '',
            ),
          ),
        ),
      );

      // Process payment on backend
      final result = await _apiService.processPayment(
        reservationId: reservation.id ?? 0,
        paymentMethod: 'stripe',
        paymentData: {
          'payment_method_id': paymentMethodId,
          'client_secret': _paymentIntentClientSecret,
        },
      );

      if (result['status'] == 'succeeded') {
        // Show success notification
        await _notificationService.showPaymentNotification(
          amount: '${AppConstants.currencySymbol}${reservation.totalAmount.toStringAsFixed(2)}',
          parkingName: reservation.parkingName ?? 'Unknown Parking',
        );

        // Show booking confirmation
        await _notificationService.showBookingConfirmation(
          parkingName: reservation.parkingName ?? 'Unknown Parking',
          startTime: reservation.startTime,
          endTime: reservation.endTime,
        );

        return true;
      } else {
        _setError('Payment failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Process payment with Google Pay
  Future<bool> processGooglePayPayment(Reservation reservation) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if Google Pay is available (simulated for now)
      final isAvailable = true; // await Stripe.instance.isGooglePaySupported();
      if (!isAvailable) {
        _setError('Google Pay is not available on this device');
        return false;
      }

      // Present Google Pay (simulated for now)
      // final paymentResult = await Stripe.instance.presentGooglePay(
      //   const GooglePayPresentParams(
      //     clientSecret: '', // Will be set by backend
      //     currencyCode: 'EUR',
      //     countryCode: 'FR',
      //   ),
      // );

      // Simulate successful payment for now
      await Future.delayed(const Duration(seconds: 2));
      final paymentResult = {'status': PaymentIntentsStatus.Succeeded, 'paymentIntentId': 'simulated_google_pay_${DateTime.now().millisecondsSinceEpoch}'};

      if (paymentResult['status'] == PaymentIntentsStatus.Succeeded) {
        // Process payment on backend
        final result = await _apiService.processPayment(
          reservationId: reservation.id ?? 0,
          paymentMethod: 'google_pay',
          paymentData: {
            'payment_intent_id': paymentResult['paymentIntentId'],
          },
        );

        if (result['status'] == 'succeeded') {
          await _notificationService.showPaymentNotification(
            amount: '${AppConstants.currencySymbol}${reservation.totalAmount.toStringAsFixed(2)}',
            parkingName: reservation.parkingName ?? 'Unknown Parking',
          );

          return true;
        } else {
          _setError('Payment failed: ${result['message']}');
          return false;
        }
      } else {
        _setError('Google Pay payment was cancelled or failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Process payment with Apple Pay
  Future<bool> processApplePayPayment(Reservation reservation) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if Apple Pay is available (simulated for now)
      final isAvailable = true; // await Stripe.instance.isApplePaySupported();
      if (!isAvailable) {
        _setError('Apple Pay is not available on this device');
        return false;
      }

      // Present Apple Pay (simulated for now)
      // final paymentResult = await Stripe.instance.presentApplePay(
      //   const ApplePayPresentParams(
      //     clientSecret: '', // Will be set by backend
      //     paymentItems: [
      //       ApplePayCartItem(
      //         label: 'Parking Reservation',
      //         amount: '0',
      //       ),
      //     ],
      //     country: 'FR',
      //     currency: 'EUR',
      //   ),
      // );

      // Simulate successful payment for now
      await Future.delayed(const Duration(seconds: 2));
      final paymentResult = {'status': PaymentIntentsStatus.Succeeded, 'paymentIntentId': 'simulated_apple_pay_${DateTime.now().millisecondsSinceEpoch}'};

      if (paymentResult['status'] == PaymentIntentsStatus.Succeeded) {
        // Process payment on backend
        final result = await _apiService.processPayment(
          reservationId: reservation.id ?? 0,
          paymentMethod: 'apple_pay',
          paymentData: {
            'payment_intent_id': paymentResult['paymentIntentId'],
          },
        );

        if (result['status'] == 'succeeded') {
          await _notificationService.showPaymentNotification(
            amount: '${AppConstants.currencySymbol}${reservation.totalAmount.toStringAsFixed(2)}',
            parkingName: reservation.parkingName ?? 'Unknown Parking',
          );

          return true;
        } else {
          _setError('Payment failed: ${result['message']}');
          return false;
        }
      } else {
        _setError('Apple Pay payment was cancelled or failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Process payment with PayPal (simulated)
  Future<bool> processPayPalPayment(Reservation reservation) async {
    try {
      _setLoading(true);
      _clearError();

      // Simulate PayPal payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Process payment on backend
      final result = await _apiService.processPayment(
        reservationId: reservation.id ?? 0,
        paymentMethod: 'paypal',
        paymentData: {
          'paypal_order_id': 'simulated_paypal_order_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      if (result['status'] == 'succeeded') {
        await _notificationService.showPaymentNotification(
          amount: '${AppConstants.currencySymbol}${reservation.totalAmount.toStringAsFixed(2)}',
          parkingName: reservation.parkingName ?? 'Unknown Parking',
        );

        return true;
      } else {
        _setError('Payment failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get payment methods for user
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      // This would typically fetch from backend
      // For now, return default payment methods
      return [
        {
          'id': 'card_1',
          'type': 'card',
          'brand': 'visa',
          'last4': '4242',
          'exp_month': 12,
          'exp_year': 2025,
        },
        {
          'id': 'card_2',
          'type': 'card',
          'brand': 'mastercard',
          'last4': '5555',
          'exp_month': 10,
          'exp_year': 2026,
        },
      ];
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Add new payment method
  Future<bool> addPaymentMethod(Map<String, dynamic> paymentData) async {
    try {
      _setLoading(true);
      _clearError();

      // This would typically save to backend
      await Future.delayed(const Duration(seconds: 1));

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove payment method
  Future<bool> removePaymentMethod(String paymentMethodId) async {
    try {
      _setLoading(true);
      _clearError();

      // This would typically remove from backend
      await Future.delayed(const Duration(seconds: 1));

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
} 