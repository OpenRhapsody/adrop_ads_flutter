import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unitId = 'PUBLIC_TEST_UNIT_ID_NATIVE';
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Map<String, Object?> metadataFor(String requestId) {
    return {
      'creativeId': 'creative_$requestId',
      'headline': 'Headline $requestId',
      'body': 'Body $requestId',
      'displayLogo': 'https://example.com/logo.png',
      'displayName': 'Advertiser',
      'extra': '{"key":"value"}',
      'asset': 'https://example.com/asset.png',
      'destinationURL': 'https://example.com/$requestId',
      'creative': 'https://example.com/creative.html',
      'creativeSizeWidth': 320.0,
      'creativeSizeHeight': 240.0,
      'txId': 'tx_$requestId',
      'campaignId': 'campaign_$requestId',
      'isBackfilled': false,
      'callToAction': 'Install',
      'browserTarget': 0,
      'creativeType': 'display',
    };
  }

  tearDown(() {
    messenger.setMockMethodCallHandler(invokeChannel, null);
  });

  test('loads sends unitId, 5 distinct requestIds and useCustomClick',
      () async {
    Map<Object?, Object?>? sentArgs;
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      expect(call.method, AdropMethod.loadsNative);
      sentArgs = Map<Object?, Object?>.from(call.arguments);
      return {'requestIds': <String>[], 'ads': <Map<Object?, Object?>>[]};
    });

    final ads = await AdropNativeAd.loads(unitId: unitId, useCustomClick: true);
    expect(ads, isEmpty);
    expect(sentArgs?['unitId'], unitId);
    expect(sentArgs?['useCustomClick'], true);
    final ids = List<Object?>.from(sentArgs?['requestIds'] as List);
    expect(ids, hasLength(5));
    expect(ids.toSet(), hasLength(5));
  });

  test('loads resolves fully-hydrated instances (no didReceiveAd needed)',
      () async {
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      final ids = List<String>.from(call.arguments['requestIds']);
      final filled = ids.sublist(0, 3);
      return {'requestIds': filled, 'ads': filled.map(metadataFor).toList()};
    });

    final ads = await AdropNativeAd.loads(unitId: unitId);
    expect(ads, hasLength(3));
    for (final ad in ads) {
      expect(ad.isLoaded, isTrue);
      expect(ad.unitId, unitId);
      expect(ad.creativeId, 'creative_${ad.requestId}');
      expect(ad.txId, 'tx_${ad.requestId}');
      expect(ad.campaignId, 'campaign_${ad.requestId}');
      expect(ad.properties.headline, 'Headline ${ad.requestId}');
      expect(ad.properties.body, 'Body ${ad.requestId}');
      expect(ad.properties.extra['key'], 'value');
      expect(ad.isBackfilled, isFalse);
      expect(ad.creativeSize.width, 320.0);
      expect(ad.creativeSize.height, 240.0);
    }
    expect(ads.map((a) => a.requestId).toSet(), hasLength(3));
  });

  test('loads throws PlatformException carrying the AdropErrorCode name',
      () async {
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      throw PlatformException(code: 'ERROR_CODE_AD_NO_FILL');
    });

    await expectLater(
      AdropNativeAd.loads(unitId: unitId),
      throwsA(isA<PlatformException>()
          .having((e) => e.code, 'code', 'ERROR_CODE_AD_NO_FILL')),
    );
  });

  test('loads itself fires no listener callbacks (no onAdReceived re-fire)',
      () async {
    final events = <String>[];
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      final ids = List<String>.from(call.arguments['requestIds']);
      final filled = ids.sublist(0, 2);
      return {'requestIds': filled, 'ads': filled.map(metadataFor).toList()};
    });

    await AdropNativeAd.loads(
      unitId: unitId,
      listener: AdropNativeListener(
        onAdReceived: (ad) => events.add('received'),
        onAdClicked: (ad) => events.add('clicked'),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
  });

  test('per-instance events route to the right batch instance', () async {
    final clicked = <AdropNativeAd>[];
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      final ids = List<String>.from(call.arguments['requestIds']);
      final filled = ids.sublist(0, 3);
      return {'requestIds': filled, 'ads': filled.map(metadataFor).toList()};
    });

    final ads = await AdropNativeAd.loads(
      unitId: unitId,
      listener: AdropNativeListener(
        onAdClicked: (ad) => clicked.add(ad),
      ),
    );

    final target = ads[1];
    final channelName = AdropChannel.adropEventListenerChannelOf(
        AdType.native, target.requestId)!;
    await messenger.handlePlatformMessage(
      channelName,
      const StandardMethodCodec().encodeMethodCall(
          MethodCall(AdropMethod.didClickAd, metadataFor(target.requestId))),
      (_) {},
    );

    expect(clicked, hasLength(1));
    expect(identical(clicked.single, target), isTrue);
  });

  test('dispose invokes disposeAd with the batch requestId', () async {
    final disposed = <String>[];
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      if (call.method == AdropMethod.disposeAd) {
        disposed.add(call.arguments['requestId'] as String);
        return null;
      }
      final ids = List<String>.from(call.arguments['requestIds']);
      final filled = ids.sublist(0, 1);
      return {'requestIds': filled, 'ads': filled.map(metadataFor).toList()};
    });

    final ads = await AdropNativeAd.loads(unitId: unitId);
    await ads.single.dispose();
    expect(disposed, [ads.single.requestId]);
  });
}
