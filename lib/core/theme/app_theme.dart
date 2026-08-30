// core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class CupertinoStylePageTransitionsBuilder extends PageTransitionsBuilder {
  const CupertinoStylePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedIn = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final curvedOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeOutCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(curvedIn),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.2, 0),
        ).animate(curvedOut),
        child: child,
      ),
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(AppColors.light, Brightness.light);
  static ThemeData get darkTheme => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColorScheme c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: 'Geist',

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: c.border,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 0),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoStylePageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoStylePageTransitionsBuilder(),
        },
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: isDark ? Colors.transparent : AppColors.primaryLight,
          side: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: c.textHint, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: c.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Geist',
          color: c.textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Geist',
          color: c.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Geist',
          color: c.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Geist',
          color: c.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          letterSpacing: -0.1,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Geist',
          color: c.textSecondary,
          fontSize: 11.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Geist',
          color: c.textPrimary,
          fontSize: 13.5,
          height: 1.45,
          letterSpacing: -0.1,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Geist',
          color: c.textSecondary,
          fontSize: 12,
          height: 1.35,
          letterSpacing: -0.1,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Geist',
          color: c.textHint,
          fontSize: 10.5,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'Geist',
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
        ),
      ),
    );
  }
}
