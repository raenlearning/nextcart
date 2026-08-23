import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/constants/app_assets.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  static const List<_BannerSlide> _slides = [
    _BannerSlide(
      badge: 'Diskon 25%',
      title: 'Temukan\nProduk Terbaru',
      cta: 'Belanja Sekarang',
      image: AppAssets.bannerTech1,
    ),
    _BannerSlide(
      badge: 'Promo Spesial',
      title: 'Gadget Favorit\nMakin Hemat',
      cta: 'Lihat Promo',
      image: AppAssets.bannerTech2,
    ),
    _BannerSlide(
      badge: 'Gratis Ongkir',
      title: 'Belanja Puas\nTanpa Biaya Kirim',
      cta: 'Cek Syarat',
      image: AppAssets.bannerTech3,
    ),
    _BannerSlide(
      badge: 'Hari Ini Saja',
      title: 'Flash Sale\nSampai Stok Habis',
      cta: 'Grab It Fast',
      image: AppAssets.bannerTech4,
    ),
  ];

  final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_current + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  void _rescheduleAutoPlay() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), _startAutoPlay);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = (MediaQuery.sizeOf(context).width * 0.44).clamp(
      170.0,
      200.0,
    );

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: Listener(
            onPointerDown: (_) => _stopAutoPlay(),
            onPointerUp: (_) => _rescheduleAutoPlay(),
            onPointerCancel: (_) => _rescheduleAutoPlay(),
            child: PageView.builder(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) => setState(() => _current = index),
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return _BannerCard(
                  slide: _slides[index],
                  isActive: index == _current,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final isActive = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerSlide slide;
  final bool isActive;

  const _BannerCard({required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final double cardHeight = (MediaQuery.sizeOf(context).width * 0.44).clamp(
      170.0,
      200.0,
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(right: isActive ? 10 : 14),
      child: Container(
        height: cardHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(slide.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black45, Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      slide.badge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    slide.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      context.push('/view-all');
                    },
                    child: Text(
                      slide.cta,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerSlide {
  final String badge;
  final String title;
  final String cta;
  final String image;

  const _BannerSlide({
    required this.badge,
    required this.title,
    required this.cta,
    required this.image,
  });
}