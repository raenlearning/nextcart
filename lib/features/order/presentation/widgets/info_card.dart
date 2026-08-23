import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/theme/app_fonts.dart';

class InfoRow {
  final String label;
  final String value;
  InfoRow(this.label, this.value);
}

class InfoCard extends StatelessWidget {
  final List<InfoRow> rows;
  final AppColorScheme colors;
  final Widget? footer;

  const InfoCard({
    super.key,
    required this.rows,
    required this.colors,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                  Flexible(
                    child: Text(
                      row.value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: AppFonts.secondary,
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footer != null) ...[
            Divider(height: 20, color: colors.divider),
            footer!,
          ],
        ],
      ),
    );
  }
}
