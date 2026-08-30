import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);

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

  @override
  void initState() {
    super.initState();
    MainNavigationContainer.tabNotifier.addListener(_onExternalTabChange);
  }

  @override
  void dispose() {
    MainNavigationContainer.tabNotifier.removeListener(_onExternalTabChange);
    super.dispose();
  }

  void _onExternalTabChange() {
    final index = MainNavigationContainer.tabNotifier.value;
    if (index == _currentIndex || index < 0 || index >= _pages.length) return;
    _onNavTap(index);
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
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
    final theme = Theme.of(context);
    final isDark = context.isDark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
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
                    _buildNavItem(0, FontAwesomeIcons.house, 'Beranda'),
                    BlocBuilder<WishlistBloc, WishlistState>(
                      buildWhen: (previous, current) =>
                          (previous is WishlistLoaded &&
                           current is WishlistLoaded &&
                           previous.productIds.length !=
                               current.productIds.length) ||
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
                    _buildNavItem(2, FontAwesomeIcons.receipt, 'Pesanan'),
                    _buildNavItem(3, FontAwesomeIcons.user, 'Profil'),
                  ],
                ),
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
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: badgeCount),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Container(
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.sale,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            value > 99 ? '99+' : '$value',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
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
                            fontSize: 11.5,
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