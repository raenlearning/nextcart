import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/shimmer_box.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/cart/presentation/payment_status_page.dart';
import 'package:nextcart/features/cart/presentation/payment_webview_page.dart';
import 'package:nextcart/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:nextcart/features/cart/presentation/widgets/checkout_bar.dart';
import 'package:nextcart/features/cart/presentation/widgets/empty_cart.dart';
import 'package:nextcart/features/cart/presentation/widgets/price_summary.dart';
import 'package:nextcart/features/cart/presentation/widgets/promo_section.dart';
import 'package:nextcart/features/cart/presentation/widgets/shipping_section.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCart());
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) async {
          if (state is CheckoutRedirectReady) {
            final bool? isSuccess = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PaymentWebViewPage(redirectUrl: state.redirectUrl),
              ),
            );

            if (context.mounted && isSuccess != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Pesanan disimpan ke riwayat, menunggu pembayaran.',
                  ),
                  backgroundColor: AppColors.warning,
                ),
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }

          if (state is CheckoutStatusVerified && context.mounted) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaymentStatusPage(status: state),
                fullscreenDialog: true,
              ),
            );

            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }

          if (state is CartError && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const _CartShimmerSkeleton();
          }

          if (state is CartError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${state.message}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (state is CartLoaded) {
            if (state.cartItems.isEmpty) {
              return EmptyCart(colors: colors);
            }

            return _CartBody(promoController: _promoController, colors: colors);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppColorScheme colors) {
    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
      title: Text(
        'Keranjang Belanja',
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  final TextEditingController promoController;
  final AppColorScheme colors;

  const _CartBody({required this.promoController, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BlocSelector<CartBloc, CartState, List<Map<String, dynamic>>>(
                  selector: (state) =>
                      state is CartLoaded ? state.cartItems : [],
                  builder: (context, items) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        children: items
                            .map(
                              (item) => CartItemTile(
                                key: ValueKey(item['id']),
                                item: item,
                                colors: colors,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: ShippingSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocSelector<CartBloc, CartState, double>(
                  selector: (state) =>
                      state is CartLoaded ? state.totalPrice.toDouble() : 0,
                  builder: (context, subtotal) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: PromoSection(
                        controller: promoController,
                        colors: colors,
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    final double subtotal =
                        state is CartLoaded ? state.totalPrice.toDouble() : 0;
                    final voucher =
                        state is CartLoaded ? state.voucher : null;
                    final shippingFee =
                        state is CartLoaded ? state.shippingFee : 0.0;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: PriceSummary(
                        subtotal: subtotal,
                        voucher: voucher,
                        shippingFee: shippingFee,
                        colors: colors,
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is! CartLoaded) {
              return CheckoutBar(
                total: 0,
                cartItems: const [],
                colors: colors,
              );
            }

            final subtotal = state.totalPrice.toDouble();
            final double total = subtotal > 0
                ? context
                    .read<CartBloc>()
                    .checkoutTotal(subtotal, state.voucher, state.shippingFee)
                : 0;

            return CheckoutBar(
              total: total,
              cartItems: state.cartItems,
              colors: colors,
            );
          },
        ),
      ],
    );
  }
}

class _CartShimmerSkeleton extends StatelessWidget {
  const _CartShimmerSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const ShimmerBox(width: 80, height: 80, radius: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                        width: 120 + (index * 30).toDouble(),
                        height: 14,
                        radius: 6,
                      ),
                      const SizedBox(height: 6),
                      const ShimmerBox(width: 80, height: 10, radius: 5),
                      const SizedBox(height: 10),
                      const ShimmerBox(width: 100, height: 12, radius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const ShimmerBox(width: 60, height: 14, radius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
