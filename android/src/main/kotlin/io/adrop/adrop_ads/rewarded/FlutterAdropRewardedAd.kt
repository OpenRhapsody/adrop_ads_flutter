package io.adrop.adrop_ads.rewarded

import android.app.Activity
import android.content.Context
import io.adrop.adrop_ads.AdropAd
import io.adrop.adrop_ads.AdType
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.ads.model.AdropErrorCode
import io.adrop.ads.rewardedAd.AdropRewardedAd
import io.adrop.ads.rewardedAd.AdropRewardedAdListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class FlutterAdropRewardedAd(
    context: Context,
    unitId: String,
    requestId: String,
    messenger: BinaryMessenger
): AdropAd(), AdropRewardedAdListener {
    private var rewardedAd: AdropRewardedAd = AdropRewardedAd(context, unitId)
    private var adropEventListenerChannel: MethodChannel?

    init {
        rewardedAd.rewardedAdListener = this
        val channelName = AdropChannel.adropEventListenerChannelOf(AdType.Rewarded, requestId)
        adropEventListenerChannel = if (channelName != null) {
            MethodChannel(messenger, channelName)
        } else {
            null
        }
    }

    override fun load() {
        rewardedAd.load()
    }

    override fun show(activity: Activity) {
        rewardedAd.show(activity) { type, amount ->
            val args = mapOf("type" to type, "amount" to amount)
            adropEventListenerChannel?.invokeMethod(AdropMethod.HANDLE_EARN_REWARD, args)
        }
    }

    override fun destroy() {
        rewardedAd.destroy()
    }

    override fun onAdFailedToReceive(ad: AdropRewardedAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_RECEIVE_AD, mapOf("errorCode" to errorCode.name))
    }

    override fun onAdReceived(ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, null)
    }

    override fun onAdClicked(ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, null)
    }

    override fun onAdImpression(ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, null)
    }

    override fun onAdDidPresentFullScreen(ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_PRESENT_FULL_SCREEN, null)
    }

    override fun onAdDidDismissFullScreen(ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_DISMISS_FULL_SCREEN, null)
    }

    override fun onAdFailedToShowFullScreen(ad: AdropRewardedAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_SHOW_FULL_SCREEN, mapOf("errorCode" to errorCode.name))
    }
}
