import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService    _api    = ApiService();
  final GoogleSignIn  _google = GoogleSignIn(scopes: ['email', 'profile']);

  // ── Token Storage ─────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name',     user['name']     ?? '');
    await prefs.setString('user_email',    user['email']    ?? '');
    await prefs.setString('user_phone',    user['phone']    ?? '');
    await prefs.setString('user_type',     user['type']     ?? '');
    await prefs.setBool('onboarding_done', user['onboarding_done'] ?? false);
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name':            prefs.getString('user_name')  ?? '',
      'email':           prefs.getString('user_email') ?? '',
      'phone':           prefs.getString('user_phone') ?? '',
      'type':            prefs.getString('user_type')  ?? '',
      'onboarding_done': prefs.getBool('onboarding_done') ?? false,
    };
  }

  // ── OTP Flow ──────────────────────────────────────────────────────────────
  Future<bool> sendOtp(String phone) async {
    try {
      final response = await _api.sendOtp(phone);
      return response['success'] == true;
    } catch (_) {
      rethrow;
    }
  }

  Future<AuthResult> verifyOtp(String phone, String otp) async {
    try {
      final response = await _api.verifyOtp(phone, otp);
      final token    = response['token'] as String?;
      final user     = response['user']  as Map<String, dynamic>?;

      if (token != null) {
        await saveToken(token);
        if (user != null) await saveUserData(user);
        return AuthResult(
          success:        true,
          needsOnboarding: !(user?['onboarding_done'] ?? false),
        );
      }
      return AuthResult(success: false, message: 'Invalid OTP');
    } catch (e) {
      rethrow;
    }
  }

  // ── Google Sign In ────────────────────────────────────────────────────────
  Future<AuthResult> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) {
        return AuthResult(success: false, message: 'Sign-in cancelled');
      }
      final auth    = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Google ID token is null');

      final response = await _api.googleLogin(idToken);
      final token    = response['token'] as String?;
      final user     = response['user']  as Map<String, dynamic>?;

      if (token != null) {
        await saveToken(token);
        if (user != null) await saveUserData(user);
        return AuthResult(
          success:        true,
          needsOnboarding: !(user?['onboarding_done'] ?? false),
        );
      }
      return AuthResult(success: false, message: 'Google login failed');
    } catch (e) {
      rethrow;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    try {
      await _google.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// ── Result Model ──────────────────────────────────────────────────────────────
class AuthResult {
  final bool    success;
  final bool    needsOnboarding;
  final String? message;

  AuthResult({
    required this.success,
    this.needsOnboarding = false,
    this.message,
  });
}
