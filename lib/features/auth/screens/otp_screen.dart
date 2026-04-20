import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer?  _timer;
  int     _seconds = 60;
  bool    _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _seconds   = 60;
    _canResend = false;
    _timer     = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) {
      _showSnack('Please enter the complete 6-digit OTP', isError: true);
      return;
    }
    final auth   = context.read<AuthProvider>();
    final result = await auth.verifyOtp(widget.phone, _otp);
    if (!mounted) return;

    if (result?.success == true) {
      if (result!.needsOnboarding) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      _showSnack(auth.error ?? 'Invalid OTP', isError: true);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    final auth    = context.read<AuthProvider>();
    final success = await auth.sendOtp(widget.phone);
    if (!mounted) return;
    if (success) {
      _startTimer();
      _showSnack('OTP resent successfully');
    } else {
      _showSnack('Failed to resend OTP', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── OTP box handler ────────────────────────────────────────────────────────
  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_otp.length == 6) _verifyOtp();
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyOtp),
        leading: IconButton(
          icon:     const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Header ───────────────────────────────────────────────────
            Text(
              'Enter Verification Code',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                children: [
                  const TextSpan(text: '${AppStrings.otpSentTo} '),
                  TextSpan(
                    text: '+91 ${widget.phone}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color:      AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── OTP Boxes ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => _OtpBox(
                  controller: _controllers[i],
                  focusNode:  _focusNodes[i],
                  onChanged:  (v) => _onChanged(v, i),
                  isDark:     isDark,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Verify Button ────────────────────────────────────────────
            Consumer<AuthProvider>(
              builder: (_, auth, __) => ElevatedButton(
                onPressed: (){
 Navigator.pushReplacementNamed(context, '/home');
                },
                // auth.isLoading ? null : _verifyOtp,
                style:     ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient:     AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    height:    54,
                    alignment: Alignment.center,
                    child: auth.isLoading
                        ? const SizedBox(
                            width:  22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color:       Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            AppStrings.verifyOtp,
                            style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w600,
                              color:      Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Resend ────────────────────────────────────────────────────
            Center(
              child: _canResend
                  ? TextButton(
                      onPressed: _resendOtp,
                      child: const Text(
                        AppStrings.resendOtp,
                        style: TextStyle(
                          color:      AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Text(
                      'Resend OTP in ${_seconds}s',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single OTP Input Box ──────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final ValueChanged<String>  onChanged;
  final bool                  isDark;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  50,
      height: 58,
      child: TextField(
        controller:       controller,
        focusNode:        focusNode,
        textAlign:        TextAlign.center,
        keyboardType:     TextInputType.number,
        maxLength:        1,
        inputFormatters:  [FilteringTextInputFormatter.digitsOnly],
        onChanged:        onChanged,
        style: TextStyle(
          fontSize:   22,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          counterText:   '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primaryPurple,
              width: 2,
            ),
          ),
          fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          filled:    true,
        ),
      ),
    );
  }
}
