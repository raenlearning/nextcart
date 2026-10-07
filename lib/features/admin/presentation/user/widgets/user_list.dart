import 'package:flutter/material.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'user_item.dart';

typedef OnToggleBlock = void Function(Map<String, dynamic> user);
typedef OnDelete = void Function(Map<String, dynamic> user);

class UserList extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final OnToggleBlock onToggleBlock;
  final OnDelete? onDelete;

  const UserList({
    super.key,
    required this.users,
    required this.onToggleBlock,
    this.onDelete,
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
                  fontSize: 12,
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
              return UserItem(
                user: user,
                onToggleBlock: onToggleBlock,
                onDelete: onDelete,
                avatarSeed: index,
              );
            },
          ),
        ),
      ],
    );
  }
}
