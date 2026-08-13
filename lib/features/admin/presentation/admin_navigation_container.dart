import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextcart/features/admin/presentation/dashboard/admin_dashboard_page.dart';
import 'package:nextcart/features/admin/presentation/order/admin_order_page.dart';
import 'package:nextcart/features/admin/presentation/product/admin_product_management.dart';
import 'package:nextcart/features/admin/presentation/review/admin_review_management.dart';
import 'package:nextcart/features/admin/presentation/user/admin_user_management.dart';
import '../../../core/theme/app_colors.dart';


class AdminNavigationContainer extends StatefulWidget {
  const AdminNavigationContainer({super.key});

  @override
  State<AdminNavigationContainer> createState() => _AdminNavigationContainerState();
}

class _AdminNavigationContainerState extends State<AdminNavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _adminPages = [
    const AdminAnalyticsDashboardPage(), 
    const AdminProductManagementPage(),  
    const AdminOrderPage(),    
    const AdminUserManagementPage(),     
    const AdminReviewManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: context.colors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _adminPages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark 
                      ? theme.colorScheme.surface.withValues(alpha: 0.85) 
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.08) 
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAdminNavItem(0, FontAwesomeIcons.chartPie, 'Dashboard'),
                    _buildAdminNavItem(1, FontAwesomeIcons.boxOpen, 'Produk'),
                    _buildAdminNavItem(2, FontAwesomeIcons.receipt, 'Pesanan'),
                    _buildAdminNavItem(3, FontAwesomeIcons.usersGear, 'Pengguna'),
                    _buildAdminNavItem(4, FontAwesomeIcons.star, 'Ulasan'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminNavItem(int index, FaIconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: isSelected
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}