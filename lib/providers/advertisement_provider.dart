import 'dart:io';
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/advertisement_model.dart';
import '../models/ad_slot_model.dart';

enum AdStatus { initial, loading, success, error }

class AdvertisementProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AdStatus _status = AdStatus.initial;
  String? _error;

  List<AdSlot> _localSlots = [];
  List<Advertisement> _myAds = [];
  AdSlot? _selectedSlot;
  Advertisement? _pendingAd;

  // ── Getters ───────────────────────────────────────────────────────────────
  AdStatus get status => _status;
  String? get error => _error;
  List<AdSlot> get localSlots => _localSlots;
  List<Advertisement> get myAds => _myAds;
  AdSlot? get selectedSlot => _selectedSlot;
  Advertisement? get pendingAd => _pendingAd;
  bool get isLoading => _status == AdStatus.loading;

  // ── Load Local Slots ──────────────────────────────────────────────────────
  Future<void> fetchLocalSlots() async {
    _setLoading();
    try {
      final response = await _api.getLocalSlots();
      final list = response['data'] as List<dynamic>;
      _localSlots =
          list.map((e) => AdSlot.fromJson(e as Map<String, dynamic>)).toList();
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Select Slot ───────────────────────────────────────────────────────────
  void selectSlot(AdSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  // ── Create Advertisement ──────────────────────────────────────────────────
  Future<bool> createAdvertisement({
    required String title,
    required String description,
    required String duration,
    required File media,
    required String slotId,
  }) async {
    _setLoading();
    try {
      final response = await _api.createAdvertisement(
        {
          'title': title,
          'description': description,
          'duration': duration,
          'slot_id': slotId,
        },
        media,
      );
      _pendingAd = Advertisement.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Fetch My Ads ──────────────────────────────────────────────────────────
  Future<void> fetchMyAdvertisements() async {
    _setLoading();
    try {
      final response = await _api.getMyAdvertisements();
      final list = response['data'] as List<dynamic>;
      _myAds = list
          .map((e) => Advertisement.fromJson(e as Map<String, dynamic>))
          .toList();
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading() {
    _status = AdStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AdStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AdStatus.error;
    _error = message;
    notifyListeners();
  }

  void clearPendingAd() {
    _pendingAd = null;
    notifyListeners();
  }
}
