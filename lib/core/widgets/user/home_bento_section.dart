import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/helper/whatsapp_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/bento_tile.dart';
import 'package:nextcart/core/widgets/user/promo_banner.dart';
import 'package:nextcart/features/home/main_navigation_container.dart';
import 'package:nextcart/core/constants/store_info.dart';

class HomeBentoSection extends StatefulWidget {
  const HomeBentoSection({super.key});

  @override
  State<HomeBentoSection> createState() => _HomeBentoSectionState();
}

class _HomeBentoSectionState extends State<HomeBentoSection> {
  final PageController _bannerController = PageController();
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = (_current + 1) % HomeBannerSlides.all.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildBannerTile()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildPromoTile()),
                    const SizedBox(height: 12),
                    Expanded(child: _buildBantuanTile()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: FontAwesomeIcons.ticket,
                  iconColor: AppColors.promo,
                  label: 'Voucher',
                  subtitle: 'Pakai di keranjang',
                  onTap: () => context.push('/cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: FontAwesomeIcons.store,
                  iconColor: AppColors.primary,
                  label: 'Profil Toko',
                  subtitle: StoreInfo.name,
                  onTap: () => context.push('/store-profile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: FontAwesomeIcons.receipt,
                  iconColor: AppColors.success,
                  label: 'Pesanan Saya',
                  subtitle: 'Cek status',
                  onTap: () =>
                      MainNavigationContainer.tabNotifier.value = 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerTile() {
    final slides = HomeBannerSlides.all;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: GestureDetector(
        onTap: () => context.push('/view-all'),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _bannerController,
              itemCount: slides.length,
              onPageChanged: (index) => setState(() => _current = index),
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Image.asset(
                  slide.image,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.55],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  slides[_current].badge,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 12,
              right: 60,
              child: Text(
                slides[_current].title.replaceAll('\n', ' '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(slides.length, (i) {
                  final isActive = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(left: 4),
                    width: isActive ? 14 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoTile() {
    return BentoTile(
      onTap: () => context.push('/view-all'),
      padding: const EdgeInsets.all(12),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, Color(0xFF0F766E)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.truckFast,
            color: Colors.white,
            size: 17,
          ),
          const SizedBox(height: 7),
          const Text(
            'Gratis Ongkir',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Setiap hari',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBantuanTile() {
    return BentoTile(
      onTap: () => WhatsAppHelper.openChat(
        'Halo Admin ${StoreInfo.name}, saya butuh bantuan.',
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.whatsapp,
            color: AppColors.success,
            size: 17,
          ),
          const SizedBox(height: 7),
          Text(
            'Bantuan',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Chat WhatsApp',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final FaIconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BentoTile(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, color: iconColor, size: 17),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}
