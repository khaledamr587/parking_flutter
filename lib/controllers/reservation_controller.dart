import 'package:flutter/foundation.dart';
import '../models/reservation.dart';
import '../models/parking.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ReservationController extends ChangeNotifier {
  final ApiService _apiService;
  final NotificationService _notificationService;

  List<Reservation> _reservations = [];
  List<Reservation> _activeReservations = [];
  List<Reservation> _upcomingReservations = [];
  List<Reservation> _completedReservations = [];
  bool _isLoading = false;
  String? _error;

  ReservationController(this._apiService, this._notificationService);

  // Getters
  List<Reservation> get reservations => _reservations;
  List<Reservation> get activeReservations => _activeReservations;
  List<Reservation> get upcomingReservations => _upcomingReservations;
  List<Reservation> get completedReservations => _completedReservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all user reservations
  Future<void> loadReservations() async {
    try {
      _setLoading(true);
      _clearError();

      final reservations = await _apiService.getUserReservations();
      _reservations = reservations;
      _categorizeReservations();
      
      // Schedule notifications for upcoming reservations
      await _scheduleNotifications();
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create a new reservation
  Future<Reservation?> createReservation({
    required Parking parking,
    required DateTime startTime,
    required DateTime endTime,
    required int durationHours,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final reservation = await _apiService.createReservation(
        parkingId: parking.id ?? 0,
        startTime: startTime,
        endTime: endTime,
        durationHours: durationHours,
        notes: notes,
      );

      _reservations.add(reservation);
      _categorizeReservations();
      await _scheduleNotifications();
      
      notifyListeners();
      return reservation;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel a reservation
  Future<bool> cancelReservation(int reservationId) async {
    try {
      _setLoading(true);
      _clearError();

      await _apiService.cancelReservation(reservationId);
      
      // Remove from local list
      _reservations.removeWhere((r) => r.id == reservationId);
      _categorizeReservations();
      
      // Cancel related notifications
      await _notificationService.cancelNotification(reservationId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Extend a reservation
  Future<bool> extendReservation(int reservationId, int additionalHours) async {
    try {
      _setLoading(true);
      _clearError();

      final reservation = _reservations.firstWhere((r) => r.id == reservationId);
      final newEndTime = reservation.endTime.add(Duration(hours: additionalHours));
      
      final updatedReservation = await _apiService.updateReservationStatus(
        reservationId,
        'extended',
      );

      // Update local reservation
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = updatedReservation;
        _categorizeReservations();
        await _scheduleNotifications();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get reservation by ID
  Reservation? getReservationById(int id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh a specific reservation
  Future<void> refreshReservation(int reservationId) async {
    try {
      final reservation = await _apiService.getReservation(reservationId);
      
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = reservation;
        _categorizeReservations();
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Categorize reservations by status
  void _categorizeReservations() {
    final now = DateTime.now();
    
    _activeReservations = _reservations.where((r) {
      return r.status == 'active' && 
             r.startTime.isBefore(now) && 
             r.endTime.isAfter(now);
    }).toList();

    _upcomingReservations = _reservations.where((r) {
      return r.status == 'confirmed' && r.startTime.isAfter(now);
    }).toList();

    _completedReservations = _reservations.where((r) {
      return r.status == 'completed' || 
             r.status == 'cancelled' || 
             (r.endTime.isBefore(now) && r.status == 'active');
    }).toList();
  }

  // Schedule notifications for upcoming reservations
  Future<void> _scheduleNotifications() async {
    for (final reservation in _upcomingReservations) {
      await _notificationService.scheduleReservationReminder(
        reservation.id ?? 0,
        reservation.parkingName ?? 'Unknown Parking',
        reservation.startTime,
      );
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