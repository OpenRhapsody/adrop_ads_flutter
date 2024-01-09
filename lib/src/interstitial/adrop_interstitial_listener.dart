import 'package:adrop_ads_flutter/src/interstitial/adrop_interstitial_ad.dart';

import '../adrop_ad.dart';
import '../adrop_error_code.dart';

typedef AdropAdCallback = void Function(AdropAd ad);
typedef AdropAdErrorCallback = void Function(AdropAd ad, AdropErrorCode errorCode);

/// A listener called when load or show is called in the [AdropInterstitialAd].
///
/// [onAdReceived] Gets invoked when the interstitial ad is received.
/// [onAdClicked] Gets invoked when the interstitial ad is clicked.
/// [onAdImpression] Gets invoked when the interstitial ad is shown.
/// [onAdWillPresentFullScreen] Gets invoked when the interstitial ad is about to appear. (iOS only)
/// [onAdDidPresentFullScreen] Gets invoked when the interstitial ad appeared.
/// [onAdWillDismissFullScreen] Gets invoked when the interstitial ad is about to disappear. (iOS only)
/// [onAdDidDismissFullScreen] Gets invoked when the interstitial ad disappeared.
/// [onAdFailedToReceive] Gets invoked with [AdropErrorCode] when the interstitial ad fails to be received.
/// [onAdFailedToShowFullScreen] Gets invoked with [AdropErrorCode] when the interstitial ad fails to be shown.
class AdropInterstitialListener {
  final AdropAdCallback? onAdReceived;
  final AdropAdCallback? onAdClicked;
  final AdropAdCallback? onAdImpression;
  final AdropAdCallback? onAdWillPresentFullScreen;
  final AdropAdCallback? onAdDidPresentFullScreen;
  final AdropAdCallback? onAdWillDismissFullScreen;
  final AdropAdCallback? onAdDidDismissFullScreen;
  final AdropAdErrorCallback? onAdFailedToReceive;
  final AdropAdErrorCallback? onAdFailedToShowFullScreen;

  const AdropInterstitialListener(
      {this.onAdReceived,
      this.onAdClicked,
      this.onAdImpression,
      this.onAdWillPresentFullScreen,
      this.onAdDidPresentFullScreen,
      this.onAdWillDismissFullScreen,
      this.onAdDidDismissFullScreen,
      this.onAdFailedToReceive,
      this.onAdFailedToShowFullScreen});
}
