import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class OrderEmptyState extends StatelessWidget {
  final String message;
  final AppColorScheme colors;

  const OrderEmptyState({
    super.key,
    required this.message,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppAssets.emptyOrders,
            width: 200,
            height: 180,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}