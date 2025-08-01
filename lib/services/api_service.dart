import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/parking.dart';
import '../models/reservation.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Change to your API URL
  // Remove apiVersion and do not append /v1 to baseUrl
  
  late Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl, // No /v1
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));

    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  Future<void> _saveAuthToken(String? token) async {
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _authToken = token;
    }
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'An error occurred';
        throw Exception('HTTP $statusCode: $message');
      case DioExceptionType.cancel:
        throw Exception('Request was cancelled');
      default:
        throw Exception('Network error occurred');
    }
  }

  // Authentication Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      print('API Login Response: ${response.data}');
      print('Token from response: ${response.data['data']?['token']}');
      
      final token = response.data['data']?['token'];
      await _saveAuthToken(token);
      
      return response.data;
    } catch (e) {
      print('API Login Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'email': email,
        'password': password,
        'firstName': firstName, // <-- camelCase for backend
        'lastName': lastName,   // <-- camelCase for backend
      };
      
      // Only add phone if it's not null and not empty
      if (phone != null && phone.isNotEmpty) {
        requestData['phone'] = phone;
      }
      
      print('API Register Request Data: $requestData');
      
      final response = await _dio.post('/auth/register', data: requestData);
      
      print('API Register Response: ${response.data}');
      print('Token from response: ${response.data['data']?['token']}');
      
      final token = response.data['data']?['token'];
      await _saveAuthToken(token);
      
      return response.data;
    } catch (e) {
      print('API Register Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _authToken = null;
    }
  }

  // User Methods
  Future<User> getCurrentUser() async {
    try {
      print('API GetCurrentUser: Making request to /users/me');
      final response = await _dio.get('/users/me');
      print('API GetCurrentUser Response: ${response.data}');
      return User.fromJson(response.data['data']['user']);
    } catch (e) {
      print('API GetCurrentUser Error: $e');
      rethrow;
    }
  }

  Future<User> updateUser(Map<String, dynamic> userData) async {
    try {
      print('API UpdateUser: Making request to /users/me');
      final response = await _dio.put('/users/me', data: userData);
      print('API UpdateUser Response: ${response.data}');
      return User.fromJson(response.data['data']['user']);
    } catch (e) {
      print('API UpdateUser Error: $e');
      rethrow;
    }
  }

  // Parking Methods
  Future<List<Parking>> getNearbyParkings({
    required double latitude,
    required double longitude,
    double radius = 5.0, // km
    String? filter,
  }) async {
    try {
      final response = await _dio.get('/parkings/nearby', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        if (filter != null) 'filter': filter,
      });
      
      return (response.data['parkings'] as List)
          .map((json) => Parking.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Parking> getParkingDetails(int parkingId) async {
    try {
      final response = await _dio.get('/parkings/$parkingId');
      return Parking.fromJson(response.data['parking']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Parking>> searchParkings({
    String? query,
    String? city,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
  }) async {
    try {
      final response = await _dio.get('/parkings/search', queryParameters: {
        if (query != null) 'q': query,
        if (city != null) 'city': city,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (amenities != null) 'amenities': amenities.join(','),
      });
      
      return (response.data['parkings'] as List)
          .map((json) => Parking.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Reservation Methods
  Future<Reservation> createReservation({
    required int parkingId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationHours,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/reservations', data: {
        'parking_id': parkingId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_hours': durationHours,
        if (notes != null) 'notes': notes,
      });
      
      return Reservation.fromJson(response.data['reservation']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Reservation> getReservation(int reservationId) async {
    try {
      final response = await _dio.get('/reservations/$reservationId');
      return Reservation.fromJson(response.data['reservation']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Reservation>> getUserReservations({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get('/reservations', queryParameters: {
        if (status != null) 'status': status,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      });
      
      return (response.data['reservations'] as List)
          .map((json) => Reservation.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Reservation> updateReservationStatus(
    int reservationId,
    String status,
  ) async {
    try {
      final response = await _dio.patch('/reservations/$reservationId', data: {
        'status': status,
      });
      
      return Reservation.fromJson(response.data['reservation']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    try {
      await _dio.delete('/reservations/$reservationId');
    } catch (e) {
      rethrow;
    }
  }

  // Payment Methods
  Future<Map<String, dynamic>> processPayment({
    required int reservationId,
    required String paymentMethod,
    required Map<String, dynamic> paymentData,
  }) async {
    try {
      final response = await _dio.post('/payments/process', data: {
        'reservation_id': reservationId,
        'payment_method': paymentMethod,
        'payment_data': paymentData,
      });
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaymentIntent(int reservationId) async {
    try {
      final response = await _dio.get('/payments/intent/$reservationId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Admin Methods (for parking owners and admins)
  Future<List<Parking>> getMyParkings() async {
    try {
      final response = await _dio.get('/admin/parkings');
      return (response.data['parkings'] as List)
          .map((json) => Parking.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Parking> createParking(Map<String, dynamic> parkingData) async {
    try {
      final response = await _dio.post('/admin/parkings', data: parkingData);
      return Parking.fromJson(response.data['parking']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Parking> updateParking(int parkingId, Map<String, dynamic> parkingData) async {
    try {
      final response = await _dio.put('/admin/parkings/$parkingId', data: parkingData);
      return Parking.fromJson(response.data['parking']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteParking(int parkingId) async {
    try {
      await _dio.delete('/admin/parkings/$parkingId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getParkingStatistics(int parkingId) async {
    try {
      final response = await _dio.get('/admin/parkings/$parkingId/statistics');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
} 