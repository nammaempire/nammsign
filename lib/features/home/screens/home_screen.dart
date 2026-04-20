import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../history/screens/history_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/local_tab.dart';
import '../widgets/premium_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int                  _currentIndex = 0;
  late TabController   _tabController;

  final List<Widget> _pages = [
    const _AdSlotsPage(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index:    _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex:    _currentIndex,
          onTap:           (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation:       0,
          items: const [
            BottomNavigationBarItem(
              icon:           Icon(Icons.tv_outlined),
              activeIcon:     Icon(Icons.tv_rounded),
              label:          'Ad Slots',
            ),
            BottomNavigationBarItem(
              icon:           Icon(Icons.history_outlined),
              activeIcon:     Icon(Icons.history_rounded),
              label:          'History',
            ),
            BottomNavigationBarItem(
              icon:           Icon(Icons.person_outline_rounded),
              activeIcon:     Icon(Icons.person_rounded),
              label:          'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ad Slots Page (with Tab Bar) ──────────────────────────────────────────────
class _AdSlotsPage extends StatefulWidget {
  const _AdSlotsPage();

  @override
  State<_AdSlotsPage> createState() => _AdSlotsPageState();
}

class _AdSlotsPageState extends State<_AdSlotsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth   = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  28,
              height: 28,
              decoration: BoxDecoration(
                gradient:     AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tv_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          // Theme Toggle
          Consumer<ThemeProvider>(
            builder: (_, themeProvider, __) => IconButton(
              icon: Icon(
                themeProvider.isDark
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
                color: AppColors.primaryPurple,
              ),
              onPressed: themeProvider.toggleTheme,
              tooltip: themeProvider.isDark
                  ? AppStrings.lightMode
                  : AppStrings.darkMode,
            ),
          ),

          // Notification Bell
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: AppStrings.local),
                Tab(text: AppStrings.premium),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LocalTab(),
          PremiumTab(),
        ],
      ),
    );
  }
}
