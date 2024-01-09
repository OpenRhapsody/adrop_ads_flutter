import 'package:flutter/services.dart';

import 'adrop_platform_interface.dart';
import 'bridge/adrop_channel.dart';
import 'bridge/adrop_method.dart';

const _methodChannel = MethodChannel(AdropChannel.invokeChannel);

class AdropMethodChannel extends AdropPlatform {
  @override
  Future<void> initialize(bool production) async {
    await _methodChannel.invokeMethod(AdropMethod.initialize, production);
  }
}
