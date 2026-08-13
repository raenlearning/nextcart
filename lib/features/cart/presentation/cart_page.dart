import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/helper/payment_success.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/data/repository/address_repository.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/cart/presentation/payment_webview_page.dart';

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

            if (context.mounted) {
              if (isSuccess == true) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const PaymentSuccessDialog(),
                );

                await Future.delayed(const Duration(milliseconds: 4000));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Pesanan disimpan ke riwayat, menunggu pembayaran.',
                    ),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }

              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
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
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            );
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
              return _EmptyCart(colors: colors);
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
          fontSize: 18,
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
                child:
                    BlocSelector<
                      CartBloc,
                      CartState,
                      List<Map<String, dynamic>>
                    >(
                      selector: (state) =>
                          state is CartLoaded ? state.cartItems : [],
                      builder: (context, items) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            children: items
                                .map(
                                  (item) => _CartItemTile(
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

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const _ShippingSection(),
                ),
              ),

              SliverToBoxAdapter(
                child: BlocSelector<CartBloc, CartState, double>(
                  selector: (state) =>
                      state is CartLoaded ? state.totalPrice.toDouble() : 0,
                  builder: (context, subtotal) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _PromoSection(
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
                      child: _PriceSummary(
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
              return _CheckoutBar(
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

            return _CheckoutBar(
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

class _CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final AppColorScheme colors;

  const _CartItemTile({super.key, required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    final product = item['products'] as Map<String, dynamic>?;
    final images = product?['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;
    final price = (product?['price'] as num?) ?? 0;
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    final int? stock = (product?['stock'] as num?)?.toInt();
    final itemId = item['id'] as String;
    final storeName = product?['store_name'] as String? ?? 'NextCart Store';
    final outOfStock = stock == 0;
    final atStockLimit = stock != null && stock > 0 && quantity >= stock;
    final isLowStock = stock != null && stock > 0 && stock <= 5;

    return Dismissible(
      key: ValueKey(itemId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => context.read<CartBloc>().add(RemoveFromCart(itemId)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ItemThumbnail(imageUrl: imageUrl, colors: colors),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?['name'] ?? 'Produk Terhapus',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    storeName,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _QuantityStepper(
                    quantity: quantity,
                    colors: colors,
                    incrementEnabled: !outOfStock && !atStockLimit,
                    onDecrement: () {
                      if (quantity > 1) {
                        context.read<CartBloc>().add(
                          UpdateCartQuantity(itemId, quantity - 1),
                        );
                      } else {
                        context.read<CartBloc>().add(RemoveFromCart(itemId));
                      }
                    },
                    onIncrement: () {
                      if (!outOfStock && !atStockLimit) {
                        context.read<CartBloc>().add(
                          UpdateCartQuantity(itemId, quantity + 1),
                        );
                      }
                    },
                  ),
                  if (outOfStock)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Stok habis, silakan hapus produk',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (isLowStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Stok tersisa $stock',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.rupiah(price),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  final String? imageUrl;
  final AppColorScheme colors;
  const _ItemThumbnail({required this.imageUrl, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.card,
        border: Border.all(color: colors.border),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              Icons.image_not_supported_outlined,
              color: colors.textHint,
              size: 28,
            )
          : null,
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final AppColorScheme colors;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool incrementEnabled;

  const _QuantityStepper({
    required this.quantity,
    required this.colors,
    required this.onDecrement,
    required this.onIncrement,
    this.incrementEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onDecrement, colors: colors),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add,
            onTap: onIncrement,
            colors: colors,
            enabled: incrementEnabled,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final bool enabled;

  const _StepBtn({
    required this.icon,
    required this.onTap,
    required this.colors,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: enabled ? colors.card : colors.card.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 12,
          color: enabled ? colors.textPrimary : colors.textHint,
        ),
      ),
    );
  }
}

class _ShippingSection extends StatelessWidget {
  const _ShippingSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is! CartLoaded) return const SizedBox.shrink();
        final address = state.selectedAddress;
        final courier = state.selectedCourier;
        final weight = state.totalWeightGrams;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ShippingCard(
              icon: Icons.location_on_outlined,
              title: 'Alamat Pengiriman',
              subtitle: address == null
                  ? 'Pilih alamat pengiriman'
                  : _addressPreview(address),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () => _openAddressPicker(context),
            ),
            const SizedBox(height: 12),
            _ShippingCard(
              icon: Icons.local_shipping_outlined,
              title: 'Metode Pengiriman',
              subtitle: courier == null
                  ? 'Pilih kurir'
                  : '${courier['name']} ${courier['service']}'
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' '),
              trailing: Text(
                CurrencyFormatter.rupiah(state.shippingFee),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              onTap: (address == null || state.shippingRates.isEmpty)
                  ? null
                  : () => _openCourierPicker(context),
              footnote: weight > 0
                  ? 'Total berat ${_formatWeight(weight)}'
                  : 'Total berat 0 g (ongkir dihitung min 1 kg)',
            ),
          ],
        );
      },
    );
  }

  String _addressPreview(Map<String, dynamic> address) {
    final parts = [
      address['full_address'] as String?,
      address['district'] as String?,
      address['city'] as String?,
      address['province'] as String?,
      address['postal_code'] as String?,
    ].whereType<String>().where((p) => p.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  String _formatWeight(int grams) {
    if (grams >= 1000) {
      final kg = grams / 1000;
      return kg == kg.roundToDouble()
          ? '${kg.round()} kg'
          : '${kg.toStringAsFixed(1)} kg';
    }
    return '$grams g';
  }

  void _openAddressPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressPickerSheet(
        onSelected: (address) {
          Navigator.pop(context);
          context.read<CartBloc>().add(SelectShippingAddress(address));
        },
      ),
    );
  }

  void _openCourierPicker(BuildContext context) {
    final state = context.read<CartBloc>().state;
    if (state is! CartLoaded) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CourierPickerSheet(
        rates: state.shippingRates,
        selectedCode: state.selectedCourier?['code'],
        onSelected: (courier) {
          Navigator.pop(context);
          context.read<CartBloc>().add(SelectCourier(courier));
        },
      ),
    );
  }
}

class _ShippingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final String? footnote;
  final VoidCallback? onTap;

  const _ShippingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.footnote,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.textOnPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (footnote != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        footnote!,
                        style: TextStyle(
                          color: colors.textHint,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressPickerSheet extends StatefulWidget {
  final void Function(Map<String, dynamic> address) onSelected;

  const _AddressPickerSheet({required this.onSelected});

  @override
  State<_AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<_AddressPickerSheet> {
  final AddressRepository _repository = AddressRepository();
  late Future<List<ShippingAddress>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchAddresses();
  }

  void _reload() {
    setState(() => _future = _repository.fetchAddresses());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Alamat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<ShippingAddress>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                final addresses = snapshot.data ?? [];
                if (addresses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          color: colors.textHint,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada alamat tersimpan',
                          style: TextStyle(color: colors.textHint),
                        ),
                      ],
                    ),
                  );
                }
                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final a = addresses[index];
                      final parts = [
                        a.fullAddress,
                        a.district,
                        a.city,
                        a.province,
                        a.postalCode,
                      ].whereType<String>().where((p) => p.trim().isNotEmpty);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(Icons.location_on_outlined,
                            color: AppColors.primary, size: 20),
                        title: Text(
                          '${a.recipientName ?? ''} ${a.phone ?? ''}'.trim(),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          parts.join(', '),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => widget.onSelected({
                          'id': a.id,
                          'full_address': a.fullAddress,
                          'province': a.province,
                          'city': a.city,
                          'district': a.district,
                          'postal_code': a.postalCode,
                        }),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.push('/address-form');
                  if (context.mounted) _reload();
                },
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Tambah Alamat Baru'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourierPickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> rates;
  final String? selectedCode;
  final void Function(Map<String, dynamic> courier) onSelected;

  const _CourierPickerSheet({
    required this.rates,
    required this.selectedCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Kurir',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: rates.length,
                itemBuilder: (context, index) {
                  final courier = rates[index];
                  final code = courier['code'] as String?;
                  final isSelected = code == selectedCode;
                  final eta = '${courier['eta_min']}-${courier['eta_max']} hari';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? AppColors.primary
                          : colors.textHint,
                      size: 20,
                    ),
                    title: Text(
                      '${courier['name']} ${courier['service']}'.trim(),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      'Estimasi $eta',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      CurrencyFormatter.rupiah(
                        (courier['price'] as num?)?.toDouble() ?? 0,
                      ),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () => onSelected(courier),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoSection extends StatelessWidget {
  final TextEditingController controller;
  final AppColorScheme colors;

  const _PromoSection({required this.controller, required this.colors});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartBloc, CartState, Map<String, dynamic>?>(
      selector: (state) => state is CartLoaded ? state.voucher : null,
      builder: (context, voucher) {
        final applied = voucher != null && voucher.isNotEmpty;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(
                applied ? Icons.sell_rounded : Icons.local_offer_rounded,
                color: applied ? AppColors.success : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: applied
                    ? Text(
                        'Kupon ${voucher['code']} diterapkan',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      )
                    : TextField(
                        controller: controller,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          
                          hintText: 'Masukkan kode voucher',
                          hintStyle: TextStyle(
                            color: colors.textHint,
                            fontSize: 12,

                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12 , vertical: 12),
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              if (applied)
                TextButton(
                  onPressed: () {
                    controller.clear();
                    context.read<CartBloc>().add(ClearVoucher());
                  },
                  child: const Text('Hapus'),
                )
              else
                FilledButton(
                  onPressed: () {
                    final code = controller.text.trim();
                    if (code.isNotEmpty) {
                      context.read<CartBloc>().add(ApplyVoucher(code));
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Pakai'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final double subtotal;
  final Map<String, dynamic>? voucher;
  final double shippingFee;
  final AppColorScheme colors;

  const _PriceSummary({
    required this.subtotal,
    required this.voucher,
    required this.shippingFee,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final discount =
        context.read<CartBloc>().calculateDiscount(subtotal, voucher);
    final double deliveryFee = shippingFee;
    final double vat = (subtotal - discount) * 0.11;
    final double total = subtotal > 0
        ? subtotal - discount + deliveryFee + vat
        : 0;

    return Column(
      children: [
        _SummaryRow(
          label: 'Voucher Diskon',
          value: CurrencyFormatter.rupiah(discount),
          colors: colors,
          valueColor: AppColors.success,
        ),
        const SizedBox(height: 10),
        _SummaryRow(
          label: 'Biaya Pengiriman',
          value: CurrencyFormatter.rupiah(deliveryFee),
          colors: colors,
          valueColor: AppColors.sale,
        ),
        const SizedBox(height: 10),
        _SummaryRow(
          label: 'PPN (11%)',
          value: CurrencyFormatter.rupiah(vat),
          colors: colors,
        ),
        const SizedBox(height: 10),
        _SummaryRow(
          label: 'Total',
          value: CurrencyFormatter.rupiah(total),
          colors: colors,
          isTotal: true,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColorScheme colors;
  final bool isTotal;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.colors,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: isTotal ? 15 : 13.5,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.textPrimary,
            fontSize: isTotal ? 15 : 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final AppColorScheme colors;
  final List<Map<String, dynamic>> cartItems;

  const _CheckoutBar({
    required this.total,
    required this.colors,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: ElevatedButton(
        onPressed: total > 0
            ? () {
                context.read<CartBloc>().add(
                  TriggerCheckout(cartItems: cartItems),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.slate200,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CheckoutLoading) {
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            }
            return const Text(
              'Beli Sekarang',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final AppColorScheme colors;
  const _EmptyCart({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Keranjang anda masih kosong',
              style: TextStyle(
                color: colors.textHint,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mulai Belanja',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
