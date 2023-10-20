import 'package:adrop_ads_flutter/adrop_error_code.dart';
import 'package:adrop_ads_flutter/banner/adrop_banner.dart';
import 'package:adrop_ads_flutter/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/bridge/adrop_method.dart';
import 'package:flutter/services.dart';

class AdropBannerController {
  final MethodChannel _channel;

  final AdropBanner _banner;
  final void Function(AdropBanner banner)? onAdReceived;
  final void Function(AdropBanner banner)? onAdClicked;
  final void Function(AdropBanner banner, AdropErrorCode code)? onAdFailedToReceive;

  AdropBannerController.withId(
    int id, {
    required AdropBanner banner,
    this.onAdReceived,
    this.onAdClicked,
    this.onAdFailedToReceive,
  })  : _banner = banner,
        _channel = MethodChannel(AdropChannel.methodBannerChannelOf(id)) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case AdropMethod.didReceiveAd:
          onAdReceived?.call(_banner);
          break;
        case AdropMethod.didClickAd:
          onAdClicked?.call(_banner);
          break;
        case AdropMethod.didFailToReceiveAd:
          onAdFailedToReceive?.call(_banner, AdropErrorCode.getByCode(call.arguments));
          break;
      }
    });
  }

  Future<void> load() async {
    return _channel.invokeMethod(AdropMethod.loadBanner);
  }
}
