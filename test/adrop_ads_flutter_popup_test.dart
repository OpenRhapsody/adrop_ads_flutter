import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mock/mock_adrop_popup_ad.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unitId = 'PUBLIC_TEST_UNIT_ID_POPUP';
  const unitId2 = 'PUBLIC_TEST_UNIT_ID_POPUP_2';
  const inactiveUnitId = 'PUBLIC_TEST_UNIT_ID_INACTIVE';
  const nonExistUnitId = 'PUBLIC_TEST_UNIT_ID_NOT_EXIST';
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  Map<AdropAd, String> handleEventMessage = {};

  final listener = AdropPopupListener(
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
  final MockAdropPopupAd popupAd =
      MockAdropPopupAd(unitId: unitId, listener: listener);

  Map<String, bool> isLoading = {};
  Map<String, bool> isLoaded = {};
  Map<String, bool> isActive = {};
  Map<String, bool> isShown = {};
  Map<String, Map<String, dynamic>?> customizeData = {};
  Map<String, bool> isClosed = {};
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

      case AdropMethod.customizeAd:
        final requestId = call.arguments['requestId'];
        final data = call.arguments['data'];
        customizeData[requestId] =
            data != null ? Map<String, dynamic>.from(data as Map) : null;
        return null;

      case AdropMethod.closeAd:
        final requestId = call.arguments['requestId'];
        isClosed[requestId] = true;
        return null;

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
    customizeData.clear();
    isClosed.clear();
    isInitialized = false;
    handleEventMessage.clear();
    reset(popupAd);
  });

  group('load', () {
    test('load before initialized error', () async {
      await popupAd.load();
      expect(handleEventMessage[popupAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.initialize.name}');
    });

    test('load with invalid unitId error', () async {
      await Adrop.initialize(true);
      final nullPopupAd = MockAdropPopupAd(unitId: '', listener: listener);
      await nullPopupAd.load();
      expect(handleEventMessage[nullPopupAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.invalidUnit.name}');
      await nullPopupAd.dispose();
    });

    test('load with non-exist unitId error', () async {
      await Adrop.initialize(true);
      final nonExistPopupAd =
          MockAdropPopupAd(unitId: nonExistUnitId, listener: listener);
      await nonExistPopupAd.load();
      expect(handleEventMessage[nonExistPopupAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adNoFill.name}');
      await nonExistPopupAd.dispose();
    });

    test('load with inactive unitId error', () async {
      await Adrop.initialize(true);
      final inactivePopupAd =
          MockAdropPopupAd(unitId: inactiveUnitId, listener: listener);
      await inactivePopupAd.load();
      expect(handleEventMessage[inactivePopupAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.inactive.name}');
      await inactivePopupAd.dispose();
    });

    test('load popup ad success', () async {
      await Adrop.initialize(true);
      await popupAd.load();

      expect(popupAd.isLoaded, true);
      expect(handleEventMessage[popupAd], 'Ad Received');
    });

    test('load duplicate error', () async {
      await Adrop.initialize(true);
      await popupAd.load();
      await popupAd.load();
      expect(handleEventMessage[popupAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adLoadDuplicate.name}');
    });

    test('load while loading error', () async {
      await Adrop.initialize(true);
      popupAd.load();
      popupAd.load();
      expect(handleEventMessage[popupAd],
          'Ad Failed to Receive with err: ${AdropErrorCode.adLoading.name}');
    });
  });

  group('show', () {
    test('show while loading error', () async {
      await Adrop.initialize(true);
      popupAd.load();
      await popupAd.show();
      expect(handleEventMessage[popupAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adLoading.name}');
    });

    test('show after shown error', () async {
      await Adrop.initialize(true);
      await popupAd.load();
      await popupAd.show();
      await popupAd.show();
      expect(handleEventMessage[popupAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adShown.name}');
    });

    test('show not loaded ad error', () async {
      await Adrop.initialize(true);
      await popupAd.show();
      expect(handleEventMessage[popupAd],
          'Ad Failed to Show with err: ${AdropErrorCode.adEmpty.name}');
    });

    test('show popup ad', () async {
      await Adrop.initialize(true);
      await popupAd.load();
      popupAd.show();
      expect(handleEventMessage[popupAd], 'Ad Will Present');
      await Future.delayed(const Duration(seconds: 2));
      expect(handleEventMessage[popupAd], 'Ad Did Present');
    });
  });

  group('close', () {
    test('close invokes closeAd', () async {
      await Adrop.initialize(true);
      await popupAd.load();

      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(
              AdType.popup, popupAd.requestId);
      final adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      await adropEventObserverChannel
          ?.invokeMethod(AdropMethod.willDismissFullScreen);
      expect(handleEventMessage[popupAd], 'Ad Will Dismiss');
    });

    test('did dismiss', () async {
      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(
              AdType.popup, popupAd.requestId);
      final adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      await adropEventObserverChannel
          ?.invokeMethod(AdropMethod.didDismissFullScreen);
      expect(handleEventMessage[popupAd], 'Ad Did Dismiss');
    });
  });

  test('click ad', () async {
    final adropEventObserverChannelName =
        AdropChannel.adropEventListenerChannelOf(
            AdType.popup, popupAd.requestId);
    final adropEventObserverChannel = adropEventObserverChannelName != null
        ? MethodChannel(adropEventObserverChannelName)
        : null;
    await adropEventObserverChannel?.invokeMethod(AdropMethod.didClickAd);
    expect(handleEventMessage[popupAd], 'Ad Clicked');
  });

  test('impression', () async {
    final adropEventObserverChannelName =
        AdropChannel.adropEventListenerChannelOf(
            AdType.popup, popupAd.requestId);
    final adropEventObserverChannel = adropEventObserverChannelName != null
        ? MethodChannel(adropEventObserverChannelName)
        : null;
    await adropEventObserverChannel?.invokeMethod(AdropMethod.didImpression);
    expect(handleEventMessage[popupAd], 'Ad Impression');
  });

  test('creativeIds deprecated getter returns empty', () {
    // ignore: deprecated_member_use_from_same_package
    expect(AdropPopupAd(unitId: 'test').creativeIds, isEmpty);
  });
}
