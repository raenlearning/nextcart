import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class SingleImage extends StatelessWidget {
  final String url;

  const SingleImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (_, _, _) => Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 60,
          color: context.colors.textHint,
        ),
      ),
    );
  }
}