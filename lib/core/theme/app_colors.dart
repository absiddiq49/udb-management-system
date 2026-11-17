import 'package:flutter/material.dart';

class AppColors {
  // ========================================================
  // MODERN WEB DESIGN SYSTEM (Clean Slate, Indigo & Neutrals)
  // Completely removed dark navy blue!
  // ========================================================

  // Primary Brand Colors (Modern Tech-Forward Royal Indigo)
  static const Color primary = Color(0xFF2563EB);        // Modern Royal Blue (Tailwind Blue 600)
  static const Color primaryHover = Color(0xFF1D4ED8);   // Blue 700
  static const Color primaryLight = Color(0xFFEFF6FF);   // Blue 50 (Soft pill background)
  static const Color primaryBorder = Color(0xFFBFDBFE);  // Blue 200

  // Modern Neutral Slate Hierarchy (No harsh blacks, no gloomy navy)
  static const Color slate950 = Color(0xFF0F172A);       // Deep Slate
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);       // Primary dark text / high-emphasis
  static const Color slate700 = Color(0xFF334155);       // Medium-high contrast
  static const Color slate600 = Color(0xFF475569);       // Secondary body text
  static const Color slate500 = Color(0xFF64748B);       // Muted captions / icons
  static const Color slate400 = Color(0xFF94A3B8);       // Placeholders & hints
  static const Color slate300 = Color(0xFFCBD5E1);       // Subtle dividers
  static const Color slate200 = Color(0xFFE2E8F0);       // Standard card borders
  static const Color slate100 = Color(0xFFF1F5F9);       // Wells / input backgrounds / hover
  static const Color slate50 = Color(0xFFF8FAFC);        // Page background
  static const Color white = Color(0xFFFFFFFF);

  // Modern Warm Amber / Gazette Gold
  static const Color gold = Color(0xFFD97706);           // Warm Amber 600
  static const Color goldLight = Color(0xFFFFFBEB);      // Amber 50
  static const Color goldBorder = Color(0xFFFDE68A);     // Amber 200
  static const Color goldDark = Color(0xFF92400E);       // Amber 800
  static const Color goldBright = Color(0xFFF59E0B);

  // Modern Soft Semantic Accents
  static const Color red = Color(0xFFE11D48);            // Modern Rose 600
  static const Color redLight = Color(0xFFFFF1F2);       // Rose 50
  static const Color redBorder = Color(0xFFFECDD3);      // Rose 200
  static const Color redDark = Color(0xFF9F1239);

  static const Color green = Color(0xFF059669);          // Modern Emerald 600
  static const Color greenLight = Color(0xFFECFDF5);     // Emerald 50
  static const Color greenBorder = Color(0xFFA7F3D0);    // Emerald 200
  static const Color greenDark = Color(0xFF065F46);

  static const Color blue = Color(0xFF2563EB);           // Blue 600
  static const Color blueLight = Color(0xFFEFF6FF);      // Blue 50
  static const Color blueBorder = Color(0xFFBFDBFE);

  static const Color cyan = Color(0xFF0D9488);           // Modern Teal 600
  static const Color cyanLight = Color(0xFFF0FDFA);      // Teal 50
  static const Color cyanBorder = Color(0xFF99F6E4);

  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFFFBEB);

  static const Color purple = Color(0xFF7C3AED);         // Modern Violet 600
  static const Color purpleLight = Color(0xFFF5F3FF);    // Violet 50
  static const Color purpleBorder = Color(0xFFDDD6FE);

  // --- LIGHT THEME (PRIMARY DEFAULT) ---
  static const Color lightBg = Color(0xFFF8FAFC);           // Slate 50 (Clean, breathable)
  static const Color lightSurface = Color(0xFFFFFFFF);      // Pure White Card
  static const Color lightCardBg = Color(0xFFFFFFFF);       // Pure White Card
  static const Color lightInputBg = Color(0xFFFFFFFF);      // White input with slate border
  static const Color lightBorder = Color(0xFFE2E8F0);       // Slate 200
  static const Color lightBorderStrong = Color(0xFFCBD5E1); // Slate 300
  static const Color lightTextPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8);     // Slate 400
  static const Color lightDivider = Color(0xFFE2E8F0);

  // --- DARK THEME (Sleek Charcoal / Slate, NOT navy) ---
  static const Color darkBg = Color(0xFF090D16);            // Deep Neutral Charcoal
  static const Color darkSurface = Color(0xFF131A29);       // Slate 900 Surface
  static const Color darkCardBg = Color(0xFF131A29);        // Slate 900 Surface
  static const Color darkInputBg = Color(0xFF1B2438);       // Slate 800 Input
  static const Color darkBorder = Color(0xFF243048);        // Slate 700 Border
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF243048);

  // Backward-compatibility aliases (mapped to modern non-navy tones)
  static const Color navyDarkest = Color(0xFF0F172A);       // Deep Slate (replaces harsh navy)
  static const Color navyDark = Color(0xFF1E293B);          // Slate 800
  static const Color navyMedium = Color(0xFFF1F5F9);        // Soft Slate 100 well
  static const Color navySurface = Color(0xFFE2E8F0);       // Slate 200
  static const Color navyBorder = Color(0xFFE2E8F0);        // Subtle Border
  static const Color navyHighlight = Color(0xFF2563EB);     // Modern Blue

  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color cardBg = lightCardBg;
  static const Color inputBg = lightInputBg;
  static const Color divider = lightDivider;
}
