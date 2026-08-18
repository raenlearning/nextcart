import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';

class CheckoutBar extends StatelessWidget {
  final double total;
  final AppColorScheme colors;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutBar({
    super.key,
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
