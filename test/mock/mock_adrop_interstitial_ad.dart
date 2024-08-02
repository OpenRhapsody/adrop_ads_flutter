import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/interstitial/adrop_interstitial_listener.dart';

import 'mock_adrop_ad.dart';

class MockAdropInterstitialAd extends MockAdropAd {
  MockAdropInterstitialAd(
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
