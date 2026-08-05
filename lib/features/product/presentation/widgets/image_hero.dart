import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'single_image.dart';

class ImageHero extends StatelessWidget {
  final Product product;
  final PageController pageController;
  final double height;
  final bool isDark;
  final AppColorScheme colors;

  const ImageHero({super.key, 
    required this.product,
    required this.pageController,
    required this.height,
    required this.isDark,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (product.images.isEmpty)
            Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 80,
                color: colors.textHint,
              ),
            )
          else
            PageView.builder(
              controller: pageController,
              itemCount: product.images.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, index) =>
                  SingleImage(url: product.images[index]),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    (isDark ? const Color(0xFF0F172A) : colors.card)
                        .withAlpha(180),
                  ],
                ),
              ),
            ),
          ),
          if (product.images.length > 1)
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: product.images.length,
                  effect: ExpandingDotsEffect(
                    dotWidth: 7,
                    dotHeight: 7,
                    expansionFactor: 3,
                    activeDotColor: AppColors.primary,
                    dotColor: isDark
                        ? Colors.white.withAlpha(60)
                        : Colors.black.withAlpha(30),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}