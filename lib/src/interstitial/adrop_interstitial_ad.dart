import 'package:adrop_ads_flutter/src/interstitial/adrop_interstitial_listener.dart';

import '../adrop_ad.dart';

/// AdropInterstitialAd class responsible for requesting interstitial ads and displaying them to the user.
///
/// [unitId] required Ad unit ID
/// [listener] optional invoked when a response from load, show method called back.
class AdropInterstitialAd extends AdropAd {
  AdropInterstitialAd(
      {required String unitId, AdropInterstitialListener? listener})
      : super(
          adType: AdType.interstitial,
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
          ),
        );
}
