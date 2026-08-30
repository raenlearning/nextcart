import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/cart_fly_animation.dart';

class BumpingCartIcon extends StatefulWidget {
  final int count;
  final AppColorScheme colors;
  final VoidCallback onTap;

  const BumpingCartIcon({
    super.key,
    required this.count,
    required this.colors,
    required this.onTap,
  });

  @override
  State<BumpingCartIcon> createState() => _BumpingCartIconState();
}

class _BumpingCartIconState extends State<BumpingCartIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bumpController;
  late final Animation<double> _bumpScale;

  @override
  void initState() {
    super.initState();

    _bumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bumpScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bumpController, curve: Curves.easeOut));

    cartBumpNotifier.addListener(_onBump);
  }

  void _onBump() {
    _bumpController.forward(from: 0);
  }

  @override
  void dispose() {
    cartBumpNotifier.removeListener(_onBump);
    _bumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 40,
        height: 40 , 
        decoration: BoxDecoration(
          color:  widget.colors.card,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(65)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        
        padding: const EdgeInsets.all(8),
        child: AnimatedBuilder(
          animation: _bumpScale,
          builder: (context, child) {
            return Transform.scale(scale: _bumpScale.value, child: child);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(AppAssets.cartIcon, height: 28, colorFilter: ColorFilter.mode(widget.colors.textPrimary, BlendMode.srcIn)),
              if (widget.count > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.promo,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
