import 'package:flutter/material.dart';
import 'colors.dart';

class AdropTypography {
  AdropTypography._();

  static const TextStyle heroTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.0,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontSize: 16,
    color: Color(0xB0FFFFFF),
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AdropColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AdropColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AdropColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AdropColors.textSecondary,
    height: 1.43,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: AdropColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    color: AdropColors.textSecondary,
  );

  static const TextStyle category = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AdropColors.primary,
  );

  static const TextStyle adLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AdropColors.textSecondary,
  );

  static const TextStyle formatTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AdropColors.primary,
  );
}
