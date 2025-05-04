import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static Color get primary => const Color(0xFF011B10);
  static Color get secondary => const Color(0xFFBCA65A);
  static Color get p1Color => const Color(0xFF133A1B);
  static Color get y1Color => const Color(0xFFF2F3F4);

  // Text colors
  static Color get primaryText => const Color(0xff4A4B4D);
  static Color get secondaryText => const Color(0xff7C7D7E);
  static Color get readOnlyText => const Color(0xff333333);

  // textfield colors
  static Color get textField => const Color(0xffF2F2F2);
  static Color get readOnlyTextField => const Color(0xffD9D9D9);
  static Color get placeholder => const Color(0xffB6B7B7);

  // Status colors
  static Color get redColor => const Color(0xFFA91D3A);
  static Color get successColor => const Color(0xFF2E7D32);
  static Color get warningColor => const Color(0xFFF9A825);
  static Color get infoColor => const Color(0xFF0288D1);

  // Basic colors
  static Color get blackColor => Colors.black;
  static Color get whiteColor => const Color(0xFFFFFFFF);

  // Background colors
  static Color get backgroundColor => const Color(0xFFF5F6F8);
  static Color get cardBackground => const Color(0xFFFFFFFF);
  static Color get disabledColor => const Color(0xFFDCDCDC);


  // Shadow colors
  static Color get shadowColor => blackColor.withOpacity(0.1);
  static Color get shadowColorDark => blackColor.withOpacity(0.25);

  //NewsFeed Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFFFFFFF);

  // Shadow colors
  static const Color shadow = Color(0x40000000);

  // Shimmer effect colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Support colors
  static const Color secondaryLight = Color(0xFF80CBC4);
  static const Color background = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1E88E5);

  // New modern UI colors
  static Color get inputBorderFocus => secondary.withOpacity(0.8);
  static Color get subtleBackground => const Color(0xFFF9F9F9);
  static Color get subtleAccent => secondary.withOpacity(0.15);
  static Color get darkAccent => primary.withOpacity(0.8);
  static Color get dividerColor => const Color(0xFFEEEEEE);
  static const Color accent = Color(0xFFFF7043);

  // Border & Divider colors
  static const Color divider = Color(0xFFBDBDBD);
  static const Color border = Color(0xFFE0E0E0);

  // Additional modern UI colors
  static Color get accentGold => const Color(0xFFD4BE6A);
  static Color get lightGreen => const Color(0xFF4CAF50);
  static Color get itemBackground => const Color(0xFFFAFAFA);
  static Color get cardBorder => const Color(0xFFE0E0E0);
  static Color get badgeColor => const Color(0xFF388E3C);
  static Color get errorRed => const Color(0xFFD32F2F);
  static Color get subtleGold => secondary.withOpacity(0.2);
  static Color get darkGreen => const Color(0xFF1B5E20);
  static Color get primaryLight => primary.withOpacity(0.5);

  static const Color backgroundLight = Color(0xFFF9F9F9);

  // Gradient colors
  static List<Color> get primaryGradient => [
    primary,
    primary.withOpacity(0.8),
    p1Color,
  ];

  static List<Color> get secondaryGradient => [
    secondary,
    secondary.withOpacity(0.8),
    const Color(0xFFAB965A),
  ];

  // Button gradient
  static List<Color> get buttonGradient => [
    secondary,
    const Color(0xFFD4BE6A),
  ];

  // Card gradient
  static List<Color> get cardGradient => [
    whiteColor,
    subtleBackground,
  ];

  // Status gradients
  static List<Color> get successGradient => [
    successColor,
    lightGreen,
  ];

  static List<Color> get errorGradient => [
    redColor,
    errorRed,
  ];
}

// Keep these for backward compatibility
const Color wColor = Colors.white;
const Color blackColor = Colors.black;
const Color sdColor = Colors.black12;
const Color primaryColor = Color(0xFF011B10);
const Color rColor = Color(0xFFA91D3A);
const Color secondaryColor = Color(0xFFBCA65A);
const Color p1Color = Color(0xFF133A1B);
const Color y1Color = Color(0xFFF2F3F4);