import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  String? _error;
  Map<String, dynamic> _userData = {};

  AuthStatus get status => _status;
  String? get error => _error;
  Map<String, dynamic> get userData => _userData;
  bool get isLoading => _status == AuthStatus.loading;

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<bool> checkAuth() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      _userData = await _authService.getUserData();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return loggedIn;
  }

  // ── OTP ───────────────────────────────────────────────────────────────────
  Future<bool> sendOtp(String phone) async {
    _setLoading();
    try {
      final success = await _authService.sendOtp(phone);

      // If Firebase auto-verified the SMS (Android), the user is already
      // signed in by the time sendOtp returns true. Reflect that here.
      if (success && await _authService.isLoggedIn()) {
        _userData = await _authService.getUserData();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
      return success;
    } catch (e) {
      // Service throws a humanized message; surface it directly.
      _setError(e is String ? e : e.toString());
      return false;
    }
  }

  Future<AuthResult?> verifyOtp(String phone, String otp) async {
    _setLoading();
    try {
      final result = await _authService.verifyOtp(phone, otp);
      if (result.success) {
        _userData = await _authService.getUserData();
        _status = AuthStatus.authenticated;
      } else {
        _setError(result.message ?? 'OTP verification failed');
      }
      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // ── Google ────────────────────────────────────────────────────────────────
  Future<AuthResult?> signInWithGoogle() async {
    _setLoading();
    try {
      final result = await _authService.signInWithGoogle();
      if (result.success) {
        _userData = await _authService.getUserData();
        _status = AuthStatus.authenticated;
      } else {
        _setError(result.message ?? 'Google sign-in failed');
      }
      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _setLoading();
    await _authService.logout();
    _userData = {};
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String get userName => _userData['name'] ?? '';
  String get userEmail => _userData['email'] ?? '';
  String get userPhone => _userData['phone'] ?? '';
  String get userType => _userData['type'] ?? '';
  bool get onboardingDone => _userData['onboarding_done'] ?? false;
}
