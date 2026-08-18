import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/order_status.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class StatusFilterChips extends StatelessWidget {
  final List<String> statuses;
  final String selectedStatus;
  final Map<String, int> counts;
  final ValueChanged<String> onTap;

  const StatusFilterChips({
    super.key,
    required this.statuses,
    required this.selectedStatus,
    required this.counts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: statuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = status == selectedStatus;
          final chipColor =
              status == 'all' ? AppColors.primary : OrderStatus.color(status);
          final count = counts[status] ?? 0;

          return GestureDetector(
            onTap: () => onTap(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? chipColor : context.colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? chipColor : context.colors.border,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status != 'all') ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : chipColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    OrderStatus.label(status),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : context.colors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : context.colors.inputFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : context.colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}