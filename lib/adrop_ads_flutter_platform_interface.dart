import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adrop_ads_flutter_method_channel.dart';

abstract class AdropAdsFlutterPlatform extends PlatformInterface {
  /// Constructs a AdropAdsFlutterPlatform.
  AdropAdsFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdropAdsFlutterPlatform _instance = MethodChannelAdropAdsFlutter();

  /// The default instance of [AdropAdsFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdropAdsFlutter].
  static AdropAdsFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdropAdsFlutterPlatform] when
  /// they register themselves.
  static set instance(AdropAdsFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize(bool production) async {
    throw UnimplementedError('initialize() has not been implemented.');
  }
}
