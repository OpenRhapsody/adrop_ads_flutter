import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:adrop_ads_flutter/src/consent/adrop_consent_debug_geography.dart';
import 'package:adrop_ads_flutter/src/consent/adrop_consent_manager.dart';
import 'package:adrop_ads_flutter/src/consent/adrop_consent_result.dart';
import 'package:adrop_ads_flutter/src/consent/adrop_consent_status.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);

  late AdropConsentManager consentManager;
  AdropConsentStatus mockConsentStatus = AdropConsentStatus.unknown;
  bool mockCanRequestAds = false;
  bool mockCanShowPersonalizedAds = false;
  String? mockError;
  bool shouldThrowError = false;
  AdropConsentDebugGeography? lastDebugGeography;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(invokeChannel, (call) async {
    if (shouldThrowError) {
      throw PlatformException(code: 'ERROR', message: 'Test error');
    }

    switch (call.method) {
      case AdropMethod.requestConsentInfoUpdate:
        return {
          'status': mockConsentStatus.value,
          'canRequestAds': mockCanRequestAds,
          'canShowPersonalizedAds': mockCanShowPersonalizedAds,
          'error': mockError,
        };

      case AdropMethod.getConsentStatus:
        return mockConsentStatus.value;

      case AdropMethod.canRequestAds:
        return mockCanRequestAds;

      case AdropMethod.resetConsent:
        mockConsentStatus = AdropConsentStatus.unknown;
        mockCanRequestAds = false;
        mockCanShowPersonalizedAds = false;
        return null;

      case AdropMethod.setConsentDebugSettings:
        lastDebugGeography = AdropConsentDebugGeography.fromValue(
            call.arguments['geography'] as int);
        return null;

      default:
        return null;
    }
  });

  setUp(() {
    consentManager = AdropConsentManager();
    mockConsentStatus = AdropConsentStatus.unknown;
    mockCanRequestAds = false;
    mockCanShowPersonalizedAds = false;
    mockError = null;
    shouldThrowError = false;
    lastDebugGeography = null;
  });

  group('AdropConsentStatus', () {
    test('fromValue returns correct status', () {
      expect(AdropConsentStatus.fromValue(0), AdropConsentStatus.unknown);
      expect(AdropConsentStatus.fromValue(1), AdropConsentStatus.required);
      expect(AdropConsentStatus.fromValue(2), AdropConsentStatus.notRequired);
      expect(AdropConsentStatus.fromValue(3), AdropConsentStatus.obtained);
    });

    test('fromValue returns unknown for invalid value', () {
      expect(AdropConsentStatus.fromValue(99), AdropConsentStatus.unknown);
      expect(AdropConsentStatus.fromValue(-1), AdropConsentStatus.unknown);
    });

    test('value property returns correct int', () {
      expect(AdropConsentStatus.unknown.value, 0);
      expect(AdropConsentStatus.required.value, 1);
      expect(AdropConsentStatus.notRequired.value, 2);
      expect(AdropConsentStatus.obtained.value, 3);
    });
  });

  group('AdropConsentDebugGeography', () {
    test('fromValue returns correct geography', () {
      expect(AdropConsentDebugGeography.fromValue(0),
          AdropConsentDebugGeography.disabled);
      expect(AdropConsentDebugGeography.fromValue(1),
          AdropConsentDebugGeography.eea);
      expect(AdropConsentDebugGeography.fromValue(3),
          AdropConsentDebugGeography.regulatedUSState);
      expect(AdropConsentDebugGeography.fromValue(4),
          AdropConsentDebugGeography.other);
    });

    test('fromValue returns disabled for invalid value', () {
      expect(AdropConsentDebugGeography.fromValue(99),
          AdropConsentDebugGeography.disabled);
      expect(AdropConsentDebugGeography.fromValue(-1),
          AdropConsentDebugGeography.disabled);
    });

    test('value property returns correct int', () {
      expect(AdropConsentDebugGeography.disabled.value, 0);
      expect(AdropConsentDebugGeography.eea.value, 1);
      expect(AdropConsentDebugGeography.regulatedUSState.value, 3);
      expect(AdropConsentDebugGeography.other.value, 4);
    });
  });

  group('AdropConsentResult', () {
    test('fromMap creates result correctly', () {
      final map = {
        'status': 3,
        'canRequestAds': true,
        'canShowPersonalizedAds': true,
        'error': null,
      };

      final result = AdropConsentResult.fromMap(map);

      expect(result.status, AdropConsentStatus.obtained);
      expect(result.canRequestAds, true);
      expect(result.canShowPersonalizedAds, true);
      expect(result.error, null);
    });

    test('fromMap handles missing values with defaults', () {
      final map = <String, dynamic>{};

      final result = AdropConsentResult.fromMap(map);

      expect(result.status, AdropConsentStatus.unknown);
      expect(result.canRequestAds, false);
      expect(result.canShowPersonalizedAds, false);
      expect(result.error, null);
    });

    test('fromMap handles error message', () {
      final map = {
        'status': 0,
        'canRequestAds': false,
        'canShowPersonalizedAds': false,
        'error': 'Consent form error',
      };

      final result = AdropConsentResult.fromMap(map);

      expect(result.error, 'Consent form error');
    });

    test('toString returns correct format', () {
      final result = AdropConsentResult(
        status: AdropConsentStatus.obtained,
        canRequestAds: true,
        canShowPersonalizedAds: false,
        error: null,
      );

      expect(result.toString(),
          'AdropConsentResult(status: AdropConsentStatus.obtained, canRequestAds: true, canShowPersonalizedAds: false, error: null)');
    });
  });

  group('AdropConsentManager.requestConsentInfoUpdate', () {
    test('returns consent obtained result', () async {
      mockConsentStatus = AdropConsentStatus.obtained;
      mockCanRequestAds = true;
      mockCanShowPersonalizedAds = true;

      AdropConsentResult? receivedResult;
      await consentManager.requestConsentInfoUpdate((result) {
        receivedResult = result;
      });

      expect(receivedResult, isNotNull);
      expect(receivedResult!.status, AdropConsentStatus.obtained);
      expect(receivedResult!.canRequestAds, true);
      expect(receivedResult!.canShowPersonalizedAds, true);
      expect(receivedResult!.error, null);
    });

    test('returns consent required result', () async {
      mockConsentStatus = AdropConsentStatus.required;
      mockCanRequestAds = false;
      mockCanShowPersonalizedAds = false;

      AdropConsentResult? receivedResult;
      await consentManager.requestConsentInfoUpdate((result) {
        receivedResult = result;
      });

      expect(receivedResult!.status, AdropConsentStatus.required);
      expect(receivedResult!.canRequestAds, false);
    });

    test('returns consent not required result', () async {
      mockConsentStatus = AdropConsentStatus.notRequired;
      mockCanRequestAds = true;
      mockCanShowPersonalizedAds = true;

      AdropConsentResult? receivedResult;
      await consentManager.requestConsentInfoUpdate((result) {
        receivedResult = result;
      });

      expect(receivedResult!.status, AdropConsentStatus.notRequired);
      expect(receivedResult!.canRequestAds, true);
    });

    test('handles error gracefully', () async {
      shouldThrowError = true;

      AdropConsentResult? receivedResult;
      await consentManager.requestConsentInfoUpdate((result) {
        receivedResult = result;
      });

      expect(receivedResult!.status, AdropConsentStatus.unknown);
      expect(receivedResult!.canRequestAds, false);
      expect(receivedResult!.error, isNotNull);
    });
  });

  group('AdropConsentManager.getConsentStatus', () {
    test('returns unknown status', () async {
      mockConsentStatus = AdropConsentStatus.unknown;
      final status = await consentManager.getConsentStatus();
      expect(status, AdropConsentStatus.unknown);
    });

    test('returns required status', () async {
      mockConsentStatus = AdropConsentStatus.required;
      final status = await consentManager.getConsentStatus();
      expect(status, AdropConsentStatus.required);
    });

    test('returns notRequired status', () async {
      mockConsentStatus = AdropConsentStatus.notRequired;
      final status = await consentManager.getConsentStatus();
      expect(status, AdropConsentStatus.notRequired);
    });

    test('returns obtained status', () async {
      mockConsentStatus = AdropConsentStatus.obtained;
      final status = await consentManager.getConsentStatus();
      expect(status, AdropConsentStatus.obtained);
    });

    test('returns unknown on error', () async {
      shouldThrowError = true;
      final status = await consentManager.getConsentStatus();
      expect(status, AdropConsentStatus.unknown);
    });
  });

  group('AdropConsentManager.canRequestAds', () {
    test('returns true when ads can be requested', () async {
      mockCanRequestAds = true;
      final canRequest = await consentManager.canRequestAds();
      expect(canRequest, true);
    });

    test('returns false when ads cannot be requested', () async {
      mockCanRequestAds = false;
      final canRequest = await consentManager.canRequestAds();
      expect(canRequest, false);
    });

    test('returns false on error', () async {
      shouldThrowError = true;
      final canRequest = await consentManager.canRequestAds();
      expect(canRequest, false);
    });
  });

  group('AdropConsentManager.reset', () {
    test('resets consent info', () async {
      mockConsentStatus = AdropConsentStatus.obtained;
      mockCanRequestAds = true;

      await consentManager.reset();

      final status = await consentManager.getConsentStatus();
      expect(status, AdropConsentStatus.unknown);

      final canRequest = await consentManager.canRequestAds();
      expect(canRequest, false);
    });

    test('handles error gracefully', () async {
      shouldThrowError = true;
      // Should not throw
      await consentManager.reset();
    });
  });

  group('AdropConsentManager.setDebugSettings', () {
    test('sets disabled geography', () async {
      await consentManager
          .setDebugSettings(AdropConsentDebugGeography.disabled);
      expect(lastDebugGeography, AdropConsentDebugGeography.disabled);
    });

    test('sets EEA geography', () async {
      await consentManager.setDebugSettings(AdropConsentDebugGeography.eea);
      expect(lastDebugGeography, AdropConsentDebugGeography.eea);
    });

    test('sets regulated US state geography', () async {
      await consentManager
          .setDebugSettings(AdropConsentDebugGeography.regulatedUSState);
      expect(lastDebugGeography, AdropConsentDebugGeography.regulatedUSState);
    });

    test('sets other geography', () async {
      await consentManager.setDebugSettings(AdropConsentDebugGeography.other);
      expect(lastDebugGeography, AdropConsentDebugGeography.other);
    });

    test('handles error gracefully', () async {
      shouldThrowError = true;
      // Should not throw
      await consentManager.setDebugSettings(AdropConsentDebugGeography.eea);
    });
  });

  group('AdropConsentManager singleton', () {
    test('returns same instance', () {
      final manager1 = AdropConsentManager();
      final manager2 = AdropConsentManager();
      expect(identical(manager1, manager2), true);
    });
  });
}
