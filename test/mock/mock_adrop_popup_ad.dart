import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/popupAd/adrop_popup_listener.dart';

import 'mock_adrop_ad.dart';

class MockAdropPopupAd extends MockAdropAd {
  MockAdropPopupAd({required String unitId, AdropPopupListener? listener})
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
          ),
        );
}
