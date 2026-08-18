import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

enum AuthMode { login, register }

class AuthModeToggle extends StatelessWidget {
  final AuthMode currentMode;
  final ValueChanged<AuthMode> onSwitch;

  const AuthModeToggle({
    super.key,
    required this.currentMode,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final isLogin = currentMode == AuthMode.login;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.colors.inputFill,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Masuk',
              active: isLogin,
              onTap: () => onSwitch(AuthMode.login),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Daftar',
              active: !isLogin,
              onTap: () => onSwitch(AuthMode.register),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(70),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: active ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}