package io.adrop.adrop_ads.popupAd

import android.app.Activity
import android.content.Context
import android.util.Log
import io.adrop.adrop_ads.AdType
import io.adrop.adrop_ads.AdropAd
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.ads.model.AdropErrorCode
import io.adrop.ads.popupAd.AdropPopupAd
import io.adrop.ads.popupAd.AdropPopupAdListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class FlutterAdropPopupAd(
    context: Context,
    unitId: String,
    requestId: String,
    messenger: BinaryMessenger
) : AdropAd(), AdropPopupAdListener {

    private var popupAd: AdropPopupAd = AdropPopupAd(context, unitId)
    private var adropEventListenerChannel: MethodChannel?

    init {
        popupAd.popupAdListener = this
        val channelName = AdropChannel.adropEventListenerChannelOf(AdType.Popup, requestId)
        adropEventListenerChannel = if (channelName != null) {
            MethodChannel(messenger, channelName)
        } else {
            null
        }
    }

    override fun load() {
        popupAd.load()
    }

    override fun show(activity: Activity) {
        popupAd.show(activity)
    }

    fun customize(data: Map<String, Any>) {
        data["closeTextColor"]?.let { popupAd.closeTextColor = colorOf(it) }
        data["hideForTodayTextColor"]?.let { popupAd.hideForTodayTextColor = colorOf(it) }
        data["backgroundColor"]?.let { popupAd.backgroundColor = colorOf(it) }
    }

    private fun colorOf(color: Any): Int {
        return when (color) {
            is Long -> color.toInt()
            is Int -> color
            else -> 0
        }
    }

    override fun destroy() {
        popupAd.destroy()
    }

    override fun onAdFailedToReceive(ad: AdropPopupAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(
            AdropMethod.DID_FAIL_TO_RECEIVE_AD,
            mapOf("errorCode" to errorCode.name)
        )
    }

    override fun onAdReceived(ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, null)
    }

    override fun onAdClicked(ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, null)
    }

    override fun onAdImpression(ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, null)
    }

    override fun onAdFailedToShowFullScreen(ad: AdropPopupAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(
            AdropMethod.DID_FAIL_TO_SHOW_FULL_SCREEN,
            mapOf("errorCode" to errorCode.name)
        )
    }

    override fun onAdDidPresentFullScreen(ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_PRESENT_FULL_SCREEN, null)
    }

    override fun onAdDidDismissFullScreen(ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_DISMISS_FULL_SCREEN, null)
    }
}