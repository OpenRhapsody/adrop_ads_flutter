import 'package:adrop_ads_flutter/src/adrop_error_code.dart';

import 'adrop_native_ad.dart';

typedef AdropNativeAdCallback = void Function(AdropNativeAd ad);
typedef AdropNativeAdErrorCallback = void Function(
    AdropNativeAd ad, AdropErrorCode errorCode);

/// Listener called when there is a change in the [AdropNativeAd].
///
/// [onAdReceived] Gets invoked when the native ad receives an ad.
/// [onAdClicked] Gets invoked when the native ad is clicked.
/// [onAdFailedToReceive] Gets invoked with [AdropErrorCode] when the native ad fails to receive an ad.
class AdropNativeListener {
  final AdropNativeAdCallback? onAdReceived;
  final AdropNativeAdCallback? onAdClicked;
  final AdropNativeAdCallback? onAdImpression;
  final AdropNativeAdErrorCallback? onAdFailedToReceive;

  AdropNativeListener({
    this.onAdReceived,
    this.onAdClicked,
    this.onAdImpression,
    this.onAdFailedToReceive,
  });
}
