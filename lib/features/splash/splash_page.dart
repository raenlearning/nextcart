import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkInitialSession();
      }
    });

    _controller.forward();
  }

  Future<void> _checkInitialSession() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

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
            context.go('/');
          }
        }
      } catch (e) {
        if (mounted) context.go('/');
      }
    } else if (onboardingDone) {
      if (mounted) context.go('/auth');
    } else {
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              Text(
                'NextCart',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w900,
                  fontSize: 44,
                  color: AppColors.splashCream,
                  letterSpacing: 0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                width: 48,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.splashAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Spacer(flex: 2),

              SvgPicture.asset(
                AppAssets.splashIllustration,
                width: MediaQuery.sizeOf(context).width * 0.92,
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
