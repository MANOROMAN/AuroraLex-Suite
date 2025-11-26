import 'package:flutter/material.dart';

class AuroraGradients {
  const AuroraGradients._();

  static const LinearGradient dusk = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F0B25), Color(0xFF150D34), Color(0xFF1F0F44)],
  );

  static const LinearGradient aurora = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1C1B37),
      Color(0xFF281F59),
      Color(0xFF331B67),
      Color(0xFF05112C),
    ],
  );

  static const LinearGradient glassSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white24, Colors.white10, Colors.white24],
    stops: [0.1, 0.5, 0.9],
  );
}
