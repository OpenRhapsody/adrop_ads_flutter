import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/rewarded/adrop_rewarded_listener.dart';

import 'mock_adrop_ad.dart';

class MockAdropRewardedAd extends MockAdropAd {
  MockAdropRewardedAd({required String unitId, AdropRewardedListener? listener})
      : super(
          adType: AdType.rewarded,
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
            onAdEarnRewardHandler: listener?.onAdEarnRewardHandler,
          ),
        );
}
