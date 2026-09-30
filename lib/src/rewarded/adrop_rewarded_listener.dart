import 'package:adrop_ads_flutter/src/rewarded/adrop_rewarded_ad.dart';

import '../adrop_ad.dart';
import '../interstitial/adrop_interstitial_listener.dart';

typedef AdropAdRewardEventCallback = void Function(
    AdropAd ad, int type, int amount);

/// A listener called when load or show is called in the [AdropRewardedAd].
///
/// [onAdReceived] Gets invoked when the rewarded ad is received.
/// [onAdClicked] Gets invoked when the rewarded ad is clicked.
/// [onAdImpression] Gets invoked once the rewarded ad has been displayed
/// in the foreground for 500ms continuously. Not invoked if the ad is closed
/// before that. If the app is backgrounded the count is cancelled and restarts
/// from zero on return, so it may arrive later instead of never. Use
/// [onAdDidPresentFullScreen] to know that the ad appeared.
///
/// "Still displaying" below means after [onAdDidPresentFullScreen] has
/// fired. If the ad instance is disposed while it is still displaying (e.g.
/// the widget holding it is unmounted), the ad stays on screen until the
/// user closes it and the impression is still reported to the server, but
/// this callback will not fire since the underlying ad instance is already
/// gone.
///
/// On Android specifically, disposing *before* [onAdDidPresentFullScreen]
/// fires (between calling show and the ad actually appearing) is
/// different: the ad does not display and closes — rarely, a blank
/// screen may remain until the user dismisses it with back. On iOS, the
/// ad displays normally even if disposed in that same window.
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
    AdropPaidEventCallback? onPaidEvent,
  }) : super(
            onAdReceived: onAdReceived,
            onAdClicked: onAdClicked,
            onAdImpression: onAdImpression,
            onAdWillPresentFullScreen: onAdWillPresentFullScreen,
            onAdDidPresentFullScreen: onAdDidPresentFullScreen,
            onAdWillDismissFullScreen: onAdWillDismissFullScreen,
            onAdDidDismissFullScreen: onAdDidDismissFullScreen,
            onAdFailedToReceive: onAdFailedToReceive,
            onAdFailedToShowFullScreen: onAdFailedToShowFullScreen,
            onPaidEvent: onPaidEvent);
}
