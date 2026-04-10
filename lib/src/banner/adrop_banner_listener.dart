import 'package:adrop_ads_flutter/src/banner/adrop_banner_view.dart';

import '../adrop_error_code.dart';

typedef AdropAdEventCallback = void Function(
    String unitId, Map<String, dynamic>? metadata);
typedef AdropAdFailedCallback = void Function(
    String unitId, AdropErrorCode errorCode);

typedef AdropBannerVideoCallback = void Function(String unitId);

/// Listener called when there is a change in the [AdropBannerView].
///
/// [onAdReceived] Gets invoked when the banner receives an ad.
/// [onAdClicked] Gets invoked when the banner is clicked.
/// [onAdImpression] Gets invoked when the banner is impressed.
/// [onAdFailedToReceive] Gets invoked with [AdropErrorCode] when the banner fails to receive an ad.
/// [onAdVideoStart] Gets invoked when the banner video starts playing.
/// [onAdVideoEnd] Gets invoked when the banner video ends playing.
class AdropBannerListener {
  final AdropAdEventCallback? onAdReceived;
  final AdropAdEventCallback? onAdClicked;
  final AdropAdEventCallback? onAdImpression;
  final AdropAdFailedCallback? onAdFailedToReceive;
  final AdropBannerVideoCallback? onAdVideoStart;
  final AdropBannerVideoCallback? onAdVideoEnd;

  const AdropBannerListener(
      {this.onAdReceived,
      this.onAdFailedToReceive,
      this.onAdClicked,
      this.onAdImpression,
      this.onAdVideoStart,
      this.onAdVideoEnd});
}
