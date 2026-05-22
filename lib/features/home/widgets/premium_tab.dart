import 'package:flutter/material.dart';
import 'package:signage_app/core/constants/app_colors.dart';
import 'package:signage_app/core/constants/app_strings.dart';

class PremiumTab extends StatelessWidget {
  const PremiumTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Animated Crown Icon ────────────────────────────────────
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // ── Coming Soon Badge ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: AppColors.primaryPurple,
                ),
                SizedBox(width: 6),
                Text(
                  AppStrings.premiumSoon,
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ──────────────────────────────────────────────────
          Text(
            'Premium Advertising\nLocations',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // ── Description ────────────────────────────────────────────
          Text(
            'We\'re partnering with premium venues — airports, malls, and highways. Get ready for maximum visibility!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // ── Feature Preview Cards ──────────────────────────────────
          ..._premiumFeatures.map(
            (f) => _FeatureRow(
              icon: f['icon'] as IconData,
              title: f['title'] as String,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 40),

          // ── Notify Button ──────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      const Text('You\'ll be notified when Premium launches!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.notifications_active_rounded),
            label: const Text('Notify Me When Available'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.primaryPurple,
              minimumSize: const Size(220, 52),
            ),
          ),
        ],
      ),
    );
  }

  static const _premiumFeatures = [
    {'icon': Icons.flight_takeoff_rounded, 'title': 'Airport Terminals'},
    {'icon': Icons.local_mall_rounded, 'title': 'Premium Malls'},
    {'icon': Icons.directions_car_rounded, 'title': 'Highway Billboards'},
  ];
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primaryPurple),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Soon',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}
