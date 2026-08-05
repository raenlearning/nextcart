import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class RoleSelectionDialog extends StatelessWidget {
  final String userId;
  final String currentRole;
  final ValueChanged<String> onRoleChanged;

  const RoleSelectionDialog({
    super.key,
    required this.userId,
    required this.currentRole,
    required this.onRoleChanged,
  });

  static const _roles = [
    (value: 'admin', label: 'Admin', desc: 'Akses sebagai admin', icon: Icons.shield_rounded),
    (value: 'buyer', label: 'Pembeli', desc: 'Akses sebagai pembeli', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubah Role Pengguna',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih peran baru untuk pengguna ini',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            ..._roles.map((r) {
              final selected = r.value == currentRole;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (r.value != currentRole) onRoleChanged(r.value);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? Colors.black : colors.inputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? Colors.black : colors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          r.icon,
                          size: 20,
                          color: selected ? Colors.white : colors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.label,
                                style: TextStyle(
                                  color: selected ? Colors.white : colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                r.desc,
                                style: TextStyle(
                                  color: selected ? Colors.white70 : colors.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
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
}