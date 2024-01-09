import 'package:flutter/services.dart';
import '../adrop_error_code.dart';
import '../banner/adrop_banner_view.dart';
import '../bridge/adrop_channel.dart';
import '../bridge/adrop_method.dart';

final AdropAdManager adropAdManager = AdropAdManager(AdropChannel.invokeChannel);

class AdropAdManager {
  final MethodChannel _invokeChannel;
  final Map<String, AdropBannerView> _loadedAds = <String, AdropBannerView>{};

  AdropAdManager(String channelName) : _invokeChannel = MethodChannel(channelName) {
    _invokeChannel.setMethodCallHandler((call) async {
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
          _loadedAds[unitId]?.listener?.onAdFailedToReceive?.call(unitId, AdropErrorCode.getByCode(args["error"]));
          break;
      }
    });
  }

  Future<void> load(AdropBannerView banner) async {
    _loadedAds[banner.unitId] = banner;
    return await _invokeChannel.invokeMethod(AdropMethod.loadBanner, banner.unitId);
  }

  Future<void> dispose(AdropBannerView banner) async {
    _loadedAds.remove(banner.unitId);
    return await _invokeChannel.invokeMethod(AdropMethod.disposeBanner, banner.unitId);
  }
}
