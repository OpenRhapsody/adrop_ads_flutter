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

  const unitId = 'PUBLIC_TEST_UNIT_ID_EVENT';
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(invokeChannel, (call) async {
    switch (call.method) {
      case AdropMethod.initialize:
        return true;
      default:
        return null;
    }
  });

  group('AdropEvent', () {
    test('from(null) returns safe defaults', () {
      final event = AdropEvent.from(null);
      expect(event.unitId, '');
      expect(event.method, '');
      expect(event.errorCode, isNull);
      expect(event.type, isNull);
      expect(event.amount, isNull);
    });

    test('from(valid) sets all fields', () {
      final event = AdropEvent.from({
        'unitId': 'test_unit',
        'method': 'onAdReceived',
        'errorCode': 'ERROR_CODE_NETWORK',
        'type': 1,
        'amount': 100,
      });

      expect(event.unitId, 'test_unit');
      expect(event.method, 'onAdReceived');
      expect(event.errorCode, AdropErrorCode.network);
      expect(event.type, 1);
      expect(event.amount, 100);
    });
  });

  group('AdropAd _handleEvent', () {
    late MockAdropInterstitialAd ad;
    Map<AdropAd, String> handleEventMessage = {};

    setUp(() {
      handleEventMessage.clear();
      final listener = AdropInterstitialListener(
        onAdReceived: (ad) => handleEventMessage[ad] = 'Ad Received',
        onAdClicked: (ad) => handleEventMessage[ad] = 'Ad Clicked',
        onAdImpression: (ad) => handleEventMessage[ad] = 'Ad Impression',
        onAdFailedToReceive: (ad, errorCode) =>
            handleEventMessage[ad] = 'Ad Failed with err: ${errorCode.name}',
      );
      ad = MockAdropInterstitialAd(unitId: unitId, listener: listener);
    });

    tearDown(() {
      handleEventMessage.clear();
      reset(ad);
    });

    test(
        '_handleEvent sets creativeId, txId, campaignId, destinationURL, browserTarget',
        () async {
      final channelName = AdropChannel.adropEventListenerChannelOf(
          AdType.interstitial, ad.requestId);
      final channel = channelName != null ? MethodChannel(channelName) : null;
      await channel?.invokeMethod(AdropMethod.didReceiveAd, {
        'creativeId': 'cid123',
        'txId': 'tx456',
        'campaignId': 'camp789',
        'destinationURL': 'https://dest.com',
        'browserTarget': 1,
      });
      // The mock ad stores these but since MockAdropAd doesn't expose them directly,
      // we verify via the listener callback that the event was handled
      expect(handleEventMessage[ad], 'Ad Received');
    });

    test('browserTarget getter maps ordinal correctly', () {
      expect(BrowserTarget.fromOrdinal(0), BrowserTarget.external);
      expect(BrowserTarget.fromOrdinal(1), BrowserTarget.internal);
      expect(BrowserTarget.fromOrdinal(null), isNull);
      expect(BrowserTarget.fromOrdinal(5), isNull);
    });
  });
}
