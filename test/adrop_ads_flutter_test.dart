import 'package:adrop_ads_flutter/adrop_platform_interface.dart';
import 'package:adrop_ads_flutter/adrop_method_channel.dart';
import 'package:adrop_ads_flutter/adrop.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdropAdsFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AdropPlatform {

  @override
  Future<void> initialize(bool production) async {
    
  }
}

void main() {

  final AdropPlatform initialPlatform = AdropPlatform.instance;

  test('$AdropMethodChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<AdropMethodChannel>());
  });

  test('initialize', () async {
    await MockAdropAdsFlutterPlatform().initialize(true);
  }); 
}
