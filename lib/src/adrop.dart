import 'dart:developer';

import 'adrop_platform_interface.dart';
import 'consent/adrop_consent_manager.dart';
import 'model/adrop_theme.dart';

class Adrop {
  /// Consent Manager for managing user consent (GDPR, CCPA, etc.)
  ///
  /// Use this to request consent info updates and check consent status.
  static final AdropConsentManager consentManager = AdropConsentManager();

  /// Initializes Adrop
  ///
  /// [production] When false, display error log in sdk
  /// [targetCountries] If you are using this SDK in specific countries, pass an array of ISO 3166 alpha-2 country codes.
  /// [useInAppBrowser] (Only iOS) If you want to use the in-app browser, set it to true.
  static Future<void> initialize(bool production,
      {List<String>? targetCountries, bool? useInAppBrowser}) async {
    return await AdropPlatform.instance.initialize(
        production, targetCountries ?? [], useInAppBrowser ?? false);
  }

  /// Set UID
  ///
  /// [uid] User ID for consistent web and app targeting
  static Future<void> setUID(String uid) async {
    try {
      return await AdropPlatform.instance.setUID(uid);
    } catch (e) {
      log('Error: $e', name: 'Adrop');
    }
  }

  /// Set Theme
  ///
  /// [theme] Theme for ad display
  static Future<void> setTheme(AdropTheme theme) async {
    try {
      return await AdropPlatform.instance.setTheme(theme.value);
    } catch (e) {
      log('Error: $e', name: 'Adrop');
    }
  }
}
