import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mock/mock_adrop_interstitial_ad.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unitId = 'PUBLIC_TEST_UNIT_ID_INTERSTITIAL';
  const unitId2 = 'PUBLIC_TEST_UNIT_ID_INTERSTITIAL_2';
  const inactiveUnitId = 'PUBLIC_TEST_UNIT_ID_INACTIVE';
  const nonExistUnitId = 'PUBLIC_TEST_UNIT_ID_NOT_EXIST';
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  Map<AdropAd, String> handleEventMessage = {};

  final listener = AdropInterstitialListener(
    onAdReceived: (ad) => handleEventMessage[ad] = 'Ad Received',
    onAdClicked: (ad) => handleEventMessage[ad] = 'Ad Clicked',
    onAdImpression: (ad) => handleEventMessage[ad] = 'Ad Impression',
    onAdFailedToReceive: (ad, errorCode) => handleEventMessage[ad] =
        'Ad Failed to Receive with err: ${errorCode.name}',
    onAdFailedToShowFullScreen: (ad, errorCode) => handleEventMessage[ad] =
        'Ad Failed to Show with err: ${errorCode.name}',
    onAdWillPresentFullScreen: (ad) =>
        handleEventMessage[ad] = 'Ad Will Present',
    onAdDidPresentFullScreen: (ad) => handleEventMessage[ad] = 'Ad Did Present',
    onAdWillDismissFullScreen: (ad) =>
        handleEventMessage[ad] = 'Ad Will Dismiss',
    onAdDidDismissFullScreen: (ad) => handleEventMessage[ad] = 'Ad Did Dismiss',
  );
  final MockAdropInterstitialAd interstitialAd =
      MockAdropInterstitialAd(unitId: unitId, listener: listener);

  Map<String, bool> isLoading = {};
  Map<String, bool> isLoaded = {};
  Map<String, bool> isActive = {};
  Map<String, bool> isShown = {};
  bool isInitialized = false;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(invokeChannel, (call) async {
    switch (call.method) {
      case AdropMethod.initialize:
        return isInitialized = true;

      case AdropMethod.loadAd:
        final adType = AdType.values[call.arguments['adType']];
        final unitId = call.arguments['unitId'];
        final requestId = call.arguments['requestId'];
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
        if (isLoading[key] ?? false) {
          return await adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailToReceiveAd,
              {'errorCode': AdropErrorCode.adLoading.code});
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
            ?.invokeMethod(AdropMethod.didReceiveAd);

      case AdropMethod.showAd:
        final adType = AdType.values[call.arguments['adType']];
        final requestId = call.arguments['requestId'];
        final adropEventObserverChannelName =
            AdropChannel.adropEventListenerChannelOf(adType, requestId);
        final adropEventObserverChannel = adropEventObserverChannelName != null
            ? MethodChannel(adropEventObserverChannelName)
            : null;
        final key = '${adType.name}/$requestId';
        if (isLoading[key] ?? false) {
          return adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailedToShowFullScreen,
              {'errorCode': AdropErrorCode.adLoading.code});
        }
        if (isShown[key] ?? false) {
          return adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailedToShowFullScreen,
              {'errorCode': AdropErrorCode.adShown.code});
        }
        if (!(isLoaded[key] ?? false)) {
          return adropEventObserverChannel?.invokeMethod(
              AdropMethod.didFailedToShowFullScreen,
              {'errorCode': AdropErrorCode.adEmpty.code});
        }
        await adropEventObserverChannel
            ?.invokeMethod(AdropMethod.willPresentFullScreen);
        await Future.delayed(const Duration(seconds: 1));
        isShown[key] = true;

        return await adropEventObserverChannel
            ?.invokeMethod(AdropMethod.didPresentFullScreen);

      default:
        return null;
    }
  });

  setUp(() async {
    isActive[unitId] = true;
    isActive[unitId2] = true;
    isActive[inactiveUnitId] = false;
  });

  tearDown(() async {
    isLoaded.clear();
    isLoading.clear();
    isActive.clear();
    isShown.clear();
    isInitialized = false;
    handleEventMessage.clear();
    reset(interstitialAd);
  });

  group('load', () {
    test('load before initialized error', () async {
      await interstitialAd.load();
      expect(handleEventMessage[interstitialAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.initialize.name}');
    });

    test('load with invalid unitId error', () async {
      await Adrop.initialize(true);
      final nullInterstitialAd =
          MockAdropInterstitialAd(unitId: '', listener: listener);
      await nullInterstitialAd.load();
      expect(handleEventMessage[nullInterstitialAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.invalidUnit.name}');
      await nullInterstitialAd.dispose();
    });

    test('load with non-exist unitId error', () async {
      await Adrop.initialize(true);
      final nonExistInterstitialAd =
          MockAdropInterstitialAd(unitId: nonExistUnitId, listener: listener);
      await nonExistInterstitialAd.load();
      expect(handleEventMessage[nonExistInterstitialAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adNoFill.name}');
      await nonExistInterstitialAd.dispose();
    });

    test('load with inactive unitId error', () async {
      await Adrop.initialize(true);
      final inactiveInterstitialAd =
          MockAdropInterstitialAd(unitId: inactiveUnitId, listener: listener);
      await inactiveInterstitialAd.load();
      expect(handleEventMessage[inactiveInterstitialAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.inactive.name}');
      await inactiveInterstitialAd.dispose();
    });

    test('load test interstitial ad', () async {
      await Adrop.initialize(true);
      await interstitialAd.load();

      expect(interstitialAd.isLoaded, true);
      expect(handleEventMessage[interstitialAd], 'Ad Received');
    });

    test('load two interstitial ads', () async {
      await Adrop.initialize(true);
      final interstitialAd2 =
          MockAdropInterstitialAd(unitId: unitId2, listener: listener);
      await Future.wait([interstitialAd.load(), interstitialAd2.load()]);

      expect(interstitialAd.isLoaded, true);
      expect(interstitialAd2.isLoaded, true);
      expect(handleEventMessage[interstitialAd], 'Ad Received');
      expect(handleEventMessage[interstitialAd2], 'Ad Received');
    });

    test('load duplicate error', () async {
      await Adrop.initialize(true);
      await interstitialAd.load();
      await interstitialAd.load();
      expect(handleEventMessage[interstitialAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adLoadDuplicate.name}');
    });

    test('load while loading error', () async {
      await Adrop.initialize(true);
      interstitialAd.load();
      interstitialAd.load();
      expect(handleEventMessage[interstitialAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adLoading.name}');
    });
  });

  group('show', () {
    test('show while loading error', () async {
      await Adrop.initialize(true);
      interstitialAd.load();
      await interstitialAd.show();
      expect(handleEventMessage[interstitialAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adLoading.name}');
    });

    test('show after shown error', () async {
      await Adrop.initialize(true);
      await interstitialAd.load();
      await interstitialAd.show();
      await interstitialAd.show();
      expect(handleEventMessage[interstitialAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adShown.name}');
    });

    test('show not loaded ad error', () async {
      await Adrop.initialize(true);
      await interstitialAd.show();
      expect(handleEventMessage[interstitialAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adEmpty.name}');
    });

    test('show interstitial ad', () async {
      await Adrop.initialize(true);
      await interstitialAd.load();
      interstitialAd.show();
      expect(handleEventMessage[interstitialAd], 'Ad Will Present');
      await Future.delayed(const Duration(seconds: 2));
      expect(handleEventMessage[interstitialAd], 'Ad Did Present');
    });

    test('show two interstitial ads', () async {
      await Adrop.initialize(true);
      final interstitialAd2 =
          MockAdropInterstitialAd(unitId: unitId2, listener: listener);
      await Future.wait([interstitialAd.load(), interstitialAd2.load()]);

      await interstitialAd.show();
      expect(handleEventMessage[interstitialAd], 'Ad Did Present');
      interstitialAd2.show();
      expect(handleEventMessage[interstitialAd2], 'Ad Will Present');
      await Future.delayed(const Duration(seconds: 2));
      expect(handleEventMessage[interstitialAd2], 'Ad Did Present');
    });
  });

  test('click ad', () async {
    final adropEventObserverChannelName =
        AdropChannel.adropEventListenerChannelOf(
            AdType.interstitial, interstitialAd.requestId);
    final adropEventObserverChannel = adropEventObserverChannelName != null
        ? MethodChannel(adropEventObserverChannelName)
        : null;
    await adropEventObserverChannel?.invokeMethod(AdropMethod.didClickAd);
    expect(handleEventMessage[interstitialAd], 'Ad Clicked');
  });

  test('impression', () async {
    final adropEventObserverChannelName =
        AdropChannel.adropEventListenerChannelOf(
            AdType.interstitial, interstitialAd.requestId);
    final adropEventObserverChannel = adropEventObserverChannelName != null
        ? MethodChannel(adropEventObserverChannelName)
        : null;
    await adropEventObserverChannel?.invokeMethod(AdropMethod.didImpression);
    expect(handleEventMessage[interstitialAd], 'Ad Impression');
  });

  group('close ad', () {
    test('will dismiss', () async {
      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(
              AdType.interstitial, interstitialAd.requestId);
      final adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      await adropEventObserverChannel
          ?.invokeMethod(AdropMethod.willDismissFullScreen);
      expect(handleEventMessage[interstitialAd], 'Ad Will Dismiss');
    });

    test('did dismiss', () async {
      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(
              AdType.interstitial, interstitialAd.requestId);
      final adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      await adropEventObserverChannel
          ?.invokeMethod(AdropMethod.didDismissFullScreen);
      expect(handleEventMessage[interstitialAd], 'Ad Did Dismiss');
    });
  });
}
