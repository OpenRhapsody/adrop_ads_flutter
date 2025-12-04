import 'package:flutter/services.dart';
import '../adrop_error_code.dart';
import '../banner/adrop_banner_view.dart';
import '../bridge/adrop_channel.dart';
import '../bridge/adrop_method.dart';
import '../model/creative_size.dart';

final AdropAdManager adropAdManager =
    AdropAdManager(AdropChannel.invokeChannel);

class AdropAdManager {
  final MethodChannel _invokeChannel;
  final Map<String, AdropBannerView> _loadedAds = <String, AdropBannerView>{};
  final Map<String, CreativeSize> _creativeSizes = <String, CreativeSize>{};

  AdropAdManager(String channelName)
      : _invokeChannel = MethodChannel(channelName) {
    _invokeChannel.setMethodCallHandler((call) async {
      var args = call.arguments;
      var unitId = args["unitId"] ?? "";
      var creativeId = args["creativeId"] ?? "";
      var requestId = args["requestId"] ?? "";
      var txId = args["txId"] ?? "";
      var campaignId = args["campaignId"] ?? "";
      var destinationURL = args["destinationURL"] ?? "";
      var key = "${unitId}_$requestId";

      if (args['creativeSizeWidth'] != null &&
          args['creativeSizeHeight'] != null) {
        _creativeSizes[key] = CreativeSize(
          width: args['creativeSizeWidth'],
          height: args['creativeSizeHeight'],
        );
      }

      var metadata = {
        'creativeId': creativeId,
        'txId': txId,
        'campaignId': campaignId,
        'destinationURL': destinationURL,
      };

      switch (call.method) {
        case AdropMethod.didReceiveAd:
          _loadedAds[key]?.listener?.onAdReceived?.call(unitId, metadata);
          break;
        case AdropMethod.didClickAd:
          _loadedAds[key]?.listener?.onAdClicked?.call(unitId, metadata);
          break;
        case AdropMethod.didImpression:
          _loadedAds[key]?.listener?.onAdImpression?.call(unitId, metadata);
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
    return await _invokeChannel.invokeMethod(AdropMethod.loadBanner, {
      'unitId': banner.unitId,
      'requestId': requestId,
      'width': banner.adSize?.width,
      'height': banner.adSize?.height,
    });
  }

  Future<void> dispose(AdropBannerView banner, String requestId) async {
    _loadedAds.remove("${banner.unitId}_$requestId");
    return await _invokeChannel.invokeMethod(AdropMethod.disposeBanner,
        {'unitId': banner.unitId, 'requestId': requestId});
  }

  CreativeSize? getCreativeSize(AdropBannerView banner, String requestId) {
    return _creativeSizes["${banner.unitId}_$requestId"];
  }
}
