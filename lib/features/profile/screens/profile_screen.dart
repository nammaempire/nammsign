import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar & Name ─────────────────────────────────────────
            _ProfileHeader(
              name:
                  auth.userName.isNotEmpty ? auth.userName : 'SignageAds User',
              phone: auth.userPhone,
              email: auth.userEmail,
              type: auth.userType,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // ── Stats Cards ───────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '3',
                    label: 'Total Ads',
                    icon: Icons.tv_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '1',
                    label: 'Live Now',
                    icon: Icons.live_tv_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '₹8.1K',
                    label: 'Spent',
                    icon: Icons.currency_rupee_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Settings Section ──────────────────────────────────────
            _SectionHeader(title: AppStrings.settings, isDark: isDark),
            const SizedBox(height: 12),

            // Theme Toggle
            _SettingsTile(
              icon: themeProvider.isDark
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round,
              iconColor: AppColors.primaryPurple,
              title: themeProvider.isDark
                  ? AppStrings.lightMode
                  : AppStrings.darkMode,
              subtitle: 'Switch app appearance',
              trailing: Switch.adaptive(
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeThumbColor: AppColors.primaryPurple,
              ),
              onTap: themeProvider.toggleTheme,
              isDark: isDark,
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.info,
              title: 'Notifications',
              subtitle: 'Ad status, updates & more',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // ── Account Section ───────────────────────────────────────
            _SectionHeader(title: 'Account', isDark: isDark),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primaryPurple,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.receipt_long_outlined,
              iconColor: AppColors.success,
              title: 'Payment History',
              subtitle: 'View all transactions',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.verified_user_outlined,
              iconColor: AppColors.info,
              title: 'Verification Status',
              subtitle: auth.onboardingDone
                  ? 'Your account is verified'
                  : 'Complete verification',
              trailing: Icon(
                auth.onboardingDone
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color:
                    auth.onboardingDone ? AppColors.success : AppColors.warning,
              ),
              onTap: auth.onboardingDone
                  ? null
                  : () => Navigator.pushNamed(context, '/onboarding'),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // ── Support Section ───────────────────────────────────────
            _SectionHeader(title: 'Support', isDark: isDark),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.help_outline_rounded,
              iconColor: AppColors.warning,
              title: 'Help & FAQ',
              subtitle: 'Get answers to common questions',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.policy_outlined,
              iconColor: AppColors.darkTextSecondary,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // ── Logout ────────────────────────────────────────────────
            GestureDetector(
              onTap: () => _showLogoutDialog(context, auth),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.error),
                    SizedBox(width: 10),
                    Text(
                      AppStrings.logout,
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Version ────────────────────────────────────────────────
            Text(
              AppStrings.appVersion,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(
      BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await auth.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String type;
  final bool isDark;

  const _ProfileHeader({
    required this.name,
    required this.phone,
    required this.email,
    required this.type,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '+91 $phone',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type.isNotEmpty
                        ? type[0].toUpperCase() + type.substring(1)
                        : 'Individual',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primaryPurple),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            trailing,
          ],
        ),
      ),
    );
  }
}
