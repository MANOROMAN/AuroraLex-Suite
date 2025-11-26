import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_colors.dart';
import 'app_gradients.dart';
import 'text_styles.dart';

final appThemeProvider = Provider<_AuroraTheme>((_) => _AuroraTheme());

class _AuroraTheme {
  ThemeData get light => _baseTheme(brightness: Brightness.light);

  ThemeData get dark => _baseTheme(brightness: Brightness.dark);

  ThemeData _baseTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: const Color(0xFF1173d4),
      primary: const Color(0xFF1173d4),
      secondary: const Color(0xFF59FFD5),
      surface: isDark ? const Color(0xFF1a2633) : Colors.white,
      background: isDark ? const Color(0xFF101922) : Colors.white,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF101922)
          : const Color(0xFFF9FAFF),
      useMaterial3: true,
      textTheme: AuroraTextStyles.textTheme(brightness),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1a2633) : Colors.white,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1a2633) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: const Color(0xFF1173d4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF101922) : Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AuroraTextStyles.textTheme(brightness).titleMedium,
      ),
      extensions: [
        const _AuroraGradientsTheme(background: AuroraGradients.aurora),
      ],
    );
  }
}

class AuroraTheme extends ThemeExtension<AuroraTheme> {
  const AuroraTheme({required this.background});

  final LinearGradient background;

  @override
  ThemeExtension<AuroraTheme> copyWith({LinearGradient? background}) {
    return AuroraTheme(background: background ?? this.background);
  }

  @override
  ThemeExtension<AuroraTheme> lerp(
    covariant ThemeExtension<AuroraTheme>? other,
    double t,
  ) {
    if (other is! AuroraTheme) return this;
    return AuroraTheme(
      background: LinearGradient.lerp(background, other.background, t)!,
    );
  }
}

class _AuroraGradientsTheme extends ThemeExtension<_AuroraGradientsTheme> {
  const _AuroraGradientsTheme({required this.background});

  final LinearGradient background;

  @override
  ThemeExtension<_AuroraGradientsTheme> copyWith({
    LinearGradient? background,
  }) => _AuroraGradientsTheme(background: background ?? this.background);

  @override
  ThemeExtension<_AuroraGradientsTheme> lerp(
    covariant ThemeExtension<_AuroraGradientsTheme>? other,
    double t,
  ) {
    if (other is! _AuroraGradientsTheme) return this;
    return _AuroraGradientsTheme(
      background: LinearGradient.lerp(background, other.background, t)!,
    );
  }
}
