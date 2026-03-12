import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mock/mock_adrop_native_ad.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unitId = 'PUBLIC_TEST_UNIT_ID_NATIVE';
  const inactiveUnitId = 'PUBLIC_TEST_UNIT_ID_INACTIVE';
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  Map<dynamic, String> handleEventMessage = {};

  Map<String, bool> isLoading = {};
  Map<String, bool> isLoaded = {};
  Map<String, bool> isActive = {};
  bool isInitialized = false;
  Map<String, dynamic>? lastLoadPayload;

  final listener = AdropNativeListener(
    onAdReceived: (ad) => handleEventMessage[ad] = 'Ad Received',
    onAdClicked: (ad) => handleEventMessage[ad] = 'Ad Clicked',
    onAdImpression: (ad) => handleEventMessage[ad] = 'Ad Impression',
    onAdFailedToReceive: (ad, errorCode) => handleEventMessage[ad] =
        'Ad Failed to Receive with err: ${errorCode.name}',
  );

  final MockAdropNativeAd nativeAd =
      MockAdropNativeAd(unitId: unitId, listener: listener);

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(invokeChannel, (call) async {
    switch (call.method) {
      case AdropMethod.initialize:
        return isInitialized = true;

      case AdropMethod.loadAd:
        final adType = AdType.values[call.arguments['adType']];
        final unitId = call.arguments['unitId'];
        final requestId = call.arguments['requestId'];
        lastLoadPayload = Map<String, dynamic>.from(call.arguments as Map);
        final adropEventObserverChannelName =
            AdropChannel.adropEventListenerChannelOf(adType, requestId);
        final adropEventObserverChannel = adropEventObserverChannelName != null
            ? MethodChannel(adropEventObserverChannelName)
            : null;
        final key = '${adType.name}/$requestId';

        if (!isInitialized) {
          return await adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailToReceiveAd,
              {'errorCode': AdropErrorCode.initialize.code});
        }
        if (unitId == null || unitId == '') {
          return await adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailToReceiveAd,
              {'errorCode': AdropErrorCode.invalidUnit.code});
        }
        if (isActive[unitId] == null) {
          return await adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailToReceiveAd,
              {'errorCode': AdropErrorCode.adNoFill.code});
        }
        if (!isActive[unitId]!) {
          return await adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailToReceiveAd,
              {'errorCode': AdropErrorCode.inactive.code});
        }
        if (isLoaded[key] ?? false) {
          return await adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailToReceiveAd,
              {'errorCode': AdropErrorCode.adLoadDuplicate.code});
        }

        isLoading[key] = true;
        await Future.delayed(const Duration(seconds: 1));
        isLoading[key] = false;
        isLoaded[key] = true;

        return await adropEventObserverChannel
            ?.invokeMethod(AdropMethod.didReceiveAd, {
          'headline': 'Test Headline',
          'body': 'Test Body',
          'creative': 'https://example.com/creative.png',
          'asset': 'https://example.com/asset.png',
          'destinationURL': 'https://example.com',
          'callToAction': 'Learn More',
          'displayName': 'Test Brand',
          'displayLogo': 'https://example.com/logo.png',
          'isBackfilled': false,
          'extra': '{"key1":"value1"}',
          'creativeId': 'creative123',
          'txId': 'tx456',
          'campaignId': 'campaign789',
          'browserTarget': 0,
          'creativeSizeWidth': 300.0,
          'creativeSizeHeight': 250.0,
        });

      default:
        return null;
    }
  });

  setUp(() async {
    isActive[unitId] = true;
    isActive[inactiveUnitId] = false;
  });

  tearDown(() async {
    isLoaded.clear();
    isLoading.clear();
    isActive.clear();
    isInitialized = false;
    handleEventMessage.clear();
    lastLoadPayload = null;
    reset(nativeAd);
  });

  group('load', () {
    test('load sends correct adType, unitId, requestId', () async {
      await Adrop.initialize(true);
      await nativeAd.load();
      expect(lastLoadPayload?['adType'], AdType.native.index);
      expect(lastLoadPayload?['unitId'], unitId);
      expect(lastLoadPayload?['requestId'], isNotNull);
    });

    test('load before initialized error', () async {
      await nativeAd.load();
      expect(handleEventMessage[nativeAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.initialize.name}');
    });

    test('load with invalid unitId error', () async {
      await Adrop.initialize(true);
      final invalidAd = MockAdropNativeAd(unitId: '', listener: listener);
      await invalidAd.load();
      expect(handleEventMessage[invalidAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.invalidUnit.name}');
    });

    test('load success sets isLoaded and onAdReceived', () async {
      await Adrop.initialize(true);
      await nativeAd.load();

      expect(nativeAd.isLoaded, true);
      expect(handleEventMessage[nativeAd], 'Ad Received');
    });

    test('load sets properties from event args', () async {
      await Adrop.initialize(true);
      await nativeAd.load();

      expect(nativeAd.properties.headline, 'Test Headline');
      expect(nativeAd.properties.body, 'Test Body');
      expect(nativeAd.properties.creative, 'https://example.com/creative.png');
      expect(nativeAd.properties.callToAction, 'Learn More');
      expect(nativeAd.properties.profile?.displayName, 'Test Brand');
      expect(nativeAd.properties.profile?.displayLogo,
          'https://example.com/logo.png');
    });

    test('load sets creativeSize from event args', () async {
      await Adrop.initialize(true);
      await nativeAd.load();

      expect(nativeAd.creativeSize.width, 300.0);
      expect(nativeAd.creativeSize.height, 250.0);
    });

    test('load sets metadata fields from event', () async {
      await Adrop.initialize(true);
      await nativeAd.load();

      expect(nativeAd.creativeId, 'creative123');
      expect(nativeAd.txId, 'tx456');
      expect(nativeAd.campaignId, 'campaign789');
      expect(nativeAd.destinationURL, 'https://example.com');
      expect(nativeAd.browserTarget, BrowserTarget.external);
    });

    test('useCustomClick flag forwarded in load payload', () async {
      await Adrop.initialize(true);
      final customClickAd = MockAdropNativeAd(
          unitId: unitId, useCustomClick: true, listener: listener);
      await customClickAd.load();
      expect(lastLoadPayload?['useCustomClick'], true);
    });

    test('isBackfilled reflects properties.isBackfilled', () async {
      await Adrop.initialize(true);
      await nativeAd.load();
      expect(nativeAd.isBackfilled, false);
    });
  });

  group('events', () {
    test('click event triggers onAdClicked', () async {
      final channelName = AdropChannel.adropEventListenerChannelOf(
          AdType.native, nativeAd.requestId);
      final channel = channelName != null ? MethodChannel(channelName) : null;
      await channel?.invokeMethod(AdropMethod.didClickAd, {
        'creativeId': '',
        'txId': '',
        'campaignId': '',
        'destinationURL': '',
      });
      expect(handleEventMessage[nativeAd], 'Ad Clicked');
    });

    test('impression event triggers onAdImpression', () async {
      final channelName = AdropChannel.adropEventListenerChannelOf(
          AdType.native, nativeAd.requestId);
      final channel = channelName != null ? MethodChannel(channelName) : null;
      await channel?.invokeMethod(AdropMethod.didImpression, {
        'creativeId': '',
        'txId': '',
        'campaignId': '',
        'destinationURL': '',
      });
      expect(handleEventMessage[nativeAd], 'Ad Impression');
    });

    test('fail event triggers onAdFailedToReceive with errorCode', () async {
      final channelName = AdropChannel.adropEventListenerChannelOf(
          AdType.native, nativeAd.requestId);
      final channel = channelName != null ? MethodChannel(channelName) : null;
      await channel?.invokeMethod(AdropMethod.didFailToReceiveAd, {
        'errorCode': AdropErrorCode.network.code,
        'creativeId': '',
        'txId': '',
        'campaignId': '',
        'destinationURL': '',
      });
      expect(handleEventMessage[nativeAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.network.name}');
    });
  });
}
