import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ItemThumbnail extends StatelessWidget {
  final String? imageUrl;
  final AppColorScheme colors;
  const ItemThumbnail({super.key, required this.imageUrl, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.card,
        border: Border.all(color: colors.border),
        image: imageUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              Icons.image_not_supported_outlined,
              color: colors.textHint,
              size: 28,
            )
          : null,
    );
  }
}
