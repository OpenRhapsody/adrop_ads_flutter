import 'package:adrop_ads_flutter/src/adrop_error_code.dart';

import 'adrop_native_ad.dart';
import 'package:adrop_ads_flutter/src/model/adrop_ad_value.dart';

typedef AdropNativeAdCallback = void Function(AdropNativeAd ad);
typedef AdropNativeAdErrorCallback = void Function(
    AdropNativeAd ad, AdropErrorCode errorCode);

typedef AdropNativeVideoCallback = void Function(AdropNativeAd ad);
typedef AdropNativePaidEventCallback = void Function(
    AdropNativeAd ad, AdropAdValue value);

/// Listener called when there is a change in the [AdropNativeAd].
///
/// [onAdReceived] Gets invoked when the native ad receives an ad.
/// [onAdClicked] Gets invoked when the native ad is clicked.
/// [onAdFailedToReceive] Gets invoked with [AdropErrorCode] when the native ad fails to receive an ad.
/// [onAdVideoStart] Gets invoked when the native ad video starts playing.
/// [onAdVideoEnd] Gets invoked when the native ad video ends playing.
class AdropNativeListener {
  final AdropNativeAdCallback? onAdReceived;
  final AdropNativeAdCallback? onAdClicked;
  final AdropNativeAdCallback? onAdImpression;
  final AdropNativeAdErrorCallback? onAdFailedToReceive;
  final AdropNativeVideoCallback? onAdVideoStart;
  final AdropNativeVideoCallback? onAdVideoEnd;
  final AdropNativePaidEventCallback? onPaidEvent;

  AdropNativeListener({
    this.onAdReceived,
    this.onAdClicked,
    this.onAdImpression,
    this.onAdFailedToReceive,
    this.onAdVideoStart,
    this.onAdVideoEnd,
    this.onPaidEvent,
  });
}
