import 'package:flutter/material.dart';

/// Colour tokens mirrored from the web app's design system
/// (see `DESIGN.md` and `frontend/src/app/globals.css`).
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF533AFD);
  static const Color primaryDeep = Color(0xFF4434D4);
  static const Color primaryPress = Color(0xFF2E2B8C);
  static const Color primarySoft = Color(0xFF665EFD);
  static const Color primarySubtle = Color(0xFFECECFE);

  // Ink / text
  static const Color ink = Color(0xFF0D253D);
  static const Color body = Color(0xFF3C4B61);
  static const Color muted = Color(0xFF64748D);
  static const Color mutedSoft = Color(0xFF8A96A9);

  // Surfaces (light)
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasSoft = Color(0xFFF6F9FC);
  static const Color canvasCream = Color(0xFFF5E9D4);
  static const Color hairline = Color(0xFFE3E8EE);
  static const Color hairlineSoft = Color(0xFFEEF2F7);

  // Surfaces (dark)
  static const Color darkCanvas = Color(0xFF0D1B2A);
  static const Color darkSurface = Color(0xFF1C1E54);
  static const Color darkSurfaceElevated = Color(0xFF262A63);
  static const Color darkHairline = Color(0xFF2C3550);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkSoft = Color(0xFFA6B0CF);

  // Accents used for course covers and chips
  static const Color mint = Color(0xFF6EA8FF);
  static const Color peach = Color(0xFFF6B98F);
  static const Color lavender = Color(0xFFC9B8F0);
  static const Color sky = Color(0xFF665EFD);
  static const Color rose = Color(0xFFF96BEE);
  static const Color ruby = Color(0xFFEA2261);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFEA2261);
  static const Color info = Color(0xFF2563EB);

  /// Gradient pairs used for course / module cover art.
  static const Map<String, List<Color>> covers = <String, List<Color>>{
    'mint': <Color>[Color(0xFF6EA8FF), Color(0xFF9BE7D8)],
    'peach': <Color>[Color(0xFFF6B98F), Color(0xFFF9A8C4)],
    'lavender': <Color>[Color(0xFFC9B8F0), Color(0xFF8E7BE8)],
    'sky': <Color>[Color(0xFF665EFD), Color(0xFF6EA8FF)],
    'rose': <Color>[Color(0xFFF96BEE), Color(0xFFEA2261)],
  };


  /// Blends [accent] into [surface] by [t] (0..1).
  ///
  /// Used instead of `Color.withOpacity` / `Color.withValues`, both of which
  /// have changed across Flutter releases. `Color.lerp` has been stable since
  /// Flutter 1.0.
  static Color tint(Color surface, Color accent, double t) =>
      Color.lerp(surface, accent, t) ?? accent;

  /// A soft background for [accent] appropriate to the current brightness.
  static Color softBg(Color accent, {required bool dark}) => tint(
        dark ? darkSurface : canvas,
        accent,
        dark ? 0.24 : 0.12,
      );

  /// A subtle border for [accent] appropriate to the current brightness.
  static Color softBorder(Color accent, {required bool dark}) => tint(
        dark ? darkSurface : canvas,
        accent,
        dark ? 0.42 : 0.28,
      );

  static List<Color> coverFor(String? key) {
    if (key != null && covers.containsKey(key)) {
      return covers[key]!;
    }
    final List<List<Color>> values = covers.values.toList();
    final int index = (key?.hashCode ?? 0).abs() % values.length;
    return values[index];
  }
}
