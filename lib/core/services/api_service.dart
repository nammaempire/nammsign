import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://your-api.com/api/v1'; // 🔧 Replace with your API URL

  // ── Singleton ─────────────────────────────────────────────────────────────
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ── Token Management ──────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type':  'application/json',
      'Accept':        'application/json',
    };
    if (withAuth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Generic Request Helpers ───────────────────────────────────────────────
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      message:    body['message'] ?? 'Something went wrong',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(withAuth: withAuth),
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  // ── Multipart Upload ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> uploadFile(
    String path,
    File file,
    String fieldName, {
    Map<String, String>? fields,
  }) async {
    final token    = await _getToken();
    final request  = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(fieldName, file.path),
    );
    if (fields != null) request.fields.addAll(fields);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // ── Auth Endpoints ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> sendOtp(String phone) =>
      post('/auth/send-otp', {'phone': phone}, withAuth: false);

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) =>
      post('/auth/verify-otp', {'phone': phone, 'otp': otp}, withAuth: false);

  Future<Map<String, dynamic>> googleLogin(String idToken) =>
      post('/auth/google', {'id_token': idToken}, withAuth: false);

  Future<Map<String, dynamic>> logout() => post('/auth/logout', {});

  // ── Onboarding Endpoints ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> submitOnboarding({
    required String accountType,
    required Map<String, dynamic> data,
    File? document,
  }) async {
    if (document != null) {
      return uploadFile(
        '/onboarding/submit',
        document,
        'document',
        fields: {
          'account_type': accountType,
          ...data.map((k, v) => MapEntry(k, v.toString())),
        },
      );
    }
    return post('/onboarding/submit', {'account_type': accountType, ...data});
  }

  // ── Ad Slot Endpoints ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getLocalSlots() => get('/slots/local');
  Future<Map<String, dynamic>> getPremiumSlots() => get('/slots/premium');
  Future<Map<String, dynamic>> getSlotDetail(String slotId) =>
      get('/slots/$slotId');

  // ── Advertisement Endpoints ───────────────────────────────────────────────
  Future<Map<String, dynamic>> createAdvertisement(
    Map<String, dynamic> data,
    File media,
  ) =>
      uploadFile(
        '/advertisements',
        media,
        'media',
        fields: data.map((k, v) => MapEntry(k, v.toString())),
      );

  Future<Map<String, dynamic>> getMyAdvertisements() =>
      get('/advertisements/mine');

  Future<Map<String, dynamic>> getAdvertisementStatus(String adId) =>
      get('/advertisements/$adId/status');

  // ── Payment Endpoints ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) =>
      post('/payments/create-order', data);

  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> data) =>
      post('/payments/verify', data);

  // ── User Profile ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProfile() => get('/user/profile');
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) =>
      put('/user/profile', data);
}

// ── Custom Exception ──────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
