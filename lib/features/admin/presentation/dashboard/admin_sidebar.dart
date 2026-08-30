import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSidebar extends StatefulWidget {
  final String email;
  final bool isExporting;
  final VoidCallback? onExport;
  final VoidCallback onLogout;

  static final ValueNotifier<int> refreshTrigger = ValueNotifier<int>(0);

  const AdminSidebar({
    super.key,
    required this.email,
    required this.isExporting,
    required this.onExport,
    required this.onLogout,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  int _unansweredCount = 0;

  String get _initials {
    final name = widget.email.split('@').first;
    if (name.isEmpty) return 'A';
    final parts =
        name.split(RegExp(r'[._-]')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _fetchUnansweredCount();
    AdminSidebar.refreshTrigger.addListener(_fetchUnansweredCount);
  }

  @override
  void dispose() {
    AdminSidebar.refreshTrigger.removeListener(_fetchUnansweredCount);
    super.dispose();
  }

  Future<void> _fetchUnansweredCount() async {
    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .select('id')
          .isFilter('reply_text', null)
          .count(CountOption.exact);
      if (!mounted) return;
      setState(() => _unansweredCount = response.count);
    } catch (_) {
      // Badge bersifat informasi — abaikan kegagalan.
    }
  }

  void _openRoute(String route) {
    Navigator.pop(context);
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Drawer(
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFF3C6D2), Color(0xFFE8A0B4)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.divider),
            const SizedBox(height: 10),
            _SidebarItem(
              icon: Icons.star_rounded,
              color: AppColors.rating,
              label: 'Ulasan',
              badgeCount: _unansweredCount,
              badgeColor: AppColors.warning,
              onTap: () => _openRoute('/admin-reviews'),
            ),
            _SidebarItem(
              icon: Icons.category_outlined,
              color: AppColors.secondary,
              label: 'Kelola Kategori',
              onTap: () => _openRoute('/admin-categories'),
            ),
            _SidebarItem(
              icon: Icons.local_offer_outlined,
              color: AppColors.promo,
              label: 'Kelola Voucher',
              onTap: () => _openRoute('/admin-vouchers'),
            ),
            const Spacer(),
            Divider(height: 1, color: colors.divider),
            const SizedBox(height: 10),
            _SidebarItem(
              icon: widget.isExporting ? null : Icons.download_rounded,
              color: AppColors.primary,
              label: widget.isExporting ? 'Mengekspor...' : 'Ekspor Laporan',
              enabled: !widget.isExporting && widget.onExport != null,
              trailing: widget.isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
              onTap: (widget.onExport != null && !widget.isExporting)
                  ? () {
                      Navigator.pop(context);
                      widget.onExport!();
                    }
                  : null,
            ),
            _SidebarItem(
              icon: Icons.logout_rounded,
              color: AppColors.error,
              label: 'Keluar',
              onTap: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;
  final int badgeCount;
  final Color badgeColor;

  const _SidebarItem({
    required this.color,
    required this.label,
    required this.onTap,
    this.icon,
    this.enabled = true,
    this.trailing,
    this.badgeCount = 0,
    this.badgeColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = enabled ? color : colors.textHint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: effectiveColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: enabled ? colors.textPrimary : colors.textHint,
                    ),
                  ),
                ),
                if (trailing != null) ...[trailing!],
                if (badgeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
