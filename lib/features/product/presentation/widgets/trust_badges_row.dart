import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class TrustBadgesRow extends StatelessWidget {
  const TrustBadgesRow({super.key});

  static const List<_TrustBadge> _badges = [
    _TrustBadge(
      icon: Icons.local_shipping_outlined,
      label: 'Gratis Ongkir',
    ),
    _TrustBadge(
      icon: Icons.verified_outlined,
      label: '100% Original',
    ),
    _TrustBadge(
      icon: Icons.shield_outlined,
      label: 'Garansi Resmi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final badge in _badges) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    badge.icon,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    badge.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (badge != _badges.last)
                Container(
                  width: 1,
                  height: 16,
                  color: colors.divider,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrustBadge {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});
}