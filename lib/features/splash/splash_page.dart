import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/constants/app_assets.dart';

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
    _checkInitialSession();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

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
    const cream = Color(0xFFF5F0E1);
    const deepBlue = Color.fromARGB(255, 68, 106, 194);

    return Scaffold(
      backgroundColor: deepBlue,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Brand name
              Text(
                'NextCart',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 44,
                  color: cream,
                  letterSpacing: 0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              // Thin brand underline accent
              Container(
                width: 48,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF22D3EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Spacer(flex: 2),

              // Illustration
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