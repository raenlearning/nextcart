import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/user/bumping_cart_icon.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';

class DetailTopBar extends StatelessWidget {
  final AppColorScheme colors;
  final VoidCallback? onShare;

  const DetailTopBar({super.key, required this.colors, this.onShare});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            colors: colors,
            onTap: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Detail Produk',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),

          Row(
            children: [
              if (onShare != null)
                _CircleIconBtn(
                  icon: Icons.share_outlined,
                  colors: colors,
                  onTap: onShare!,
                ),
              const SizedBox(width: 6),
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int uniqueProductsCount = 0;
                  if (state is CartLoaded) {
                    uniqueProductsCount = state.cartItems.length;
                  }
                  return BumpingCartIcon(
                    count: uniqueProductsCount,
                    colors: colors,
                    onTap: () {
                      context.push('/cart');
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final AppColorScheme colors;
  final VoidCallback onTap;

  const _CircleIconBtn({
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.card,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, size: 17, color: colors.textPrimary),
      ),
    );
  }
}
