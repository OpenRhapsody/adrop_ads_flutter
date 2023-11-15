import '../banner/adrop_banner_view.dart';
import '../adrop_platform_interface.dart';
import '../bridge/adrop_channel.dart';
import '../bridge/adrop_method.dart';
import 'package:flutter/services.dart';

AdropAdManager bannerManager = AdropAdManager(AdropChannel.methodChannel);

class AdropAdManager {
  final MethodChannel channel;
  final Map<String, AdropBannerView> _loadedAds = <String, AdropBannerView>{};

  AdropAdManager(String channelName) : channel = MethodChannel(channelName) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case AdropMethod.didReceiveAd:
          var unitId = call.arguments ?? "";
          _loadedAds[unitId]?.listener?.onAdReceived?.call(unitId);
          break;
        case AdropMethod.didClickAd:
          var unitId = call.arguments ?? "";
          _loadedAds[unitId]?.listener?.onAdClicked?.call(unitId);
          break;
        case AdropMethod.didFailToReceiveAd:
          var args = call.arguments;
          var unitId = args["unitId"];
          _loadedAds[unitId]?.listener?.onAdFailedToReceive?.call(unitId, args["error"]);
          break;
      }
    });
  }

  Future<void> load(AdropBannerView banner) async {
    _loadedAds[banner.unitId] = banner;
    return await AdropPlatform.instance.loadBanner(banner.unitId);
  }
}
