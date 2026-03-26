import 'package:adrop_ads_flutter/src/adrop_method_channel.dart';
import 'package:adrop_ads_flutter/src/adrop_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdropAdsFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AdropPlatform {
  @override
  Future<void> initialize(bool production, List<String> targetCountries,
      bool useInAppBrowser) async {}

  @override
  Future<void> setUID(String uid) async {}

  @override
  Future<void> setTheme(String theme) async {}

  @override
  Future<void> registerWebView(int webViewIdentifier) async {}
}

void main() {
  final AdropPlatform initialPlatform = AdropPlatform.instance;

  test('$AdropMethodChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<AdropMethodChannel>());
  });

  test('initialize', () async {
    await MockAdropAdsFlutterPlatform().initialize(true, [], false);
  });

  test('setUID', () async {
    await MockAdropAdsFlutterPlatform().setUID('uid');
  });

  group('AdropMethodChannel.registerWebView', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    const channel = MethodChannel('io.adrop.adrop-ads');
    final List<MethodCall> calls = [];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        calls.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('calls MethodChannel with correct method name and arguments',
        () async {
      final methodChannel = AdropMethodChannel();
      await methodChannel.registerWebView(42);

      expect(calls, hasLength(1));
      expect(calls.first.method, 'registerWebView');
      expect(calls.first.arguments, {'webViewId': 42});
    });

    test('passes different webViewIdentifier values correctly', () async {
      final methodChannel = AdropMethodChannel();
      await methodChannel.registerWebView(0);

      expect(calls, hasLength(1));
      expect(calls.first.method, 'registerWebView');
      expect(calls.first.arguments, {'webViewId': 0});
    });
  });
}
