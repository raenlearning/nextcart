import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/user/bumping_cart_icon.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';

class DetailTopBar extends StatelessWidget {
  final AppColorScheme colors;
  final VoidCallback? onShare;
  final VoidCallback? onWhatsApp;

  const DetailTopBar({
    super.key,
    required this.colors,
    this.onShare,
    this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIconBtn(
            colors: colors,
            onTap: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 17,
              color: colors.textPrimary,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              if (onWhatsApp != null) ...[
                _CircleIconBtn(
                  colors: colors,
                  onTap: onWhatsApp!,
                  icon: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: 18,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (onShare != null)
                _CircleIconBtn(
                  colors: colors,
                  onTap: onShare!,
                  icon: Icon(
                    Icons.share_outlined,
                    size: 17,
                    color: colors.textPrimary,
                  ),
                ),

              const SizedBox(width: 8),

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
  final AppColorScheme colors;
  final VoidCallback onTap;
  final Widget icon;

  const _CircleIconBtn({
    required this.colors,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.card,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(60)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}
