import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/pressable_scale.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistButton extends StatelessWidget {
  final Product product;

  const WishlistButton({super.key, required this.product});

  void _toggleWishlist(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }
    context.read<WishlistBloc>().add(WishlistToggle(product.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isWishlisted = context.watch<WishlistBloc>().contains(product.id);

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
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          color: isWishlisted ? AppColors.favorite : colors.textSecondary,
          size: 16,
        ),
      ),
    );
  }
}