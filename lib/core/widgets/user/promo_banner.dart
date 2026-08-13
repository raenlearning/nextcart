import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/constants/app_assets.dart';

class HomeBannerCarousel extends StatelessWidget {
  const HomeBannerCarousel({super.key});

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

  @override
  Widget build(BuildContext context) {
    final double cardHeight = (MediaQuery.sizeOf(context).width * 0.40).clamp(
      150.0,
      190.0,
    );

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _slides.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return _BannerCard(slide: _slides[index]);
        },
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerSlide slide;

  const _BannerCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double cardWidth = size.width * 0.78;
    final double cardHeight = (size.width * 0.40).clamp(150.0, 190.0);

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.only(right: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge container without fixed width/height constraint
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
                  const SizedBox(height: 8),
                  Text(
                    slide.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
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
          ),
        ],
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