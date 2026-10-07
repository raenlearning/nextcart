import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/pressable_scale.dart';

class BentoTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Gradient? gradient;
  final Color? color;

  const BentoTile({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 22,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    final Widget container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? colors.card) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isDark ? Border.all(color: colors.border) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );

    if (onTap == null) return container;
    return PressableScale(onTap: onTap, child: container);
  }
}
