import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

typedef OnRoleSelect = void Function(String userId, String newRole);

const _kAvatarPalette = [
  (bg: Color(0xFFFCE4E9), fg: Color(0xFFB6607A)),
  (bg: Color(0xFFE1EEFF), fg: Color(0xFF4E7BC7)),
  (bg: Color(0xFFE8F7EE), fg: Color(0xFF3E9A67)),
  (bg: Color(0xFFFFF3D6), fg: Color(0xFFB8862F)),
];

class UserItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final String role;
  final bool isPending;
  final OnRoleSelect onRoleSelect;
  final double columnWidth;
  final int avatarSeed;

  const UserItem({
    super.key,
    required this.user,
    required this.role,
    required this.onRoleSelect,
    this.isPending = false,
    this.columnWidth = 56,
    this.avatarSeed = 0,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final userId = user['id'] as String;
    final name = (user['full_name'] as String?) ?? 'User Baru';
    final email = (user['email'] as String?) ?? '-';
    final avatarUrl = user['avatar_url'] as String?;
    final style = _kAvatarPalette[avatarSeed % _kAvatarPalette.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending ? AppColors.warning : colors.border,
          width: isPending ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(isPending ? 14 : 6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.bg,
              image: avatarUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: avatarUrl == null
                ? Text(
                    _initials(name),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: style.fg,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Belum disimpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _RoleToggle(role: role, onSelect: (r) => onRoleSelect(userId, r)),
        ],
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  final String role;
  final ValueChanged<String> onSelect;

  const _RoleToggle({required this.role, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Admin',
            selected: role == 'admin',
            onTap: () => onSelect('admin'),
          ),
          _ToggleChip(
            label: 'Pembeli',
            selected: role == 'buyer',
            onTap: () => onSelect('buyer'),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}