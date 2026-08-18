import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;

  const ProductImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colors.inputFill,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.textHint,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.broken_image_outlined,
                size: 36,
                color: colors.textHint,
              ),
            )
          : Icon(Icons.image_not_supported, size: 40, color: colors.textHint),
    );
  }
}