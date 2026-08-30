import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/cart/presentation/widgets/address_picker_sheet.dart';
import 'package:nextcart/features/cart/presentation/widgets/courier_picker_sheet.dart';
import 'package:nextcart/features/cart/presentation/widgets/shipping_card.dart';

class ShippingSection extends StatelessWidget {
  const ShippingSection({super.key});

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
            ShippingCard(
              icon: Icons.location_on_outlined,
              title: 'Alamat Pengiriman',
              subtitle: address == null
                  ? 'Pilih alamat pengiriman'
                  : _addressPreview(address),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () => _openAddressPicker(context),
            ),
            const SizedBox(height: 12),
            ShippingCard(
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
                  fontFamily: AppFonts.secondary,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  fontFeatures: [FontFeature.tabularFigures()],
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
      builder: (_) => AddressPickerSheet(
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
      builder: (_) => CourierPickerSheet(
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
