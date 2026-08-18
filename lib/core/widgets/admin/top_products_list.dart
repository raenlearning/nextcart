import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class TopProductsList extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const TopProductsList({super.key, required this.products});

  @override
  State<TopProductsList> createState() => _TopProductsListState();
}

class _TopProductsListState extends State<TopProductsList> {
  static const _tabs = ['Produk Terjual'];
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final products = widget.products;

    final qtys = products.map((p) => p['qty_sold'] as int).toList();
    final avgQty = qtys.isEmpty
        ? 0
        : qtys.reduce((a, b) => a + b) / qtys.length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 24,
                color: AppColors.neonLime,
              ),
              const SizedBox(width: 10),
              Text(
                'Rating Produk',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: colors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_tabs.length, (i) {
              final isActive = i == _activeTab;
              return Padding(
                padding: const EdgeInsets.only(right: 18),
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = i),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _tabs[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isActive
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                      if (i == 0) ...[
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 13,
                          color: isActive
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 6),

          if (products.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada data penjualan.',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            )
          else
            ...products.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final product = entry.value;
              final imageUrl = product['image'] as String?;
              final name = product['name'] as String;
              final qty = product['qty_sold'] as int;

              final pct = avgQty == 0 ? 0.0 : ((qty - avgQty) / avgQty) * 100;
              final isUp = pct >= 0;
              final trendColor = isUp ? AppColors.success : AppColors.error;
              final rankColor =
                  rank <= 3 ? AppColors.primary : colors.textHint;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? AppColors.primary.withAlpha(22)
                            : colors.inputFill,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: rankColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colors.inputFill,
                        border: Border.all(color: colors.border),
                        image: imageUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageUrl == null
                          ? Icon(
                              Icons.image_outlined,
                              size: 18,
                              color: colors.textHint,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$qty units sold',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: trendColor.withAlpha(18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUp
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 11,
                            color: trendColor,
                          ),
                          const SizedBox(width: 1),
                          Text(
                            '${pct.abs().toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: trendColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}