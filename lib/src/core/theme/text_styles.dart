import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AuroraTextStyles {
  const AuroraTextStyles._();

  static TextTheme textTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.dark
        ? AuroraColors.cloud
        : Colors.black87;

    return GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: baseColor,
      displayColor: baseColor,
    );
  }

  static const TextStyle hero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
