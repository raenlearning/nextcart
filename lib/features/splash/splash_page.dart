import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkInitialSession();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  Future<void> _checkInitialSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .maybeSingle();

        final String role = profile?['role'] as String? ?? 'buyer';

        if (mounted) {
          if (role == 'admin') {
            context.go('/admin-dashboard');
          } else {
            context.go('/home');
          }
        }
      } catch (e) {
        if (mounted) context.go('/home');
      }
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                     Lottie.asset(
                       AppAssets.splashLogo,
                       width: 90,
                       height: 90,
                       repeat: true,
                     ),
                    const SizedBox(height: 24),
                    // Nama Brand
                    Text(
                      'Nextcart',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      'Teknologi Gen-Baru • Tanpa Ribet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
