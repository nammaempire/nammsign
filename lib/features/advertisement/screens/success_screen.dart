import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SuccessScreen extends StatefulWidget {
  final String slotName;
  final double amountPaid;
  final int    durationDays;

  const SuccessScreen({
    super.key,
    required this.slotName,
    required this.amountPaid,
    required this.durationDays,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false, // prevent back navigation
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Success Icon ────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width:  130,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape:    BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:      AppColors.primaryPurple.withOpacity(0.5),
                          blurRadius: 30,
                          offset:     const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size:  65,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Title ───────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Text(
                        'Payment Successful! 🎉',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your advertisement has been submitted\nand is pending admin approval.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Info Card ───────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    width:       double.infinity,
                    padding:     const EdgeInsets.all(20),
                    decoration:  BoxDecoration(
                      color:        isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(20),
                      border:       Border.all(
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon:  Icons.tv_rounded,
                          label: 'Slot',
                          value: widget.slotName,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          icon:  Icons.date_range_rounded,
                          label: 'Duration',
                          value: '${widget.durationDays} Days',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          icon:  Icons.currency_rupee_rounded,
                          label: 'Amount Paid',
                          value: '₹${widget.amountPaid.toStringAsFixed(0)}',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Status Banner ───────────────────────────────────────
                Container(
                  padding:    const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        AppColors.statusPending.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border:       Border.all(
                      color: AppColors.statusPending.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.pending_actions_rounded,
                        color: AppColors.statusPending,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status: Pending Approval',
                              style: TextStyle(
                                color:      AppColors.statusPending,
                                fontWeight: FontWeight.w700,
                                fontSize:   13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Usually takes 2–4 hours. We\'ll notify you!',
                              style: TextStyle(
                                color:   AppColors.statusPending.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Action Buttons ──────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  ),
                  icon:  const Icon(Icons.home_rounded),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    padding:     EdgeInsets.zero,
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                    arguments: 1, // navigate to History tab
                  ),
                  icon:  const Icon(Icons.history_rounded),
                  label: const Text('View My Ads'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final bool     isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width:  36,
          height: 36,
          decoration: BoxDecoration(
            color:        AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryPurple),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize:   14,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
