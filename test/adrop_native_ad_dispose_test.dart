import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for [AdropNativeAd.dispose] — the real class (not the mock), covering
/// the memory-leak fix: dispose forwards to the native `disposeAd` channel,
/// releases the event handler, is safe on listener-less instances, and blocks
/// reuse after dispose.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const unitId = 'PUBLIC_TEST_UNIT_ID_NATIVE';
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  const codec = StandardMethodCodec();

  String? capturedMethod;
  Map<dynamic, dynamic>? capturedArgs;

  setUp(() {
    capturedMethod = null;
    capturedArgs = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(invokeChannel, (call) async {
      capturedMethod = call.method;
      capturedArgs = call.arguments as Map<dynamic, dynamic>?;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(invokeChannel, null);
  });

  // Simulates a native -> Dart event arriving on the ad's per-instance channel,
  // routed to the handler registered via setMethodCallHandler.
  Future<void> deliverEvent(
      String requestId, String method, Map<String, dynamic> args) async {
    final channelName =
        AdropChannel.adropEventListenerChannelOf(AdType.native, requestId);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      channelName!,
      codec.encodeMethodCall(MethodCall(method, args)),
      (_) {},
    );
  }

  test('dispose forwards disposeAd with adType and requestId', () async {
    final ad = AdropNativeAd(unitId: unitId);
    await ad.dispose();

    expect(capturedMethod, AdropMethod.disposeAd);
    expect(capturedArgs?['adType'], AdType.native.index);
    expect(capturedArgs?['requestId'], ad.requestId);
  });

  test('dispose on a listener-less instance does not throw', () async {
    final ad = AdropNativeAd(unitId: unitId);
    await expectLater(ad.dispose(), completes);
  });

  test('events are ignored after dispose (handler released)', () async {
    var clicked = false;
    final ad = AdropNativeAd(
      unitId: unitId,
      listener: AdropNativeListener(onAdClicked: (_) => clicked = true),
    );

    // Sanity: event fires before dispose.
    await deliverEvent(ad.requestId, AdropMethod.didClickAd, {});
    expect(clicked, isTrue);

    clicked = false;
    await ad.dispose();

    // After dispose the handler is unregistered — no callback.
    await deliverEvent(ad.requestId, AdropMethod.didClickAd, {});
    expect(clicked, isFalse);
  });

  test('load after dispose is blocked and sends no loadAd', () async {
    final ad = AdropNativeAd(unitId: unitId);
    await ad.dispose();
    capturedMethod = null;

    // Debug builds trip the assert; release builds early-return. Either way,
    // no loadAd reaches the native side.
    await expectLater(ad.load(), throwsA(isA<AssertionError>()));
    expect(capturedMethod, isNull);
  });

  test('double dispose is safe and idempotent', () async {
    final ad = AdropNativeAd(unitId: unitId);
    await ad.dispose();
    capturedMethod = null;

    await expectLater(ad.dispose(), completes);
    // Second dispose short-circuits before re-invoking the channel.
    expect(capturedMethod, isNull);
  });
}
