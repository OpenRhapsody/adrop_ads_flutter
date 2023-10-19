import 'package:adrop_ads_flutter/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/bridge/adrop_method.dart';
import 'package:flutter/services.dart';

import 'adrop_ads_flutter_platform_interface.dart';

const _methodChannel = MethodChannel(AdropChannel.methodChannel);

/// An implementation of [AdropAdsFlutterPlatform] that uses method channels.
class MethodChannelAdropAdsFlutter extends AdropAdsFlutterPlatform {
  @override
  Future<void> initialize(bool production) async {
    await _methodChannel.invokeMethod(AdropMethod.initialize);
  }
}
