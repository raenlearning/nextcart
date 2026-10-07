import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

typedef OnToggleBlock = void Function(Map<String, dynamic> user);
typedef OnDelete = void Function(Map<String, dynamic> user);

const _kAvatarPalette = [
  (bg: Color(0xFFFCE4E9), fg: Color(0xFFB6607A)),
  (bg: Color(0xFFE1EEFF), fg: Color(0xFF4E7BC7)),
  (bg: Color(0xFFE8F7EE), fg: Color(0xFF3E9A67)),
  (bg: Color(0xFFFFF3D6), fg: Color(0xFFB8862F)),
];

class UserItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final OnToggleBlock onToggleBlock;
  final OnDelete? onDelete;
  final int avatarSeed;

  const UserItem({
    super.key,
    required this.user,
    required this.onToggleBlock,
    this.onDelete,
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
    final name = (user['full_name'] as String?) ?? 'User Baru';
    final email = (user['email'] as String?) ?? '-';
    final avatarUrl = user['avatar_url'] as String?;
    final role = (user['role'] ?? 'buyer').toString();
    final isBlocked = (user['is_blocked'] as bool?) ?? false;
    final style = _kAvatarPalette[avatarSeed % _kAvatarPalette.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBlocked ? AppColors.error.withValues(alpha: 0.4) : colors.border,
          width: isBlocked ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(6),
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
                      fontSize: 13,
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
                          fontSize: 13,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    if (role == 'admin') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (isBlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Diblokir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
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
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => onToggleBlock(user),
            tooltip: isBlocked ? 'Buka blokir' : 'Blokir',
            icon: Icon(
              isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
              size: 20,
              color: isBlocked ? AppColors.success : AppColors.error,
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: () => onDelete!(user),
              tooltip: 'Hapus pengguna',
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}
