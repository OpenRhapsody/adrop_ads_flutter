import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adrop_ads_flutter/adrop_ads_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAdropAdsFlutter platform = MethodChannelAdropAdsFlutter();
  const MethodChannel channel = MethodChannel('adrop_ads_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    // expect(await platform.getPlatformVersion(), '42');
  });
}
