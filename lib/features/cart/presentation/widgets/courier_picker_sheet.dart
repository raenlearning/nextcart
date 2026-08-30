import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';

class CourierPickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> rates;
  final String? selectedCode;
  final void Function(Map<String, dynamic> courier) onSelected;

  const CourierPickerSheet({
    super.key,
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
                fontSize: 15,
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
                        fontSize: 12.5,
                      ),
                    ),
                    subtitle: Text(
                      'Estimasi $eta',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    trailing: Text(
                      CurrencyFormatter.rupiah(
                        (courier['price'] as num?)?.toDouble() ?? 0,
                      ),
                      style: const TextStyle(
                        fontFamily: AppFonts.secondary,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        fontFeatures: [FontFeature.tabularFigures()],
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
