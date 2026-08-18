import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'single_image.dart';

class ImageHero extends StatefulWidget {
  final Product product;
  final PageController pageController;
  final double height;
  final bool isDark;
  final AppColorScheme colors;

  const ImageHero({
    super.key,
    required this.product,
    required this.pageController,
    required this.height,
    required this.isDark,
    required this.colors,
  });

  @override
  State<ImageHero> createState() => _ImageHeroState();
}

class _ImageHeroState extends State<ImageHero> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final page = widget.pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.product.images.isNotEmpty;
    final imageCount = widget.product.images.length;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!hasImages)
            ColoredBox(
              color: widget.colors.inputFill,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 80,
                  color: widget.colors.textHint,
                ),
              ),
            )
          else
            PageView.builder(
              controller: widget.pageController,
              itemCount: imageCount,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, index) =>
                  SingleImage(url: widget.product.images[index]),
            ),

          if (hasImages && imageCount > 1)
            Positioned(
              top: 16,
              right: 16,
              child: _ImageCounterPill(
                current: _currentPage + 1,
                total: imageCount,
                colors: widget.colors,
              ),
            ),

          if (hasImages && imageCount > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(90),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SmoothPageIndicator(
                    controller: widget.pageController,
                    count: imageCount,
                    effect: ExpandingDotsEffect(
                      dotWidth: 6,
                      dotHeight: 6,
                      expansionFactor: 2.5,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withAlpha(90),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageCounterPill extends StatelessWidget {
  final int current;
  final int total;
  final AppColorScheme colors;

  const _ImageCounterPill({
    required this.current,
    required this.total,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(90),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$current/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}