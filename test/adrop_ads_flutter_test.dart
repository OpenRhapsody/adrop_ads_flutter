import 'package:flutter_test/flutter_test.dart';
import 'package:adrop_ads_flutter/adrop_ads_flutter_platform_interface.dart';
import 'package:adrop_ads_flutter/adrop_ads_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdropAdsFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AdropAdsFlutterPlatform {

  @override
  Future<void> initialize(bool production) {
    throw UnimplementedError();
  }
}

void main() {
  final AdropAdsFlutterPlatform initialPlatform = AdropAdsFlutterPlatform.instance;

  test('$MethodChannelAdropAdsFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdropAdsFlutter>());
  });

  test('getPlatformVersion', () async {

    MockAdropAdsFlutterPlatform fakePlatform = MockAdropAdsFlutterPlatform();
    AdropAdsFlutterPlatform.instance = fakePlatform;
  });
}
