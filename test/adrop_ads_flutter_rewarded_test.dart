import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mock/mock_adrop_rewarded_ad.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unitId = 'PUBLIC_TEST_UNIT_ID_REWARDED';
  const unitId2 = 'PUBLIC_TEST_UNIT_ID_REWARDED_2';
  const inactiveUnitId = 'PUBLIC_TEST_UNIT_ID_INACTIVE';
  const nonExistUnitId = 'PUBLIC_TEST_UNIT_ID_NOT_EXIST';
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  Map<AdropAd, String> handleEventMessage = {};

  final listener = AdropRewardedListener(
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
    onAdEarnRewardHandler: (ad, type, amount) =>
        handleEventMessage[ad] = 'Ad Earned type $type with amount $amount',
  );
  final MockAdropRewardedAd rewardedAd =
      MockAdropRewardedAd(unitId: unitId, listener: listener);

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
    reset(rewardedAd);
  });

  group('load', () {
    test('load before initialized error', () async {
      await rewardedAd.load();
      expect(handleEventMessage[rewardedAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.initialize.name}');
    });

    test('load with invalid unitId error', () async {
      await Adrop.initialize(true);
      final nullRewardedAd =
          MockAdropRewardedAd(unitId: '', listener: listener);
      await nullRewardedAd.load();
      expect(handleEventMessage[nullRewardedAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.invalidUnit.name}');
      await nullRewardedAd.dispose();
    });

    test('load with non-exist unitId error', () async {
      await Adrop.initialize(true);
      final nonExistRewardedAd =
          MockAdropRewardedAd(unitId: nonExistUnitId, listener: listener);
      await nonExistRewardedAd.load();
      expect(handleEventMessage[nonExistRewardedAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adNoFill.name}');
      await nonExistRewardedAd.dispose();
    });

    test('load with inactive unitId error', () async {
      await Adrop.initialize(true);
      final inactiveRewardedAd =
          MockAdropRewardedAd(unitId: inactiveUnitId, listener: listener);
      await inactiveRewardedAd.load();
      expect(handleEventMessage[inactiveRewardedAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.inactive.name}');
      await inactiveRewardedAd.dispose();
    });

    test('load test rewarded ad', () async {
      await Adrop.initialize(true);
      await rewardedAd.load();

      expect(rewardedAd.isLoaded, true);
      expect(handleEventMessage[rewardedAd], 'Ad Received');
    });

    test('load two rewarded ads', () async {
      await Adrop.initialize(true);
      final rewardedAd2 =
          MockAdropRewardedAd(unitId: unitId2, listener: listener);
      await Future.wait([rewardedAd.load(), rewardedAd2.load()]);

      expect(rewardedAd.isLoaded, true);
      expect(rewardedAd2.isLoaded, true);
      expect(handleEventMessage[rewardedAd], 'Ad Received');
      expect(handleEventMessage[rewardedAd2], 'Ad Received');
    });

    test('load duplicate error', () async {
      await Adrop.initialize(true);
      await rewardedAd.load();
      await rewardedAd.load();
      expect(handleEventMessage[rewardedAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adLoadDuplicate.name}');
    });

    test('load while loading error', () async {
      await Adrop.initialize(true);
      rewardedAd.load();
      rewardedAd.load();
      expect(handleEventMessage[rewardedAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adLoading.name}');
    });
  });

  group('show', () {
    test('show while loading error', () async {
      await Adrop.initialize(true);
      rewardedAd.load();
      await rewardedAd.show();
      expect(handleEventMessage[rewardedAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adLoading.name}');
    });

    test('show after shown error', () async {
      await Adrop.initialize(true);
      await rewardedAd.load();
      await rewardedAd.show();
      await rewardedAd.show();
      expect(handleEventMessage[rewardedAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adShown.name}');
    });

    test('show not loaded ad error', () async {
      await Adrop.initialize(true);
      await rewardedAd.show();
      expect(handleEventMessage[rewardedAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adEmpty.name}');
    });

    test('show rewarded ad', () async {
      await Adrop.initialize(true);
      await rewardedAd.load();
      rewardedAd.show();
      expect(handleEventMessage[rewardedAd], 'Ad Will Present');
      await Future.delayed(const Duration(seconds: 2));
      expect(handleEventMessage[rewardedAd], 'Ad Did Present');
    });

    test('show two rewarded ads', () async {
      await Adrop.initialize(true);
      final rewardedAd2 =
          MockAdropRewardedAd(unitId: unitId2, listener: listener);
      await Future.wait([rewardedAd.load(), rewardedAd2.load()]);

      await rewardedAd.show();
      expect(handleEventMessage[rewardedAd], 'Ad Did Present');
      rewardedAd2.show();
      expect(handleEventMessage[rewardedAd2], 'Ad Will Present');
      await Future.delayed(const Duration(seconds: 2));
      expect(handleEventMessage[rewardedAd2], 'Ad Did Present');
    });
  });

  test('click ad', () async {
    final adropEventObserverChannelName =
        AdropChannel.adropEventListenerChannelOf(
            AdType.rewarded, rewardedAd.requestId);
    final adropEventObserverChannel = adropEventObserverChannelName != null
        ? MethodChannel(adropEventObserverChannelName)
        : null;
    await adropEventObserverChannel?.invokeMethod(AdropMethod.didClickAd);
    expect(handleEventMessage[rewardedAd], 'Ad Clicked');
  });

  test('impression', () async {
    final adropEventObserverChannelName =
        AdropChannel.adropEventListenerChannelOf(
            AdType.rewarded, rewardedAd.requestId);
    final adropEventObserverChannel = adropEventObserverChannelName != null
        ? MethodChannel(adropEventObserverChannelName)
        : null;
    await adropEventObserverChannel?.invokeMethod(AdropMethod.didImpression);
    expect(handleEventMessage[rewardedAd], 'Ad Impression');
  });

  group('close ad', () {
    test('will dismiss', () async {
      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(
              AdType.rewarded, rewardedAd.requestId);
      final adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      await adropEventObserverChannel
          ?.invokeMethod(AdropMethod.willDismissFullScreen);
      expect(handleEventMessage[rewardedAd], 'Ad Will Dismiss');
    });

    test('did dismiss', () async {
      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(
              AdType.rewarded, rewardedAd.requestId);
      final adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      await adropEventObserverChannel
          ?.invokeMethod(AdropMethod.didDismissFullScreen);
      expect(handleEventMessage[rewardedAd], 'Ad Did Dismiss');
    });
  });

  test('earn reward', () async {
    final adropEventObserverChannelName =
        AdropChannel.adropEventListenerChannelOf(
            AdType.rewarded, rewardedAd.requestId);
    final adropEventObserverChannel = adropEventObserverChannelName != null
        ? MethodChannel(adropEventObserverChannelName)
        : null;
    await adropEventObserverChannel?.invokeMethod(
        AdropMethod.didHandleEarnReward, {'type': 1, 'amount': 100});
    expect(handleEventMessage[rewardedAd], 'Ad Earned type 1 with amount 100');
  });
}
