import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Backend service for nammsign — backed by Firestore + Firebase Storage.
///
/// Replaces the previous REST-API stub. All reads/writes go directly to:
///   • Firestore (cloud_firestore) — structured data
///   • Storage (firebase_storage)  — KYC docs + ad creatives
///
/// Method signatures match the old REST shape so providers don't change.
class ApiService {
  // ── Singleton ────────────────────────────────────────────────────────────
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final FirebaseFirestore _db      = FirebaseFirestore.instance;
  final FirebaseStorage   _storage = FirebaseStorage.instance;
  final FirebaseAuth      _auth    = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) {
      throw ApiException(message: 'Not signed in', statusCode: 401);
    }
    return u.uid;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Onboarding
  // ════════════════════════════════════════════════════════════════════════

  /// Submits the KYC form + optional document upload.
  ///
  /// [accountType] is `"individual"` or `"corporate"`.
  /// [data] holds the form fields (full_name + aadhar_last4 for individual;
  /// company_name + gst_number for corporate).
  /// [document] is the user's KYC file (Aadhar / GST cert).
  Future<Map<String, dynamic>> submitOnboarding({
    required String accountType,
    required Map<String, dynamic> data,
    File? document,
  }) async {
    final uid = _uid;
    String? docUrl;

    // Upload KYC document to private Storage path
    if (document != null) {
      final ext = document.path.split('.').last.toLowerCase();
      final ref = _storage.ref('kyc/$uid/document.$ext');
      await ref.putFile(document);
      docUrl = await ref.getDownloadURL();
    }

    // Sanitize Aadhar — only keep last 4 digits (DPDP Act compliance)
    final sanitizedData = Map<String, dynamic>.from(data);
    if (sanitizedData.containsKey('aadhar_number')) {
      final raw = (sanitizedData.remove('aadhar_number') as String)
          .replaceAll(RegExp(r'\s'), '');
      sanitizedData['aadhar_last4'] =
          raw.length >= 4 ? raw.substring(raw.length - 4) : raw;
    }

    final userRef = _db.collection('users').doc(uid);
    final existing = await userRef.get();

    final userData = <String, dynamic>{
      'uid':              uid,
      'account_type':     accountType,
      'kyc_status':       'pending',
      'kyc_document_url': docUrl,
      'onboarding_done':  true,
      'updated_at':       FieldValue.serverTimestamp(),
      ...sanitizedData,
    };

    // Auto-fill name/email/phone from Firebase Auth on first write
    final fbUser = _auth.currentUser!;
    if (!existing.exists) {
      userData['created_at'] = FieldValue.serverTimestamp();
      userData.putIfAbsent('name',  () => fbUser.displayName ?? '');
      userData.putIfAbsent('email', () => fbUser.email ?? '');
      userData.putIfAbsent(
        'phone',
        () => fbUser.phoneNumber?.replaceFirst('+91', '') ?? '',
      );
    }

    await userRef.set(userData, SetOptions(merge: true));

    return {'success': true, 'kyc_status': 'pending'};
  }

  // ════════════════════════════════════════════════════════════════════════
  // Slots (signage boards catalog)
  // ════════════════════════════════════════════════════════════════════════

  /// Lists all active local signage slots.
  Future<Map<String, dynamic>> getLocalSlots() async {
    final snap = await _db
        .collection('slots')
        .where('type', isEqualTo: 'local')
        .where('active', isEqualTo: true)
        .get();

    final slots = snap.docs.map((doc) {
      final d = Map<String, dynamic>.from(doc.data());
      d['id'] = doc.id;
      return d;
    }).toList();

    return {'data': slots};
  }

  // ════════════════════════════════════════════════════════════════════════
  // Advertisements
  // ════════════════════════════════════════════════════════════════════════

  /// Creates a new advertisement record + uploads media to Storage.
  ///
  /// NOTE: In Phase 7 this becomes a Cloud Function called AFTER Razorpay
  /// payment verification, so the Flutter client never writes ads directly.
  /// For now, this is here so the existing flow keeps working during dev.
  Future<Map<String, dynamic>> createAdvertisement(
    Map<String, dynamic> data,
    File media,
  ) async {
    final uid = _uid;

    final ext = media.path.split('.').last.toLowerCase();
    final mediaType =
        const ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)
            ? 'video'
            : 'image';

    // Pre-mint the advertisement ID so we can use it in the storage path
    final adRef = _db.collection('advertisements').doc();
    final adId  = adRef.id;

    final storageRef = _storage.ref('ads/$uid/$adId/media.$ext');
    await storageRef.putFile(media);
    final mediaUrl = await storageRef.getDownloadURL();

    // Denormalize user + slot fields for display in History list
    final userSnap = await _db.collection('users').doc(uid).get();
    final user = userSnap.data() ?? {};

    final slotId   = data['slot_id'] as String;
    final slotSnap = await _db.collection('slots').doc(slotId).get();
    final slot     = slotSnap.data() ?? {};

    final duration = int.tryParse('${data['duration'] ?? '0'}') ?? 0;
    final pricePerDay = (slot['price_per_day'] as num?)?.toDouble() ?? 0.0;
    final amount = pricePerDay * duration;

    final adData = <String, dynamic>{
      'id':            adId,
      'user_id':       uid,
      'user_name':     user['name'] ?? '',
      'user_phone':    user['phone'] ?? '',
      'slot_id':       slotId,
      'slot_name':     slot['name'] ?? '',
      'slot_location':
          '${slot['area'] ?? ''}, ${slot['city'] ?? ''}'
              .replaceFirst(RegExp(r'^,\s*'), ''),
      'title':         data['title'],
      'description':   data['description'],
      'media_url':     mediaUrl,
      'media_type':    mediaType,
      'duration_days': duration,
      'amount_paid':   amount,
      'status':        'pending',
      'play_count':    0,
      'created_at':    FieldValue.serverTimestamp(),
    };

    await adRef.set(adData);

    // Echo back a copy with ISO timestamp so the existing fromJson works.
    final echo = Map<String, dynamic>.from(adData);
    echo['created_at'] = DateTime.now().toIso8601String();
    return {'data': echo};
  }

  /// Returns the current user's ads, newest first.
  Future<Map<String, dynamic>> getMyAdvertisements() async {
    final snap = await _db
        .collection('advertisements')
        .where('user_id', isEqualTo: _uid)
        .orderBy('created_at', descending: true)
        .get();

    final ads = snap.docs.map(_adDocToJson).toList();
    return {'data': ads};
  }

  /// Helper: convert Firestore Timestamp fields to ISO strings so the
  /// existing `Advertisement.fromJson` continues to work unchanged.
  Map<String, dynamic> _adDocToJson(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = Map<String, dynamic>.from(doc.data());
    d['id'] = doc.id;
    if (d['created_at'] is Timestamp) {
      d['created_at'] = (d['created_at'] as Timestamp).toDate().toIso8601String();
    } else {
      d['created_at'] ??= DateTime.now().toIso8601String();
    }
    if (d['expires_at'] is Timestamp) {
      d['expires_at'] = (d['expires_at'] as Timestamp).toDate().toIso8601String();
    }
    return d;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Payments (placeholder — Cloud Functions in Phase 7)
  // ════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    throw ApiException(
      message: 'Payment integration coming in Phase 7. '
          'Cloud Functions for Razorpay are not deployed yet.',
      statusCode: 501,
    );
  }

  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> data) async {
    throw ApiException(
      message: 'Payment integration coming in Phase 7. '
          'Cloud Functions for Razorpay are not deployed yet.',
      statusCode: 501,
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // User Profile
  // ════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getProfile() async {
    final doc = await _db.collection('users').doc(_uid).get();
    if (!doc.exists) {
      return {'data': null};
    }
    return {'data': doc.data()};
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(_uid).set(
      {...data, 'updated_at': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    return {'success': true};
  }
}

// ── Custom Exception ───────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int    statusCode;
  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
