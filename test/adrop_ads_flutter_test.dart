import 'package:adrop_ads_flutter/adrop_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdropAdsFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AdropPlatform {

  @override
  Future<void> initialize(bool production) {
    throw UnimplementedError();
  }
}

void main() {

}
