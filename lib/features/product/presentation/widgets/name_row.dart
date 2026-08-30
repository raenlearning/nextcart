import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

import '../../../../core/theme/app_fonts.dart';

class NameRow extends StatefulWidget {
  final String name;
  final bool isWishlisted;
  final AppColorScheme colors;
  final bool isDark;
  final VoidCallback onWishlistTap;
  final Key? wishlistIconKey;
  
  const NameRow({
    super.key,
    required this.name,
    required this.isWishlisted,
    required this.colors,
    required this.isDark,
    required this.onWishlistTap,
    this.wishlistIconKey,
  });

  @override
  State<NameRow> createState() => _NameRowState();
}

class _NameRowState extends State<NameRow> with SingleTickerProviderStateMixin {
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _popScale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.9), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
  ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));

  @override
  void didUpdateWidget(covariant NameRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isWishlisted && widget.isWishlisted) {
      _popController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.name,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: widget.colors.textPrimary,
              height: 1.3,
              fontFamily: AppFonts.secondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: widget.onWishlistTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: KeyedSubtree(
              key: widget.wishlistIconKey,
              child: ScaleTransition(
                scale: _popScale,
                child: Icon(
                  widget.isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: widget.isWishlisted
                      ? AppColors.favorite
                      : widget.colors.textHint,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
