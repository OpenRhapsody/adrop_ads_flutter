import 'package:flutter/material.dart';
import 'colors.dart';

class AdropStyles {
  AdropStyles._();

  static BoxDecoration card = BoxDecoration(
    color: AdropColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AdropColors.divider, width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  );

  static BoxDecoration rewardButton = BoxDecoration(
    color: AdropColors.primary,
    borderRadius: BorderRadius.circular(24),
  );

  static const BoxDecoration heroGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [AdropColors.heroGradientStart, AdropColors.heroGradientEnd],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AdropColors.primary,
    side: const BorderSide(color: AdropColors.primary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(vertical: 12),
  );

  static ButtonStyle filledButton = ElevatedButton.styleFrom(
    backgroundColor: AdropColors.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(vertical: 12),
  );
}
