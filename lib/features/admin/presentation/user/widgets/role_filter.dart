import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class RoleFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const RoleFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _options = [
    ('all', 'Semua'),
    ('admin', 'Admin'),
    ('buyer', 'Pembeli'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.map((opt) {
          final isActive = opt.$1 == value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onChanged(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  opt.$2,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : colors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}