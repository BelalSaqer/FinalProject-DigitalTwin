import 'package:flutter/material.dart';

extension ColorAlphaFix on Color {
  Color alphaF(double alpha) {
    final a = (alpha.clamp(0.0, 1.0) * 255).round();
    return Color.fromARGB(a, red, green, blue);
  }
}

class DT {
  static const bg = Color(0xFF020617);
  static const headerA = Color(0xFF0B1220);
  static const headerB = Color(0xFF0F172A);

  static const blue = Color(0xFF3B82F6);
  static const cyan = Color(0xFF22D3EE);

  static const green = Color(0xFF4ADE80);
  static const yellow = Color(0xFFFACC15);
  static const red = Color(0xFFF87171);
  static const purple = Color(0xFFA78BFA);
  static const pink = Color(0xFFF472B6);

  static Color surface([double opacity = 0.50]) =>
      const Color(0xFF0F172A).alphaF(opacity);

  static Color border([double opacity = 0.80]) =>
      const Color(0xFF1F2937).alphaF(opacity);

  static Color muted([double opacity = 0.65]) => Colors.white.alphaF(opacity);
  static Color dim([double opacity = 0.45]) => Colors.white.alphaF(opacity);

  static const grad = LinearGradient(
    colors: [blue, cyan],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}