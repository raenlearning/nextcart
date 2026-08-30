
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class FormSection extends StatelessWidget {
  final String label;
  const FormSection({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}