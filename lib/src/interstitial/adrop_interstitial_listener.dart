import 'package:adrop_ads_flutter/src/interstitial/adrop_interstitial_ad.dart';

import '../adrop_ad.dart';
import '../adrop_error_code.dart';

typedef AdropAdCallback = void Function(AdropAd ad);
typedef AdropAdErrorCallback = void Function(
    AdropAd ad, AdropErrorCode errorCode);

/// A listener called when load or show is called in the [AdropInterstitialAd].
///
/// [onAdReceived] Gets invoked when the interstitial ad is received.
/// [onAdClicked] Gets invoked when the interstitial ad is clicked.
/// [onAdImpression] Gets invoked once the interstitial ad has been displayed
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
/// [onAdWillPresentFullScreen] Gets invoked when the interstitial ad is about to appear. (iOS only)
/// [onAdDidPresentFullScreen] Gets invoked when the interstitial ad appeared.
/// [onAdWillDismissFullScreen] Gets invoked when the interstitial ad is about to disappear. (iOS only)
/// [onAdDidDismissFullScreen] Gets invoked when the interstitial ad disappeared.
/// [onAdFailedToReceive] Gets invoked with [AdropErrorCode] when the interstitial ad fails to be received.
/// [onAdFailedToShowFullScreen] Gets invoked with [AdropErrorCode] when the interstitial ad fails to be shown.
/// [onAdBackButtonPressed] Gets invoked when the user presses the back button while the interstitial ad is displayed. (Android only)
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
  final AdropAdCallback? onAdBackButtonPressed;
  final AdropPaidEventCallback? onPaidEvent;

  const AdropInterstitialListener(
      {this.onAdReceived,
      this.onAdClicked,
      this.onAdImpression,
      this.onAdWillPresentFullScreen,
      this.onAdDidPresentFullScreen,
      this.onAdWillDismissFullScreen,
      this.onAdDidDismissFullScreen,
      this.onAdFailedToReceive,
      this.onAdFailedToShowFullScreen,
      this.onAdBackButtonPressed,
      this.onPaidEvent});
}
