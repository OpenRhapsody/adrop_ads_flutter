package io.adrop.adrop_ads.interstitial

import android.app.Activity
import android.content.Context
import android.graphics.Color
import io.adrop.adrop_ads.AdropAd
import io.adrop.adrop_ads.AdType
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.ads.model.AdropErrorCode
import io.adrop.ads.interstitial.AdropInterstitialAd
import io.adrop.ads.interstitial.AdropInterstitialAdCloseListener
import io.adrop.ads.interstitial.AdropInterstitialAdListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class FlutterAdropInterstitialAd(
    context: Context,
    unitId: String,
    requestId: String,
    messenger: BinaryMessenger
): AdropAd(), AdropInterstitialAdListener, AdropInterstitialAdCloseListener {
    private var interstitialAd: AdropInterstitialAd = AdropInterstitialAd(context, unitId)
    private var adropEventListenerChannel: MethodChannel?
    private var originalStatusBarColor: Int = 0
    private var showActivity: Activity? = null

    init {
        interstitialAd.interstitialAdListener = this
        interstitialAd.closeListener = this
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
        showActivity = activity
        originalStatusBarColor = activity.window.statusBarColor
        interstitialAd.show(activity)
    }

    override fun destroy() {
        interstitialAd.destroy()
    }

    override fun onAdFailedToReceive(ad: AdropInterstitialAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_RECEIVE_AD, mapOf("errorCode" to errorCode.name))
    }

    override fun onAdReceived(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, metadataOf(ad))
    }

    override fun onAdClicked(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, metadataOf(ad))
    }

    override fun onAdImpression(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, metadataOf(ad))
    }

    override fun onAdDidPresentFullScreen(ad: AdropInterstitialAd) {
        if (ad.isBackfilled) {
            showActivity?.window?.statusBarColor = Color.BLACK
        }
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_PRESENT_FULL_SCREEN, metadataOf(ad))
    }

    override fun onAdDidDismissFullScreen(ad: AdropInterstitialAd) {
        showActivity?.window?.statusBarColor = originalStatusBarColor
        showActivity = null
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_DISMISS_FULL_SCREEN, metadataOf(ad))
    }

    override fun onAdFailedToShowFullScreen(ad: AdropInterstitialAd, errorCode: AdropErrorCode) {
        showActivity?.window?.statusBarColor = originalStatusBarColor
        showActivity = null
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_SHOW_FULL_SCREEN, mapOf("errorCode" to errorCode.name))
    }

    override fun onBackPressed(ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_BACK_BUTTON_PRESSED, metadataOf(ad))
    }

    fun close() {
        interstitialAd.close()
    }

    private fun metadataOf(ad: AdropInterstitialAd): Map<String, Any?> {
        return mapOf(
            "creativeId" to ad.creativeId,
            "txId" to ad.txId,
            "campaignId" to ad.campaignId,
            "browserTarget" to ad.browserTarget
        )
    }
}
