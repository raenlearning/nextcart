import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/features/order/presentation/order_page.dart';
import 'package:nextcart/features/profile/presentation/profile_page.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:nextcart/features/wishlist/wishlist_page.dart';
import '../../../core/theme/app_colors.dart';
import 'home_page.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  final GlobalKey<WishlistPageState> _wishlistKey =
      GlobalKey<WishlistPageState>();

  final GlobalKey<OrderScreenState> _orderKey = GlobalKey<OrderScreenState>();

  final GlobalKey<ProfilePageState> _profileKey =
      GlobalKey<ProfilePageState>();

   late final List<Widget> _pages = [
    const HomePage(),
    WishlistPage(key: _wishlistKey),
    OrderScreen(key: _orderKey),
    ProfilePage(key: _profileKey, onTabChange: (index) => _onNavTap(index)),
  ];


  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      _wishlistKey.currentState?.refresh();
    }

    if (index == 2) {
      _orderKey.currentState?.refresh(); 
    }

    if (index == 3) {
      _profileKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFB2EBF2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.3 : 0.06,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined),
                BlocBuilder<WishlistBloc, WishlistState>(
                  buildWhen: (previous, current) =>
                      (previous is WishlistLoaded &&
                       current is WishlistLoaded &&
                       previous.productIds.length != current.productIds.length) ||
                      previous is! WishlistLoaded ||
                      current is! WishlistLoaded,
                  builder: (context, state) {
                    final count = state is WishlistLoaded
                        ? state.productIds.length
                        : 0;
                    return _buildNavItem(
                      1,
                      Icons.favorite_border_rounded,
                      badgeCount: count,
                    );
                  },
                ),
                _buildNavItem(2, Icons.receipt_rounded),
                _buildNavItem(3, Icons.person_outline_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon, {
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = context.isDark;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.75)
                      : const Color(0xFF0F172A)),
            ),
            if (badgeCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sale,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
