import 'package:flutter/services.dart';

import 'bridge/adrop_channel.dart';
import 'bridge/adrop_method.dart';
import 'adrop_platform_interface.dart';

const _methodChannel = MethodChannel(AdropChannel.methodChannel);

class AdropMethodChannel extends AdropPlatform {
  @override
  Future<void> initialize(bool production) async {
    await _methodChannel.invokeMethod(AdropMethod.initialize, production);
  }
}
