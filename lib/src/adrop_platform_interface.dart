import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adrop_method_channel.dart';

abstract class AdropPlatform extends PlatformInterface {
  AdropPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdropPlatform _instance = AdropMethodChannel();

  static AdropPlatform get instance => _instance;

  static set instance(AdropPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize(bool production) async {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> loadBanner(String unitId) async {
    throw UnimplementedError('loadBanner(String unitId) has not been implemented.');
  }
}
