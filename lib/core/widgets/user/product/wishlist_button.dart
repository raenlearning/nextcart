import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/pressable_scale.dart';
import 'package:nextcart/core/widgets/user/product/heart_burst_animation.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistButton extends StatefulWidget {
  final Product product;

  const WishlistButton({super.key, required this.product});

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _popScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.5),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.5, end: 0.9),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.9, end: 1.0),
      weight: 30,
    ),
  ]).animate(
    CurvedAnimation(parent: _popController, curve: Curves.easeOut),
  );

  final GlobalKey _iconKey = GlobalKey();

  void _toggleWishlist(BuildContext context) {
    HapticFeedback.selectionClick();

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ToastHelper.showToast(
        context,
        'Silakan login terlebih dahulu',
        ToastSeverity.info,
      );
      return;
    }

    final bloc = context.read<WishlistBloc>();
    final willAdd = !bloc.contains(widget.product.id);
    bloc.add(WishlistToggle(widget.product.id));

    if (willAdd) {
      HeartBurstAnimation.burst(context: context, key: _iconKey);
      _popController.forward(from: 0);
      ToastHelper.showToast(
        context,
        '${widget.product.name} ditambahkan ke wishlist',
        ToastSeverity.success,
      );
    } else {
      ToastHelper.showToast(
        context,
        '${widget.product.name} dihapus dari wishlist',
        ToastSeverity.info,
      );
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isWishlisted =
        context.watch<WishlistBloc>().contains(widget.product.id);

    return PressableScale(
      onTap: () => _toggleWishlist(context),
      pressedScale: 0.85,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: colors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: ScaleTransition(
            scale: _popScale,
            child: KeyedSubtree(
              key: _iconKey,
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color:
                    isWishlisted ? AppColors.favorite : colors.textSecondary,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
