import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';

class PromoSection extends StatelessWidget {
  final TextEditingController controller;
  final AppColorScheme colors;

  const PromoSection({super.key, required this.controller, required this.colors});

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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
