import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/theme/theme_cubit.dart';
import 'package:nextcart/core/widgets/bento_tile.dart';
import 'package:nextcart/core/widgets/shimmer_box.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  final ValueChanged<int>? onTabChange;

  const ProfilePage({super.key, this.onTabChange});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  int _activeOrdersCount = 0;
  int _addressCount = 0;
  int _wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchSummaryCounts();
  }

  Future<void> refresh() async {
    await Future.wait([_fetchProfile(), _fetchSummaryCounts()]);
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await _supabase
          .from('profiles')
          .select('full_name, email, avatar_url')
          .eq('id', userId)
          .single();
      if (!mounted) return;
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSummaryCounts() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final results = await Future.wait([
        _supabase
            .from('orders')
            .select('id')
            .inFilter('status', ['waiting_payment', 'processing'])
            .eq('user_id', userId)
            .count(CountOption.exact),
        _supabase
            .from('shipping_addresses')
            .select('id')
            .eq('user_id', userId)
            .count(CountOption.exact),
        _supabase
            .from('wishlist_items')
            .select('id')
            .eq('user_id', userId)
            .count(CountOption.exact),
      ]);

      if (!mounted) return;
      setState(() {
        _activeOrdersCount = results[0].count;
        _addressCount = results[1].count;
        _wishlistCount = results[2].count;
      });
    } catch (_) {
      // Abaikan error count, biarkan tampil 0.
    }
  }

  Future<void> _confirmLogout() async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Log Out?', style: TextStyle(color: colors.textPrimary)),
        content: Text(
          'Kamu akan keluar dari akun kamu dan perlu login kembali.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _supabase.auth.signOut();
      if (mounted) context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = _profile?['full_name'] as String? ?? 'Pengguna';
    final email = _profile?['email'] as String? ?? '';
    final avatarUrl = _profile?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: colors.background,
      body: _isLoading
          ? const _ProfileShimmerSkeleton()
          : SafeArea(
              top: true,
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  AppSpacing.bottomNavSpace,
                ),
                children: [
                  Text(
                    'Akun',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header profil
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colors.inputFill,
                        backgroundImage: avatarUrl != null
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                        child: avatarUrl == null
                            ? Icon(
                                Icons.person,
                                color: colors.textSecondary,
                                size: 28,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Kartu ringkasan
                  _buildSummaryCards(colors),
                  const _ThemeToggleItem(),
                  _buildSectionTitle(colors, 'Pengaturan Akun'),
                  const SizedBox(height: 10),
                  _buildCard(colors, [
                    _MenuItem(
                      icon: Icons.person_outline,
                      label: 'Profil',
                      onTap: () async {
                        final isUpdated = await context.push<bool>(
                          '/profile-detail',
                          extra: _profile,
                        );

                        if (isUpdated == true) {
                          _fetchProfile();
                        }
                      },
                    ),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      label: 'Alamat Pengiriman',
                      onTap: () => context.push('/address-list'),
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      label: 'Ganti Kata Sandi',
                      onTap: () => context.push('/change-password'),
                    ),
                    _MenuItem(
                      icon: Icons.storefront_outlined,
                      label: 'Profil Toko',
                      onTap: () => context.push('/store-profile'),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Kebijakan Privasi',
                      onTap: () => context.push('/privacy-policy'),
                    ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: 'Pusat Bantuan',
                      onTap: () => context.push('/help-center'),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      label: 'Tentang Aplikasi',
                      onTap: () => context.push('/about-app'),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  _buildSectionTitle(colors, 'Notifikasi'),
                  const SizedBox(height: 10),
                  _buildCard(colors, [
                    _MenuItem(
                      icon: Icons.local_shipping_outlined,
                      label: 'Pembaruan Pesanan',
                      onTap: () => context.push('/notifications'),
                    ),
                  ]),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(AppColorScheme colors) {
    final items = [
      _SummaryItem(
        icon: Icons.local_shipping_outlined,
        label: 'Pesanan Aktif',
        count: _activeOrdersCount,
        color: AppColors.primary,
        onTap: () => widget.onTabChange?.call(2),
      ),
      _SummaryItem(
        icon: Icons.favorite_outline,
        label: 'Wishlist',
        count: _wishlistCount,
        color: AppColors.sale,
        onTap: () => widget.onTabChange?.call(1),
      ),
      _SummaryItem(
        icon: Icons.location_on_outlined,
        label: 'Alamat',
        count: _addressCount,
        color: AppColors.info,
        onTap: () => context.push('/address-list'),
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: items[i]),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(AppColorScheme colors, String title) {
    return Text(
      title,
      style: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildCard(AppColorScheme colors, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final isLast = i == items.length - 1;
          return Column(
            children: [
              items[i],
              if (!isLast)
                Divider(
                  height: 1,
                  color: colors.divider,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BentoTile(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: 20,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 10.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: colors.textHint),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggleItem extends StatelessWidget {
  const _ThemeToggleItem();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () => context.read<ThemeCubit>().toggle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.dark_mode_outlined,
              size: 20,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Mode Gelap',
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
              ),
            ),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                final isDark = mode == ThemeMode.dark;
                return Switch(
                  value: isDark,
                  onChanged: (_) => context.read<ThemeCubit>().toggle(),
                  activeThumbColor: AppColors.primary,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileShimmerSkeleton extends StatelessWidget {
  const _ProfileShimmerSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: true,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          AppSpacing.bottomNavSpace,
        ),
        children: [
          const ShimmerBox(width: 80, height: 20, radius: 6),
          const SizedBox(height: 20),
          Row(
            children: [
              const ShimmerBox(width: 56, height: 56, radius: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 140, height: 15, radius: 6),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 180, height: 12, radius: 5),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const ShimmerBox(width: 36, height: 36, radius: 18),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: 40, height: 14, radius: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const ShimmerBox(width: 20, height: 20, radius: 10),
                  const SizedBox(width: 14),
                  ShimmerBox(
                    width: 120 + (index * 20).toDouble(),
                    height: 14,
                    radius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
