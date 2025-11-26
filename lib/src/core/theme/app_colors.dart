import 'package:flutter/material.dart';

class AuroraColors {
  const AuroraColors._();

  static const Color midnight = Color(0xFF040312);
  static const Color midnightDarker = Color(0xFF02010B);
  static const Color iris = Color(0xFF5F5FFF);
  static const Color sapphire = Color(0xFF2431F4);
  static const Color magenta = Color(0xFFF9008C);
  static const Color aurora = Color(0xFF00FFC6);
  static const Color amber = Color(0xFFFFB347);
  static const Color cloud = Color(0xFFEEF2FF);
  static const Color slate = Color(0xFF8FA0C9);
  static const Color surface = Color(0xFF0D0C1F);
  static const Color glassStroke = Color(0x33FFFFFF);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5F5FFF), Color(0xFF9C53FF), Color(0xFFF257D5)],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00FFC6), Color(0xFF59FFD5), Color(0xFFA6FFEA)],
  );
}
