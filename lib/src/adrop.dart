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

  /// Sets the user's marketing consent state for push notification ad targeting.
  ///
  /// The consent state and its change timestamp are stored locally and forwarded to the
  /// server via the next remote-config call. Calling this method with the same value as
  /// the current state is a no-op, so `consentedAt` always represents the actual
  /// decision time.
  ///
  /// Must be called after [initialize]; calls before initialization are dropped with a
  /// warning by the native SDK.
  ///
  /// This API is independent of user data consent (GDPR): toggling GDPR off does not
  /// prevent marketing consent from being sent to the server.
  ///
  /// [consent] `true` for opt-in (stored as 1), `false` for opt-out (stored as 0).
  static Future<void> setMarketingConsent(bool consent) async {
    try {
      return await AdropPlatform.instance.setMarketingConsent(consent);
    } catch (e) {
      log('Error: $e', name: 'Adrop');
    }
  }

  /// Registers a WebView for the WebView API for Ads.
  ///
  /// To serve Google AdSense/Ad Manager ads within a WebView,
  /// call this method after the WebView has been created.
  ///
  /// [webViewIdentifier] is the identifier extracted from the platform-specific WebView controller:
  /// - Android: `AndroidWebViewController.webViewIdentifier`
  /// - iOS: `WebKitWebViewController.webViewIdentifier`
  ///
  /// Requires AdropAdsBackfill to be installed for actual registration.
  /// If not installed, this call is silently ignored.
  static Future<void> registerWebView(int webViewIdentifier) async {
    try {
      return await AdropPlatform.instance.registerWebView(webViewIdentifier);
    } catch (e) {
      log('Error: $e', name: 'Adrop');
    }
  }
}
