import 'package:adrop_ads_flutter/src/adrop_method_channel.dart';
import 'package:adrop_ads_flutter/src/adrop_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdropAdsFlutterPlatform with MockPlatformInterfaceMixin implements AdropPlatform {
  @override
  Future<void> initialize(bool production, List<String> targetCountries) async {}
}

void main() {
  final AdropPlatform initialPlatform = AdropPlatform.instance;

  test('$AdropMethodChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<AdropMethodChannel>());
  });

  test('initialize', () async {
    await MockAdropAdsFlutterPlatform().initialize(true, []);
  });
}
