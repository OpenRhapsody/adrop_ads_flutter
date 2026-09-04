import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unitId = 'PUBLIC_TEST_UNIT_ID_BANNER';
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Map<String, Object?> metadataFor(String requestId,
      {double width = 375, double height = 80}) {
    return {
      'unitId': unitId,
      'creativeId': 'creative_$requestId',
      'requestId': requestId,
      'txId': 'tx_$requestId',
      'campaignId': 'campaign_$requestId',
      'destinationURL': 'https://example.com/$requestId',
      'creativeSizeWidth': width,
      'creativeSizeHeight': height,
      'browserTarget': 0,
      'creativeType': 'display',
    };
  }

  /// Simulates a native -> Dart event on the shared invoke channel
  /// (the direction AdropAdManager listens on).
  Future<void> emitBannerEvent(String method, Map<String, Object?> args) async {
    await messenger.handlePlatformMessage(
      AdropChannel.invokeChannel,
      const StandardMethodCodec().encodeMethodCall(MethodCall(method, args)),
      (_) {},
    );
  }

  tearDown(() {
    messenger.setMockMethodCallHandler(invokeChannel, null);
  });

  test('loads sends unitId and 5 distinct pre-minted requestIds', () async {
    List<Object?>? sentRequestIds;
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      expect(call.method, AdropMethod.loadsBanner);
      expect(call.arguments['unitId'], unitId);
      sentRequestIds = List<Object?>.from(call.arguments['requestIds']);
      return {'requestIds': <String>[], 'ads': <Map<Object?, Object?>>[]};
    });

    final views = await AdropBannerView.loads(unitId: unitId);
    expect(views, isEmpty);
    expect(sentRequestIds, isNotNull);
    expect(sentRequestIds, hasLength(5));
    expect(sentRequestIds!.toSet(), hasLength(5));
  });

  test('loads resolves widgets bound to filled requestIds with creativeSize',
      () async {
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      final ids = List<String>.from(call.arguments['requestIds']);
      final filled = ids.sublist(0, 3);
      return {
        'requestIds': filled,
        'ads': filled.map(metadataFor).toList(),
      };
    });

    final views = await AdropBannerView.loads(unitId: unitId);
    expect(views, hasLength(3));
    expect(views.map((v) => v.requestId).toSet(), hasLength(3));
    for (final view in views) {
      expect(view.unitId, unitId);
      expect(view.creativeSize?.width, 375);
      expect(view.creativeSize?.height, 80);
    }
  });

  test('loads throws PlatformException carrying the AdropErrorCode name',
      () async {
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      throw PlatformException(code: 'ERROR_CODE_AD_NO_FILL');
    });

    await expectLater(
      AdropBannerView.loads(unitId: unitId),
      throwsA(isA<PlatformException>()
          .having((e) => e.code, 'code', 'ERROR_CODE_AD_NO_FILL')),
    );
  });

  test('loads itself fires no listener callbacks (no onAdReceived re-fire)',
      () async {
    final received = <String>[];
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      final ids = List<String>.from(call.arguments['requestIds']);
      final filled = ids.sublist(0, 2);
      return {'requestIds': filled, 'ads': filled.map(metadataFor).toList()};
    });

    await AdropBannerView.loads(
      unitId: unitId,
      listener: AdropBannerListener(
        onAdReceived: (unitId, metadata) => received.add('received'),
        onAdClicked: (unitId, metadata) => received.add('clicked'),
        onAdImpression: (unitId, metadata) => received.add('impression'),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(received, isEmpty);
  });

  test('events route to the shared listener with per-slot requestId metadata',
      () async {
    final clicked = <String>[];
    final impressed = <String>[];
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      final ids = List<String>.from(call.arguments['requestIds']);
      final filled = ids.sublist(0, 3);
      return {'requestIds': filled, 'ads': filled.map(metadataFor).toList()};
    });

    final views = await AdropBannerView.loads(
      unitId: unitId,
      listener: AdropBannerListener(
        onAdClicked: (unitId, metadata) =>
            clicked.add(metadata?['requestId'] as String? ?? ''),
        onAdImpression: (unitId, metadata) =>
            impressed.add(metadata?['requestId'] as String? ?? ''),
      ),
    );

    final target = views[1].requestId;
    await emitBannerEvent(AdropMethod.didClickAd, metadataFor(target));
    await emitBannerEvent(
        AdropMethod.didImpression, metadataFor(views[2].requestId));

    expect(clicked, [target]);
    expect(impressed, [views[2].requestId]);
  });

  test('dispose unregisters the slot and stops event delivery', () async {
    final clicked = <String>[];
    final disposed = <String>[];
    messenger.setMockMethodCallHandler(invokeChannel, (call) async {
      if (call.method == AdropMethod.disposeBanner) {
        disposed.add(call.arguments['requestId'] as String);
        return null;
      }
      final ids = List<String>.from(call.arguments['requestIds']);
      final filled = ids.sublist(0, 2);
      return {'requestIds': filled, 'ads': filled.map(metadataFor).toList()};
    });

    final views = await AdropBannerView.loads(
      unitId: unitId,
      listener: AdropBannerListener(
        onAdClicked: (unitId, metadata) =>
            clicked.add(metadata?['requestId'] as String? ?? ''),
      ),
    );

    await views[0].dispose();
    expect(disposed, [views[0].requestId]);

    await emitBannerEvent(
        AdropMethod.didClickAd, metadataFor(views[0].requestId));
    expect(clicked, isEmpty);

    // The other slot keeps working after a sibling is disposed.
    await emitBannerEvent(
        AdropMethod.didClickAd, metadataFor(views[1].requestId));
    expect(clicked, [views[1].requestId]);
  });
}
