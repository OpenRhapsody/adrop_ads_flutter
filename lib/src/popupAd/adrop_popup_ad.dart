import 'dart:ui';

import '../adrop_ad.dart';
import 'adrop_popup_listener.dart';

/// AdropPopupAd class responsible for requesting popup ads and displaying them to the user.
///
/// [unitId] required Ad unit ID
/// [listener] optional invoked when a response from load, show method called back.
/// [closeTextColor] optional text color of close button
/// [hideForTodayTextColor] optional text color of hideForToday button
/// [backgroundColor] optional background color of buttons
class AdropPopupAd extends AdropAd {
  Color? closeTextColor;
  Color? hideForTodayTextColor;
  Color? backgroundColor;

  AdropPopupAd(
      {required String unitId,
      AdropPopupListener? listener,
      this.closeTextColor,
      this.hideForTodayTextColor,
      this.backgroundColor})
      : super(
            adType: AdType.popup,
            unitId: unitId,
            listener: AdropAdListener(
              onAdReceived: listener?.onAdReceived,
              onAdClicked: listener?.onAdClicked,
              onAdImpression: listener?.onAdImpression,
              onAdFailedToReceive: listener?.onAdFailedToReceive,
              onAdDidPresentFullScreen: listener?.onAdDidPresentFullScreen,
              onAdWillPresentFullScreen: listener?.onAdWillPresentFullScreen,
              onAdDidDismissFullScreen: listener?.onAdDidDismissFullScreen,
              onAdWillDismissFullScreen: listener?.onAdWillDismissFullScreen,
              onAdFailedToShowFullScreen: listener?.onAdFailedToShowFullScreen,
            ));

  @override
  Future<void> load() async {
    super.load();
    customize({
      "closeTextColor": closeTextColor?.value,
      "hideForTodayTextColor": hideForTodayTextColor?.value,
      "backgroundColor": backgroundColor?.value,
    });
  }

  Future<void> close() async {
    closeAd();
  }

  /// Returns an Adrop ad's creativeIds.
  @Deprecated(
      "This method is deprecated and will be removed in the next version. Use creativeId instead.")
  List<String> get creativeIds {
    return [];
  }
}
