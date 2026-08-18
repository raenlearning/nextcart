import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'user_item.dart';

typedef OnRoleSelect = void Function(String userId, String newRole);

class UserList extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final Map<String, String> pendingChanges;
  final OnRoleSelect onRoleSelect;
  final double columnWidth;

  const UserList({
    super.key,
    required this.users,
    required this.onRoleSelect,
    this.pendingChanges = const {},
    this.columnWidth = 56,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              Text(
                '${users.length} pengguna',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSpacing.bottomNavSpace),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user['id'] as String;
              final originalRole = user['role'] ?? 'buyer';
              final effectiveRole = pendingChanges[userId] ?? originalRole;

              return UserItem(
                user: user,
                role: effectiveRole,
                isPending: pendingChanges.containsKey(userId),
                onRoleSelect: onRoleSelect,
                columnWidth: columnWidth,
                avatarSeed: index,
              );
            },
          ),
        ),
      ],
    );
  }
}