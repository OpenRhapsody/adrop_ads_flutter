import '../../adrop_ads_flutter.dart';
import '../adrop_ad.dart' show AdropAdVideoCallback;

/// A listener called when load or show is called in the [AdropPopupAd].
///
/// [onAdReceived] Gets invoked when the popup ad is received.
/// [onAdClicked] Gets invoked when the popup ad is clicked.
/// [onAdImpression] Gets invoked when the popup ad is shown.
/// [onAdWillPresentFullScreen] Gets invoked when the popup ad is about to appear. (iOS only)
/// [onAdDidPresentFullScreen] Gets invoked when the popup ad appeared.
/// [onAdWillDismissFullScreen] Gets invoked when the popup ad is about to disappear. (iOS only)
/// [onAdDidDismissFullScreen] Gets invoked when the popup ad disappeared.
/// [onAdFailedToReceive] Gets invoked with [AdropErrorCode] when the popup ad fails to be received.
/// [onAdFailedToShowFullScreen] Gets invoked with [AdropErrorCode] when the popup ad fails to be shown.
/// [onAdVideoStart] Gets invoked when the popup ad video starts playing.
/// [onAdVideoEnd] Gets invoked when the popup ad video ends playing.
class AdropPopupListener extends AdropInterstitialListener {
  final AdropAdVideoCallback? onAdVideoStart;
  final AdropAdVideoCallback? onAdVideoEnd;

  AdropPopupListener({
    AdropAdCallback? onAdReceived,
    AdropAdCallback? onAdClicked,
    AdropAdCallback? onAdImpression,
    AdropAdCallback? onAdWillPresentFullScreen,
    AdropAdCallback? onAdDidPresentFullScreen,
    AdropAdCallback? onAdWillDismissFullScreen,
    AdropAdCallback? onAdDidDismissFullScreen,
    AdropAdErrorCallback? onAdFailedToReceive,
    AdropAdErrorCallback? onAdFailedToShowFullScreen,
    this.onAdVideoStart,
    this.onAdVideoEnd,
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
