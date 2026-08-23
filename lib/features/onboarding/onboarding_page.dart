import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      title: 'Temukan Gadget & Tech Terkini',
      description:
          'Jelajahi berbagai produk teknologi pilihan berkualitas dengan garansi resmi dan harga terbaik.',
      imagePath: AppAssets.onBoarding1,
    ),
    OnboardingItem(
      title: 'Pembayaran Aman & Instant',
      description:
          'Nikmati kemudahan transaksi yang cepat dan terintegrasi secara aman dengan Midtrans Snap.',
      imagePath: AppAssets.onBoarding2,
    ),
    OnboardingItem(
      title: 'Pengiriman Cepat ke Lokasimu',
      description:
          'Pilih lokasi alamat pengiriman secara akurat melalui peta interaktif dan pantau status pesananmu.',
      imagePath: AppAssets.onBoarding3,
    ),
  ];

  bool get _isLastPage => _currentIndex == _slides.length - 1;
  bool get _isFirstPage => _currentIndex == 0;

  void _onFinishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) context.go('/auth');
  }

  void _goToPrevious() {
    if (_isFirstPage) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goToNext() {
    if (_isLastPage) {
      _onFinishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-bleed image + title/description per slide
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final item = _slides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white38,
                          size: 48,
                        ),
                      ),
                    ),
                  ),

                  // Top gradient — keeps status bar / brand row legible
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // Bottom gradient — text legibility, blends into control bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 340,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black87,
                            Colors.black,
                          ],
                          stops: [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Title + description
                  Positioned(
                    left: 28,
                    right: 28,
                    bottom: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.75),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Top bar: brand wordmark + Skip
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NEXTCART',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IgnorePointer(
                    ignoring: _isLastPage,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isLastPage ? 0.0 : 1.0,
                      child: TextButton(
                        onPressed: _isLastPage ? null : _onFinishOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar: dots + Previous / Next
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _slides.length,
                      effect: ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        expansionFactor: 3.5,
                        activeDotColor: AppColors.primary,
                        dotColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IgnorePointer(
                          ignoring: _isFirstPage,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isFirstPage ? 0.0 : 1.0,
                            child: TextButton(
                              onPressed: _isFirstPage ? null : _goToPrevious,
                              child: const Text(
                                'Kembali',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            onPressed: _goToNext,
                            child: Text(
                              _isLastPage ? 'Mulai' : 'Lanjut',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
