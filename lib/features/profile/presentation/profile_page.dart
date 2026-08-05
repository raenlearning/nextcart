import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> refresh() => _fetchProfile();

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
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
          ? Center(
              child: Lottie.asset(
                AppAssets.loadingChart,
                width: 80,
                height: 80,
                repeat: true,
              ),
            )
          : SafeArea(
              top: true,
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
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
                            ? NetworkImage(avatarUrl)
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
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 15,
                                  color: AppColors.info,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.rating.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    size: 12,
                                    color: AppColors.rating,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Akun Premium',
                                    style: TextStyle(
                                      color: AppColors.rating,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

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
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Pengaturan Privasi',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.notifications_none,
                      label: 'Pengaturan Notifikasi',
                      onTap: () {},
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
                    _MenuItem(
                      icon: Icons.local_offer_outlined,
                      label: 'Promosi',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Pembaruan Dompet',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.storefront_outlined,
                      label: 'Pembaruan Toko',
                      onTap: () {},
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
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(AppColorScheme colors, String title) {
    return Text(
      title,
      style: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

  Widget _buildCard(AppColorScheme colors, List<_MenuItem> items) {
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
                style: TextStyle(color: colors.textPrimary, fontSize: 13.5),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: colors.textHint),
          ],
        ),
      ),
    );
  }
}
