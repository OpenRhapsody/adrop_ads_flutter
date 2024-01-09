import 'package:adrop_ads_flutter/src/rewarded/adrop_rewarded_ad.dart';

import '../adrop_ad.dart';
import '../interstitial/adrop_interstitial_listener.dart';

typedef AdropAdRewardEventCallback = void Function(AdropAd ad, int type, int amount);

/// A listener called when load or show is called in the [AdropRewardedAd].
///
/// [onAdReceived] Gets invoked when the rewarded ad is received.
/// [onAdClicked] Gets invoked when the rewarded ad is clicked.
/// [onAdImpression] Gets invoked when the rewarded ad is shown.
/// [onAdWillPresentFullScreen] Gets invoked when the rewarded ad is about to appear. (iOS only)
/// [onAdDidPresentFullScreen] Gets invoked when the rewarded ad appeared.
/// [onAdWillDismissFullScreen] Gets invoked when the rewarded ad is about to disappear. (iOS only)
/// [onAdDidDismissFullScreen] Gets invoked when the rewarded ad disappeared.
/// [onAdFailedToReceive] Gets invoked with [AdropErrorCode] when the rewarded ad fails to be received.
/// [onAdFailedToShowFullScreen] Gets invoked with [AdropErrorCode] when the rewarded ad fails to be shown.
/// [onAdEarnRewardHandler] Gets invoked with reward type & amount when the rewarded ad gets reward message.
class AdropRewardedListener extends AdropInterstitialListener {
  final AdropAdRewardEventCallback? onAdEarnRewardHandler;

  AdropRewardedListener({
    this.onAdEarnRewardHandler,
    AdropAdCallback? onAdReceived,
    AdropAdCallback? onAdClicked,
    AdropAdCallback? onAdImpression,
    AdropAdCallback? onAdWillPresentFullScreen,
    AdropAdCallback? onAdDidPresentFullScreen,
    AdropAdCallback? onAdWillDismissFullScreen,
    AdropAdCallback? onAdDidDismissFullScreen,
    AdropAdErrorCallback? onAdFailedToReceive,
    AdropAdErrorCallback? onAdFailedToShowFullScreen,
  }) : super(
            onAdReceived: onAdReceived,
            onAdClicked: onAdClicked,
            onAdImpression: onAdImpression,
            onAdWillPresentFullScreen: onAdWillPresentFullScreen,
            onAdDidPresentFullScreen: onAdDidPresentFullScreen,
            onAdWillDismissFullScreen: onAdWillDismissFullScreen,
            onAdDidDismissFullScreen: onAdDidDismissFullScreen,
            onAdFailedToReceive: onAdFailedToReceive,
            onAdFailedToShowFullScreen: onAdFailedToShowFullScreen);
}
