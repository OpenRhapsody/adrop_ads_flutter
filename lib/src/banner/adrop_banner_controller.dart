import 'package:flutter/services.dart';

import '../adrop_error_code.dart';
import '../bridge/adrop_channel.dart';
import '../bridge/adrop_method.dart';
import 'adrop_banner.dart';

/// Banner controller class responsible for requesting banner ads.
class AdropBannerController {
  final MethodChannel _channel;

  final AdropBanner _banner;
  final void Function(AdropBanner banner)? onAdReceived;
  final void Function(AdropBanner banner)? onAdClicked;
  final void Function(AdropBanner banner, AdropErrorCode errorCode)? onAdFailedToReceive;

  /// Banner controller class responsible for requesting banner ads.
  ///
  /// [id]  required view id
  /// [onAdReceived] optional invoked when the banner receives an ad.
  /// [onAdClicked] optional invoked when the AdropBanner is clicked.
  /// [onAdFailedToReceive] optional invoked when the banner fails to receive an ad.
  AdropBannerController.withId(
    int id, {
    required AdropBanner banner,
    this.onAdReceived,
    this.onAdClicked,
    this.onAdFailedToReceive,
  })  : _banner = banner,
        _channel = MethodChannel(AdropChannel.bannerEventListenerChannelOf(id)) {
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

  /// Requests an ad from Adrop using the Ad unit ID of the AdropBanner.
  Future<void> load() async {
    return _channel.invokeMethod(AdropMethod.loadBanner);
  }
}
