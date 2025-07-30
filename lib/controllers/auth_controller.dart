import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthController() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        await _loadCurrentUser();
      }
    } catch (e) {
      _setError('Failed to check authentication status');
      await _clearAuthData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _apiService.getCurrentUser();
      _isAuthenticated = true;
      _clearError();
      notifyListeners();
    } catch (e) {
      await _clearAuthData();
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.login(email, password);
      _currentUser = User.fromJson(response['user']);
      _isAuthenticated = true;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      
      _currentUser = User.fromJson(response['user']);
      _isAuthenticated = true;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _clearAuthData();
      _setLoading(false);
    }
  }

  Future<void> _clearAuthData() async {
    _currentUser = null;
    _isAuthenticated = false;
    _clearError();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userData = <String, dynamic>{};
      if (firstName != null) userData['first_name'] = firstName;
      if (lastName != null) userData['last_name'] = lastName;
      if (phone != null) userData['phone'] = phone;
      if (profileImage != null) userData['profile_image'] = profileImage;

      _currentUser = await _apiService.updateUser(userData);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyEmail(String verificationCode) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement email verification when backend is ready
      // await _apiService.verifyEmail(verificationCode);
      
      // Simulate verification for now
      await Future.delayed(const Duration(seconds: 1));
      
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(isEmailVerified: true);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyPhone(String verificationCode) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement phone verification when backend is ready
      // await _apiService.verifyPhone(verificationCode);
      
      // Simulate verification for now
      await Future.delayed(const Duration(seconds: 1));
      
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(isPhoneVerified: true);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement forgot password when backend is ready
      // await _apiService.forgotPassword(email);
      
      // Simulate password reset email for now
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement password reset when backend is ready
      // await _apiService.resetPassword(token, newPassword);
      
      // Simulate password reset for now
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Social Sign-In Methods
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement Google Sign-In when backend is ready
      // final googleUser = await GoogleSignIn().signIn();
      // if (googleUser != null) {
      //   final googleAuth = await googleUser.authentication;
      //   await _apiService.signInWithGoogle(googleAuth.accessToken!);
      // }
      
      // Simulate Google Sign-In for now
      await Future.delayed(const Duration(seconds: 2));
      
      // Create a mock user for demonstration
      _currentUser = User(
        id: 1,
        email: 'user@gmail.com',
        firstName: 'Google',
        lastName: 'User',
        isEmailVerified: true,
        isPhoneVerified: false,
        userType: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement Apple Sign-In when backend is ready
      // final credential = await SignInWithApple.getAppleIDCredential(
      //   scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      // );
      // await _apiService.signInWithApple(credential);
      
      // Simulate Apple Sign-In for now
      await Future.delayed(const Duration(seconds: 2));
      
      // Create a mock user for demonstration
      _currentUser = User(
        id: 2,
        email: 'user@icloud.com',
        firstName: 'Apple',
        lastName: 'User',
        isEmailVerified: true,
        isPhoneVerified: false,
        userType: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      notifyListeners();
      
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

  // Check if user has specific permissions
  bool get isAdmin => _currentUser?.userType == 'admin';
  bool get isParkingOwner => _currentUser?.userType == 'parking_owner';
  bool get isRegularUser => _currentUser?.userType == 'user';
  
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    
    switch (permission) {
      case 'admin':
        return isAdmin;
      case 'parking_owner':
        return isAdmin || isParkingOwner;
      case 'user':
        return true;
      default:
        return false;
    }
  }
} 