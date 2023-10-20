import 'package:adrop_ads_flutter/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/bridge/adrop_method.dart';
import 'package:flutter/services.dart';

import 'adrop_platform_interface.dart';

const _methodChannel = MethodChannel(AdropChannel.methodChannel);

class AdropMethodChannel extends AdropPlatform {
  @override
  Future<void> initialize(bool production) async {
    await _methodChannel.invokeMethod(AdropMethod.initialize);
  }
}
