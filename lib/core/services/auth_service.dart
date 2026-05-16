import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service backed by Firebase Auth.
///
/// Supports:
///   • Phone-number OTP login (Indian numbers, +91 default).
///   • Google Sign-In (via Firebase credential).
///
/// User data is persisted to SharedPreferences for offline access.
/// NOTE: For production, migrate the token to `flutter_secure_storage`.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth   = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn(scopes: ['email', 'profile']);

  /// Stored after `sendOtp` returns; consumed by `verifyOtp`.
  String? _verificationId;

  /// Optional resend token from Firebase (used when user taps "Resend").
  int? _resendToken;

  // ── Token + User Storage ─────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> isLoggedIn() async {
    // Firebase user is the source of truth.
    if (_auth.currentUser != null) return true;
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid',      user['uid']      ?? '');
    await prefs.setString('user_name',     user['name']     ?? '');
    await prefs.setString('user_email',    user['email']    ?? '');
    await prefs.setString('user_phone',    user['phone']    ?? '');
    await prefs.setString('user_type',     user['type']     ?? '');
    await prefs.setBool('onboarding_done', user['onboarding_done'] ?? false);
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'uid':             prefs.getString('user_uid')   ?? '',
      'name':            prefs.getString('user_name')  ?? '',
      'email':           prefs.getString('user_email') ?? '',
      'phone':           prefs.getString('user_phone') ?? '',
      'type':            prefs.getString('user_type')  ?? '',
      'onboarding_done': prefs.getBool('onboarding_done') ?? false,
    };
  }

  /// Called by the onboarding flow once the user finishes their profile.
  Future<void> markOnboardingComplete({String? type}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (type != null) await prefs.setString('user_type', type);
  }

  // ── Phone OTP Flow ───────────────────────────────────────────────────────

  /// Sends an OTP to the given 10-digit Indian phone number.
  /// Returns `true` if the SMS was dispatched (or auto-verification fired).
  /// Throws a user-friendly error message on failure.
  Future<bool> sendOtp(String phone) async {
    final completer = Completer<bool>();
    final fullNumber = '+91$phone';

    await _auth.verifyPhoneNumber(
      phoneNumber: fullNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,

      // Android only: SMS auto-detected by Play Services.
      // We sign the user in immediately without showing OTP UI.
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _auth.signInWithCredential(credential);
          await _persistFirebaseUser(phone: phone);
        } catch (_) {
          // Auto-completion may race with manual entry; ignore here,
          // the user will still be able to enter the OTP manually.
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(_humanizeAuthError(e));
        }
      },

      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) completer.complete(true);
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        // Save the verification ID so manual entry still works
        // after the auto-retrieval window closes.
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  /// Verifies the 6-digit OTP entered by the user.
  Future<AuthResult> verifyOtp(String phone, String otp) async {
    if (_verificationId == null) {
      return AuthResult(
        success: false,
        message: 'Verification expired. Please request a new OTP.',
      );
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final isNewUser = userCred.additionalUserInfo?.isNewUser ?? false;

      await _persistFirebaseUser(phone: phone);

      // For brand-new Firebase users we always send them through onboarding.
      // Returning users keep the locally-stored onboarding flag.
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = isNewUser
          ? false
          : (prefs.getBool('onboarding_done') ?? false);

      return AuthResult(
        success: true,
        needsOnboarding: !onboardingDone,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _humanizeAuthError(e));
    } catch (e) {
      return AuthResult(success: false, message: 'Verification failed: $e');
    }
  }

  // ── Google Sign-In ───────────────────────────────────────────────────────

  Future<AuthResult> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) {
        return AuthResult(success: false, message: 'Sign-in cancelled');
      }

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final isNewUser = userCred.additionalUserInfo?.isNewUser ?? false;

      await _persistFirebaseUser();

      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = isNewUser
          ? false
          : (prefs.getBool('onboarding_done') ?? false);

      return AuthResult(
        success: true,
        needsOnboarding: !onboardingDone,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _humanizeAuthError(e));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Google sign-in failed: $e',
      );
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      await _google.signOut();
    } catch (_) {}

    _verificationId = null;
    _resendToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Internal Helpers ─────────────────────────────────────────────────────

  /// Persists the current Firebase user + a fresh ID token to SharedPreferences.
  /// Accepts an explicit [phone] override (Firebase strips the +91 sometimes
  /// before the user document is reloaded).
  Future<void> _persistFirebaseUser({String? phone}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final idToken = await user.getIdToken();
    if (idToken != null) await saveToken(idToken);

    await saveUserData({
      'uid':   user.uid,
      'name':  user.displayName ?? '',
      'email': user.email ?? '',
      'phone': phone ?? (user.phoneNumber ?? ''),
      // Preserve existing onboarding flag — do not overwrite.
      'onboarding_done':
          (await SharedPreferences.getInstance()).getBool('onboarding_done') ??
              false,
    });
  }

  String _humanizeAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid 10-digit Indian mobile number.';
      case 'invalid-verification-code':
        return 'The OTP you entered is incorrect.';
      case 'session-expired':
        return 'OTP expired. Please request a new code.';
      case 'too-many-requests':
        return 'Too many attempts. Try again after some time.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'quota-exceeded':
        return 'Daily SMS limit reached. Please try again tomorrow.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked to a different sign-in method.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
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
