import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nextcart/core/constants/store_info.dart';
import 'package:nextcart/core/helper/whatsapp_helper.dart';
import 'package:nextcart/core/service/map_tile_provider.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/bento_tile.dart';

class StoreProfilePage extends StatelessWidget {
  const StoreProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Profil Toko'),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderCard(),
            const SizedBox(height: 16),
            Text(
              'Tentang Toko',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              StoreInfo.description,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _InfoTile(
              icon: FontAwesomeIcons.clock,
              title: 'Jam Buka',
              subtitle: '${StoreInfo.openHours} · ${StoreInfo.openHoursDays}',
              colors: colors,
            ),
            const SizedBox(height: 10),
            _InfoTile(
              icon: FontAwesomeIcons.locationDot,
              title: 'Alamat',
              subtitle: StoreInfo.address,
              colors: colors,
            ),
            const SizedBox(height: 10),
            _InfoTile(
              icon: FontAwesomeIcons.instagram,
              title: 'Instagram',
              subtitle: StoreInfo.instagram,
              colors: colors,
              onTap: () async {
                final uri = Uri.parse(
                  'https://instagram.com/${StoreInfo.instagram.replaceFirst('@', '')}',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 20),
            _StoreMap(colors: colors),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => WhatsAppHelper.openChat(
                  'Halo Admin ${StoreInfo.name}, saya ingin bertanya tentang produk.',
                ),
                icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 20),
                label: const Text(
                  'Hubungi via WhatsApp',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BentoTile(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              'assets/branding/nextcart_logo.svg',
               width: 50,
            height: 50,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StoreInfo.name,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  StoreInfo.tagline,
                  style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final FaIconData icon;
  final String title;
  final String subtitle;
  final AppColorScheme colors;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BentoTile(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.colors.inputFill,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                icon,
                size: 15,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right, size: 18, color: colors.textHint),
        ],
      ),
    );
  }
}

class _StoreMap extends StatelessWidget {
  final AppColorScheme colors;

  const _StoreMap({required this.colors});

  @override
  Widget build(BuildContext context) {
    final center = LatLng(StoreInfo.storeLatitude, StoreInfo.storeLongitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nextcart.app',
                  tileProvider: buildMapTileProvider(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query='
                    '${StoreInfo.storeLatitude},${StoreInfo.storeLongitude}',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Buka di Maps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
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
