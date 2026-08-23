import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/service/address_store.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/pressable_scale.dart';
import 'package:nextcart/core/widgets/user/home_address_sheet.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';

class HomeAppBar extends StatefulWidget {
  final VoidCallback onLogoutTap;

  const HomeAppBar({super.key, required this.onLogoutTap});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  void initState() {
    super.initState();
    AddressStore.instance.load();
  }

  Future<void> _openAddressPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const HomeAddressSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: PressableScale(
            onTap: _openAddressPicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ValueListenableBuilder(
                valueListenable: AddressStore.instance,
                builder: (context, selected, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kirim ke',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selected?.displayName ??
                                  'Pilih alamat pengiriman',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: colors.textPrimary,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            int uniqueProductsCount = 0;
            if (state is CartLoaded) {
              uniqueProductsCount = state.cartItems.length;
            }

            return PressableScale(
              onTap: () {
                context.push('/cart');
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.card,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.bagShopping,
                      size: 20,
                      color: colors.textPrimary,
                    ),

                    if (uniqueProductsCount > 0)
                      Positioned(
                        right: 4,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.promo,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          constraints: const BoxConstraints(minWidth: 16),
                          child: Text(
                            uniqueProductsCount > 99
                                ? '99+'
                                : '$uniqueProductsCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
