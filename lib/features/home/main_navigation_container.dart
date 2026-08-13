import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

   late final List<Widget> _pages = [
    const HomePage(),
    WishlistPage(key: _wishlistKey),
    OrderScreen(key: _orderKey),
    const ProfilePage(), 
  ];


  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      _wishlistKey.currentState?.refresh();
    }

    if (index == 2) {
      _orderKey.currentState?.refresh(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colors.divider.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDark ? 0.3 : 0.06,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, FontAwesomeIcons.house, 'Beranda'),
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
                        FontAwesomeIcons.heart,
                        'Wishlist',
                        badgeCount: count,
                      );
                    },
                  ),
                  _buildNavItem(2, FontAwesomeIcons.cartPlus, 'Pesanan'),
                  _buildNavItem(3, FontAwesomeIcons.person, 'Profil'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    FaIconData icon,
    String label, {
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                FaIcon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
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
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: isSelected
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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
