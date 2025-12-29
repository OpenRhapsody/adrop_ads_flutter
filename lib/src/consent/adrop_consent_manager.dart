import 'dart:developer';

import 'package:flutter/services.dart';

import '../bridge/adrop_channel.dart';
import '../bridge/adrop_method.dart';
import 'adrop_consent_debug_geography.dart';
import 'adrop_consent_result.dart';
import 'adrop_consent_status.dart';

const _methodChannel = MethodChannel(AdropChannel.invokeChannel);

/// Callback for consent info update
typedef AdropConsentListener = void Function(AdropConsentResult result);

/// Consent Manager for managing user consent (GDPR, CCPA, etc.)
///
/// This manager provides methods to request consent information updates,
/// check consent status, and manage debug settings for testing.
class AdropConsentManager {
  static final AdropConsentManager _instance = AdropConsentManager._internal();

  factory AdropConsentManager() => _instance;

  AdropConsentManager._internal();

  /// Request consent info update and show consent form if required
  ///
  /// [listener] Callback that receives the consent result
  Future<void> requestConsentInfoUpdate(AdropConsentListener listener) async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
          AdropMethod.requestConsentInfoUpdate);

      if (result != null) {
        listener(AdropConsentResult.fromMap(result));
      } else {
        listener(AdropConsentResult(
          status: AdropConsentStatus.unknown,
          canRequestAds: false,
          canShowPersonalizedAds: false,
          error: 'No result returned',
        ));
      }
    } catch (e) {
      log('Error requesting consent info update: $e',
          name: 'AdropConsentManager');
      listener(AdropConsentResult(
        status: AdropConsentStatus.unknown,
        canRequestAds: false,
        canShowPersonalizedAds: false,
        error: e.toString(),
      ));
    }
  }

  /// Get the current consent status
  Future<AdropConsentStatus> getConsentStatus() async {
    try {
      final result =
          await _methodChannel.invokeMethod<int>(AdropMethod.getConsentStatus);
      return AdropConsentStatus.fromValue(result ?? 0);
    } catch (e) {
      log('Error getting consent status: $e', name: 'AdropConsentManager');
      return AdropConsentStatus.unknown;
    }
  }

  /// Check if ads can be requested
  Future<bool> canRequestAds() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>(AdropMethod.canRequestAds);
      return result ?? false;
    } catch (e) {
      log('Error checking canRequestAds: $e', name: 'AdropConsentManager');
      return false;
    }
  }

  /// Reset consent information (for testing/debugging)
  Future<void> reset() async {
    try {
      await _methodChannel.invokeMethod(AdropMethod.resetConsent);
    } catch (e) {
      log('Error resetting consent: $e', name: 'AdropConsentManager');
    }
  }

  /// Set debug settings for testing consent flows
  ///
  /// [geography] Test geography setting
  Future<void> setDebugSettings(AdropConsentDebugGeography geography) async {
    try {
      await _methodChannel.invokeMethod(AdropMethod.setConsentDebugSettings, {
        'geography': geography.value,
      });
    } catch (e) {
      log('Error setting debug settings: $e', name: 'AdropConsentManager');
    }
  }
}
