import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

class SignageApp extends StatelessWidget {
  const SignageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
        return MaterialApp(
          title:              AppStrings.appName,
          debugShowCheckedModeBanner: false,
          themeMode:          themeProvider.themeMode,
          theme:              AppTheme.lightTheme,
          darkTheme:          AppTheme.darkTheme,
          home:               const _SplashRouter(),
          routes: {
            '/login':      (_) => const LoginScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/home':       (_) => const HomeScreen(),
          },
        );
      },
    );
  }
}

// ── Splash / Router ───────────────────────────────────────────────────────────
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth     = context.read<AuthProvider>();
    final loggedIn = await auth.checkAuth();

    if (!mounted) return;

    if (loggedIn) {
      if (auth.onboardingDone) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0A1E), Color(0xFF1A0050), Color(0xFF0F0A1E)],
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ─────────────────────────────────────────────
                  Container(
                    width:   180,
                    height:  180,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color:      const Color(0xFF7C3AED).withOpacity(0.5),
                          blurRadius: 30,
                          offset:     const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── App Name ─────────────────────────────────────────
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.tagline,
                    style: TextStyle(
                      color:   Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // ── Loading indicator ─────────────────────────────────
                  const SizedBox(
                    width:  24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color:       Color(0xFFA855F7),
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
