import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../models/ad_slot_model.dart';
import '../../../providers/advertisement_provider.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final AdSlot slot;
  final String title;
  final String description;
  final File mediaFile;
  final String mediaType;
  final int durationDays;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.slot,
    required this.title,
    required this.description,
    required this.mediaFile,
    required this.mediaType,
    required this.durationDays,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _api = ApiService();
  late Razorpay _razorpay;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ── Razorpay Flow ─────────────────────────────────────────────────────────
  Future<void> _initiatePayment() async {
    setState(() => _isLoading = true);
    try {
      // 1. Create order on backend
      final orderResponse = await _api.createOrder({
        'amount': (widget.totalAmount * 100).toInt(), // paise
        'currency': 'INR',
        'slot_id': widget.slot.id,
        'duration': widget.durationDays,
        'title': widget.title,
        'description': widget.description,
      });

      final orderId = orderResponse['order_id'] as String;

      // 2. Open Razorpay checkout
      final options = {
        'key': 'rzp_test_XXXXXXXXXXXXXX', // 🔧 Replace with your Razorpay key
        'amount': (widget.totalAmount * 100).toInt(),
        'name': AppStrings.appName,
        'description': widget.title,
        'order_id': orderId,
        'currency': 'INR',
        'prefill': {
          'contact': '',
          'email': '',
        },
        'theme': {
          'color': '#7C3AED',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Payment initiation failed. Please try again.');
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);
    try {
      // Verify payment on backend
      await _api.verifyPayment({
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      });

      // Upload the advertisement
      if (!mounted) return;
      final provider = context.read<AdvertisementProvider>();
      final success = await provider.createAdvertisement(
        title: widget.title,
        description: widget.description,
        duration: widget.durationDays.toString(),
        media: widget.mediaFile,
        slotId: widget.slot.id,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              slotName: widget.slot.name,
              amountPaid: widget.totalAmount,
              durationDays: widget.durationDays,
            ),
          ),
        );
      } else {
        _showError('Ad submission failed after payment. Contact support.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Payment verified but ad upload failed. Contact support.');
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    _showError(response.message ?? 'Payment failed. Please try again.');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payment),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order Summary Header ──────────────────────────────────
            Text(
              AppStrings.orderSummary,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // ── Summary Card ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Column(
                children: [
                  _OrderRow(
                    label: 'Ad Title',
                    value: widget.title,
                    isDark: isDark,
                  ),
                  _OrderDivider(isDark: isDark),
                  _OrderRow(
                    label: 'Location',
                    value: widget.slot.name,
                    isDark: isDark,
                  ),
                  _OrderDivider(isDark: isDark),
                  _OrderRow(
                    label: 'Area',
                    value: '${widget.slot.area}, ${widget.slot.city}',
                    isDark: isDark,
                  ),
                  _OrderDivider(isDark: isDark),
                  _OrderRow(
                    label: 'Duration',
                    value: '${widget.durationDays} Days',
                    isDark: isDark,
                  ),
                  _OrderDivider(isDark: isDark),
                  _OrderRow(
                    label: 'Rate',
                    value: widget.slot.priceLabel,
                    isDark: isDark,
                  ),
                  _OrderDivider(isDark: isDark),
                  _OrderRow(
                    label: 'Media Type',
                    value:
                        widget.mediaType == 'image' ? '🖼 Image' : '🎬 Video',
                    isDark: isDark,
                  ),
                  _OrderDivider(isDark: isDark),
                  _OrderRow(
                    label: 'Total Amount',
                    value: '₹${widget.totalAmount.toStringAsFixed(0)}',
                    isDark: isDark,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Approval Note ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your ad will be submitted for admin approval after payment. It will go live once approved.',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Pay Button ────────────────────────────────────────────
            ElevatedButton(
              onPressed: _isLoading ? null : _initiatePayment,
              style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : AppColors.primaryGradient,
                  color: _isLoading
                      ? (isDark ? AppColors.darkCard : AppColors.lightDivider)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  height: 58,
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '${AppStrings.payNow} · ₹${widget.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Razorpay Branding ─────────────────────────────────────
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.poweredRazorpay,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Order Row ─────────────────────────────────────────────────────────────────
class _OrderRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isTotal;

  const _OrderRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal
                  ? AppColors.primaryPurple
                  : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDivider extends StatelessWidget {
  final bool isDark;
  const _OrderDivider({required this.isDark});

  @override
  Widget build(BuildContext context) => Divider(
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        height: 1,
        thickness: 1,
      );
}
