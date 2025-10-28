import 'package:adrop_ads_flutter/src/banner/adrop_banner_view.dart';

import '../adrop_error_code.dart';

typedef AdropAdEventCallback = void Function(
    String unitId, Map<String, dynamic>? metadata);
typedef AdropAdFailedCallback = void Function(
    String unitId, AdropErrorCode errorCode);

/// Listener called when there is a change in the [AdropBannerView].
///
/// [onAdReceived] Gets invoked when the banner receives an ad.
/// [onAdClicked] Gets invoked when the banner is clicked.
/// [onAdImpression] Gets invoked when the banner is impressed.
/// [onAdFailedToReceive] Gets invoked with [AdropErrorCode] when the banner fails to receive an ad.
class AdropBannerListener {
  final AdropAdEventCallback? onAdReceived;
  final AdropAdEventCallback? onAdClicked;
  final AdropAdEventCallback? onAdImpression;
  final AdropAdFailedCallback? onAdFailedToReceive;

  const AdropBannerListener(
      {this.onAdReceived,
      this.onAdFailedToReceive,
      this.onAdClicked,
      this.onAdImpression});
}
