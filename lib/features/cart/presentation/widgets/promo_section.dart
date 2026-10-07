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
    return BlocSelector<CartBloc, CartState, ({Map<String, dynamic>? voucher, String? voucherError})>(
      selector: (state) => (
        voucher: state is CartLoaded ? state.voucher : null,
        voucherError: state is CartLoaded ? state.voucherError : null,
      ),
      builder: (context, data) {
        final applied = data.voucher != null && data.voucher!.isNotEmpty;
        final error = data.voucherError;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: error != null ? AppColors.error.withValues(alpha: 0.5) : colors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                            'Kupon ${data.voucher!['code']} diterapkan',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          )
                        : TextField(
                            controller: controller,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 11.5,
                            ),
                            onChanged: (_) {
                              if (error != null) {
                                context.read<CartBloc>().add(ClearVoucherError());
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Masukkan kode voucher',
                              hintStyle: TextStyle(
                                color: colors.textHint,
                                fontSize: 11.5,
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
              if (!applied && error != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
