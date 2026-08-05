// core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand 
  static const Color primary      = Color(0xFF0A84FF);
  static const Color primaryLight = Color(0xFFEAF4FF);
  static const Color primaryDark  = Color(0xFF0066CC);
  static const Color secondary    = Color(0xFF10B981);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF0EA5E9);

  // Accent
  static const Color price        = Color(0xFF16A34A);
  static const Color sale         = Color(0xFFDC2626);
  static const Color promo        = Color(0xFFF97316);
  static const Color rating       = Color(0xFFFACC15);
  static const Color favorite     = Color(0xFFF43F5E);
  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color cyan         = Color(0xFF06B6D4);
  static const Color neonLime     = Color(0xFFE4FF33);

  // Slate scale
  static const Color slate50  = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  static const AppColorScheme light = AppColorScheme(
    background        : Color(0xFFF8FAFC),  
    surface           : Color(0xFFF8FAFC),   
    card              : Color(0xFFFFFFFF),   
    inputFill         : Color(0xFFF1F5F9),  
    border            : Color(0xFFE2E8F0),   
    divider           : Color(0xFFE2E8F0),   
    textPrimary       : Color(0xFF0F172A), 
    textSecondary     : Color(0xFF64748B), 
    textHint          : Color(0xFF94A3B8), 
    textOnPrimary     : Color(0xFFFFFFFF),
    iconFill          : Color(0xFFE2E8F0),
    shimmerBase       : Color(0xFFE2E8F0),
    shimmerHighlight  : Color(0xFFF8FAFC),
  );

  static const AppColorScheme dark = AppColorScheme(
    background        : Color(0xFF0F172A),   
    surface           : Color(0xFF1E293B),   
    card              : Color(0xFF1E293B),
    inputFill         : Color(0xFF334155),   
    border            : Color(0xFF334155),
    divider           : Color(0xFF1E293B),
    textPrimary       : Color(0xFFF8FAFC),  
    textSecondary     : Color(0xFF94A3B8),  
    textHint          : Color(0xFF64748B),  
    textOnPrimary     : Color(0xFFFFFFFF),
    iconFill          : Color(0xFF334155),
    shimmerBase       : Color(0xFF334155),
    shimmerHighlight  : Color(0xFF475569),
  );
}

@immutable
class AppColorScheme {
  final Color background;
  final Color surface;
  final Color card;
  final Color inputFill;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textOnPrimary;
  final Color iconFill;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.card,
    required this.inputFill,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textOnPrimary,
    required this.iconFill,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });
}

extension AppColorsX on BuildContext {
  AppColorScheme get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}