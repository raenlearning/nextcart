import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class AppEmptyState extends StatelessWidget {
  final String? lottieAsset;
  final String? svgAsset;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double animationSize;

  const AppEmptyState({
    super.key,
    this.lottieAsset,
    this.svgAsset,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.animationSize = 140,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset!,
                width: animationSize,
                height: animationSize,
                repeat: true,
              )
            else if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                width: animationSize,
                height: animationSize,
              ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
