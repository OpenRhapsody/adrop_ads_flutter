import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adrop_ads_flutter_platform_interface.dart';

/// An implementation of [AdropAdsFlutterPlatform] that uses method channels.
class MethodChannelAdropAdsFlutter extends AdropAdsFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adrop_ads_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
