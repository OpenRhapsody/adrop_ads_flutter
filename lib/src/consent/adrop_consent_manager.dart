import 'dart:developer';

import 'package:flutter/services.dart';

import '../bridge/adrop_channel.dart';
import '../bridge/adrop_method.dart';
import 'adrop_consent_debug_geography.dart';
import 'adrop_consent_result.dart';
import 'adrop_consent_status.dart';
import 'adrop_privacy_options_requirement_status.dart';

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
  /// Call this on every app launch, even when consent was already obtained —
  /// [getPrivacyOptionsRequirementStatus] reflects this session only after it
  /// completes.
  ///
  /// [listener] Callback that receives the consent result
  Future<void> requestConsentInfoUpdate(AdropConsentListener listener) {
    return _invokeForResult(AdropMethod.requestConsentInfoUpdate, listener);
  }

  /// Whether a privacy options (privacy settings) entry point must be shown
  ///
  /// Meaningful after [requestConsentInfoUpdate] completes in this app session;
  /// before that it is [AdropPrivacyOptionsRequirementStatus.unknown] or the
  /// previous session's value. When it is
  /// [AdropPrivacyOptionsRequirementStatus.required], show the entry point
  /// (e.g. in your settings screen) and call [showPrivacyOptionsForm] from it.
  Future<AdropPrivacyOptionsRequirementStatus>
      getPrivacyOptionsRequirementStatus() async {
    try {
      final result = await _methodChannel
          .invokeMethod<int>(AdropMethod.getPrivacyOptionsRequirementStatus);
      return AdropPrivacyOptionsRequirementStatus.fromValue(result ?? 0);
    } catch (e) {
      log('Error getting privacy options requirement status: $e',
          name: 'AdropConsentManager');
      return AdropPrivacyOptionsRequirementStatus.unknown;
    }
  }

  /// Show the privacy options form so the user can change their consent
  ///
  /// The form is shown only when [getPrivacyOptionsRequirementStatus] is
  /// [AdropPrivacyOptionsRequirementStatus.required]. Otherwise consent is left
  /// unchanged and [listener] receives the current state with an error.
  ///
  /// [listener] Callback that receives the consent result after the form closes
  Future<void> showPrivacyOptionsForm(AdropConsentListener listener) {
    return _invokeForResult(AdropMethod.showPrivacyOptionsForm, listener);
  }

  /// Calls a native method that answers with an [AdropConsentResult] map and
  /// always invokes [listener] exactly once.
  Future<void> _invokeForResult(
      String method, AdropConsentListener listener) async {
    try {
      final result =
          await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(method);

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
      log('Error calling $method: $e', name: 'AdropConsentManager');
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

  /// Reset consent information — **for testing only, do not call in
  /// production code.** To let users change their consent, use
  /// [showPrivacyOptionsForm].
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
