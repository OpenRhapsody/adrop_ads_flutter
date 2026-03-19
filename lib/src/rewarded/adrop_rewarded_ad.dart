import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/rewarded/adrop_rewarded_listener.dart';
import 'package:adrop_ads_flutter/src/rewarded/server_side_verification_options.dart';

/// AdropRewardedAd class responsible for requesting rewarded ads and displaying them to the user.
///
/// [unitId] required Ad unit ID
/// [listener] optional invoked when a response from load, show method called back.
class AdropRewardedAd extends AdropAd {
  ServerSideVerificationOptions? serverSideVerificationOptions;

  AdropRewardedAd({required String unitId, AdropRewardedListener? listener})
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

  @override
  Map<String, dynamic> get extraLoadArgs {
    final ssv = serverSideVerificationOptions;
    if (ssv == null) return {};
    return {
      if (ssv.userId != null) "userId": ssv.userId,
      if (ssv.customData != null) "customData": ssv.customData,
    };
  }
}
