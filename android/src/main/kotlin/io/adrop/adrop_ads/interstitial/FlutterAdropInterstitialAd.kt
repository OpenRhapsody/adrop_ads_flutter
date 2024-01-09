package io.adrop.adrop_ads.interstitial

import android.app.Activity
import android.content.Context
import io.adrop.adrop_ads.AdropAd
import io.adrop.adrop_ads.AdType
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.ads.model.AdropErrorCode
import io.adrop.ads.interstitial.AdropInterstitialAd
import io.adrop.ads.interstitial.AdropInterstitialAdListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class FlutterAdropInterstitialAd(
    context: Context,
    unitId: String,
    requestId: String,
    messenger: BinaryMessenger
): AdropAd(), AdropInterstitialAdListener {
    private var interstitialAd: AdropInterstitialAd = AdropInterstitialAd(context, unitId)
    private var adropEventListenerChannel: MethodChannel?

    init {
        interstitialAd.interstitialAdListener = this
        val channelName = AdropChannel.adropEventListenerChannelOf(AdType.Interstitial, requestId)
        adropEventListenerChannel = if (channelName != null) {
            MethodChannel(messenger, channelName)
        } else {
            null
        }
    }

    override fun load() {
        interstitialAd.load()
    }

    override fun show(activity: Activity) {
        interstitialAd.show(activity)
    }

    override fun destroy() {
        interstitialAd.destroy()
    }

    override fun onAdFailedToReceive(ad: AdropInterstitialAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_RECEIVE_AD, mapOf("errorCode" to errorCode.name))
    }

    override fun onAdReceived(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, null)
    }

    override fun onAdClicked(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, null)
    }

    override fun onAdImpression(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, null)
    }

    override fun onAdDidPresentFullScreen(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_PRESENT_FULL_SCREEN, null)
    }

    override fun onAdDidDismissFullScreen(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_DISMISS_FULL_SCREEN, null)
    }

    override fun onAdFailedToShowFullScreen(ad: AdropInterstitialAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_SHOW_FULL_SCREEN, mapOf("errorCode" to errorCode.name))
    }
}
