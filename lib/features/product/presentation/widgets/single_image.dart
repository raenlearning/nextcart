import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class SingleImage extends StatelessWidget {
  final String url;

  const SingleImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 48),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, _, _) => Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 60,
            color: context.colors.textHint,
          ),
        ),
      ),
    );
  }
}