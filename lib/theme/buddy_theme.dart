import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuddyColors {
  static const deep = Color(0xFF0E2A2F);
  static const ink = Color(0xFF142F35);
  static const moss = Color(0xFF1F4A48);
  static const sage = Color(0xFF6B9E8F);
  static const mist = Color(0xFFD7E8DF);
  static const sand = Color(0xFFF3EDE2);
  static const warm = Color(0xFFC9824A);
  static const softRed = Color(0xFFB85C5C);
  static const bubbleUser = Color(0xFF214B4A);
  static const bubbleBuddy = Color(0xFFE8F2EC);

  static const night = Color(0xFF0B1618);
  static const nightPanel = Color(0xFF152428);
  static const nightMist = Color(0xFF244045);
  static const nightText = Color(0xFFE6F0EB);
  static const nightBuddyBubble = Color(0xFF1C3336);
}

class BuddyTheme {
  static TextTheme _text(Color display, Color body) {
    final base = ThemeData(brightness: Brightness.light).textTheme;
    return GoogleFonts.outfitTextTheme(base).apply(
      bodyColor: body,
      displayColor: display,
    ).copyWith(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 42,
        fontWeight: FontWeight.w600,
        color: display,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: display,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: display,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: body,
      ),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, height: 1.45, color: body),
      bodyMedium: GoogleFonts.outfit(fontSize: 15, height: 1.45, color: body),
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BuddyColors.sand,
      colorScheme: const ColorScheme.light(
        primary: BuddyColors.moss,
        onPrimary: BuddyColors.sand,
        secondary: BuddyColors.warm,
        onSecondary: Colors.white,
        surface: BuddyColors.sand,
        onSurface: BuddyColors.ink,
        error: BuddyColors.softRed,
      ),
    );

    return base.copyWith(
      textTheme: _text(BuddyColors.deep, BuddyColors.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: BuddyColors.deep,
        ),
        iconTheme: const IconThemeData(color: BuddyColors.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BuddyColors.moss,
        foregroundColor: BuddyColors.sand,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BuddyColors.sand.withValues(alpha: 0.96),
        indicatorColor: BuddyColors.mist,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.65),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BuddyColors.night,
      colorScheme: const ColorScheme.dark(
        primary: BuddyColors.sage,
        onPrimary: BuddyColors.night,
        secondary: BuddyColors.warm,
        onSecondary: Colors.white,
        surface: BuddyColors.nightPanel,
        onSurface: BuddyColors.nightText,
        error: BuddyColors.softRed,
      ),
    );

    return base.copyWith(
      textTheme: _text(BuddyColors.nightText, BuddyColors.nightText),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: BuddyColors.nightText,
        ),
        iconTheme: const IconThemeData(color: BuddyColors.nightText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BuddyColors.nightMist.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BuddyColors.sage,
        foregroundColor: BuddyColors.night,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BuddyColors.nightPanel,
        indicatorColor: BuddyColors.nightMist,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        color: BuddyColors.nightPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
