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