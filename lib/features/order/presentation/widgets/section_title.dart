import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final AppColorScheme colors;

  const SectionTitle({
    super.key,
    required this.title,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}
