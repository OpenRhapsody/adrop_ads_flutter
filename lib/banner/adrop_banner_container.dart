import 'package:adrop_ads_flutter/adrop_error_code.dart';
import 'package:adrop_ads_flutter/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/bridge/adrop_method.dart';
import 'package:flutter/services.dart';

class AdropBannerController {
  final MethodChannel _channel;

  final VoidCallback? onAdReceived;
  final VoidCallback? onAdClicked;
  final Function(AdropErrorCode code)? onAdFailedToReceive;

  AdropBannerController.withId(
    int id, {
    this.onAdReceived,
    this.onAdClicked,
    this.onAdFailedToReceive,
  }) : _channel = MethodChannel(AdropChannel.methodBannerChannelOf(id)) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case AdropMethod.didReceiveAd:
          onAdReceived?.call();
          break;
        case AdropMethod.didClickAd:
          onAdClicked?.call();
          break;
        case AdropMethod.didFailToReceiveAd:
          onAdFailedToReceive?.call(AdropErrorCode.getByCode(call.arguments));
          break;
      }
    });
  }

  Future<void> load() async {
    return _channel.invokeMethod(AdropMethod.loadBanner);
  }
}
