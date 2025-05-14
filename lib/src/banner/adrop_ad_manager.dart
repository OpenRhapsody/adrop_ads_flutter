import 'package:flutter/services.dart';
import '../adrop_error_code.dart';
import '../banner/adrop_banner_view.dart';
import '../bridge/adrop_channel.dart';
import '../bridge/adrop_method.dart';

final AdropAdManager adropAdManager =
    AdropAdManager(AdropChannel.invokeChannel);

class AdropAdManager {
  final MethodChannel _invokeChannel;
  final Map<String, AdropBannerView> _loadedAds = <String, AdropBannerView>{};

  AdropAdManager(String channelName)
      : _invokeChannel = MethodChannel(channelName) {
    _invokeChannel.setMethodCallHandler((call) async {
      var args = call.arguments;
      var unitId = args["unitId"] ?? "";
      var creativeId = args["creativeId"] ?? "";
      var requestId = args["requestId"] ?? "";
      var key = "${unitId}_$requestId";

      switch (call.method) {
        case AdropMethod.didReceiveAd:
          _loadedAds[key]?.listener?.onAdReceived?.call(unitId, creativeId);
          break;
        case AdropMethod.didClickAd:
          _loadedAds[key]?.listener?.onAdClicked?.call(unitId, creativeId);
          break;
        case AdropMethod.didFailToReceiveAd:
          _loadedAds[key]
              ?.listener
              ?.onAdFailedToReceive
              ?.call(unitId, AdropErrorCode.getByCode(args["error"]));
          break;
      }
    });
  }

  Future<void> load(AdropBannerView banner, String requestId) async {
    _loadedAds["${banner.unitId}_$requestId"] = banner;
    return await _invokeChannel.invokeMethod(
        AdropMethod.loadBanner, { 'unitId': banner.unitId, 'requestId': requestId });
  }

  Future<void> dispose(AdropBannerView banner, String requestId) async {
    _loadedAds.remove("${banner.unitId}_$requestId");
    return await _invokeChannel.invokeMethod(
        AdropMethod.disposeBanner, { 'unitId': banner.unitId, 'requestId': requestId });
  }
}
