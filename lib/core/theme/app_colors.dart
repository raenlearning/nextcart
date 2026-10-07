// core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(
    0xFF10B981,
  ); 

  static const Color primaryLight = Color(0xFFEFF4FF);
  static const Color primaryDark = Color(0xFF1D4ED8);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = primary;
  static const Color neonLime = success;

  static const Color price = success; 
  static const Color sale = error; 
  static const Color rating = Color(0xFFEAB308); 
  static const Color promo = warning;
  static const Color electricBlue = primary;
  static const Color favorite = error;

  static const Color splashBackground = Color(0xFF0A1D49);
  static const Color splashCream = Color(0xFFF5F0E1);
  static const Color splashAccent = Color(0xFF22D3EE);

  static const Color navBarLight = Color(0xFFE0F7FA);
  static const Color navBarDark = Color(0xFF1E293B);
  static const Color navBarBorderLight = Color(0xFFB2EBF2);
  static const Color navBarBorderDark = Color(0xFF334155);

  static const Color authGradientDark = Color(0xFF16233F);

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  static const AppColorScheme light = AppColorScheme(
    background: slate50,
    surface: slate50,
    card: Color(0xFFFFFFFF),
    inputFill: slate100,
    border: slate200,
    divider: slate200,
    textPrimary: slate900,
    textSecondary: slate500,
    textHint: slate400,
    textOnPrimary: Color(0xFFFFFFFF),
    iconFill: slate200,
    shimmerBase: slate200,
    shimmerHighlight: slate50,
  );

  static const AppColorScheme dark = AppColorScheme(
    background: slate900,
    surface: slate800,
    card: slate800,
    inputFill: slate600,
    border: slate600,
    divider: slate800,
    textPrimary: slate50,
    textSecondary: slate400,
    textHint: slate500,
    textOnPrimary: Color(0xFFFFFFFF),
    iconFill: slate600,
    shimmerBase: slate600,
    shimmerHighlight: Color(0xFF52607A),
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
