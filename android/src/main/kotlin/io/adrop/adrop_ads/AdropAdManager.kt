package io.adrop.adrop_ads

import android.app.Activity
import android.content.Context
import io.adrop.adrop_ads.popupAd.FlutterAdropPopupAd
import io.adrop.adrop_ads.interstitial.FlutterAdropInterstitialAd
import io.adrop.adrop_ads.rewarded.FlutterAdropRewardedAd
import io.flutter.plugin.common.BinaryMessenger

class AdropAdManager {

    private val ads: MutableMap<String, AdropAd?> = mutableMapOf()

    fun load(context: Context, adType: AdType, unitId: String, requestId: String, messenger: BinaryMessenger) {
        val ad = getAd(adType, requestId) ?: createAd(context, adType, unitId, requestId, messenger)
        val key = keyOf(adType, requestId)
        ads[key]?:let {
            ads[key] = ad
        }
        ad?.load()
    }

    fun show(adType: AdType, requestId: String, activity: Activity) {
        getAd(adType, requestId)?.show(activity)
    }

    fun customize(adType: AdType, requestId: String, data: Map<String, Any>) {
        when (adType) {
            AdType.Popup -> {
                val popupAd = ads[keyOf(adType, requestId)] as? FlutterAdropPopupAd
                popupAd?: run { return }

                popupAd.customize(data)
            }
            else -> return
        }
    }

    fun destroy(adType: AdType, requestId: String) {
        val key = keyOf(adType, requestId)
        ads[key]?.let {
            it.destroy()
            ads.remove(key)
        }
    }

    private fun createAd(context: Context, adType: AdType, unitId: String, requestId: String, messenger: BinaryMessenger): AdropAd? {
        return when (adType) {
            AdType.Interstitial -> FlutterAdropInterstitialAd(context, unitId, requestId, messenger)
            AdType.Rewarded -> FlutterAdropRewardedAd(context, unitId, requestId, messenger)
            AdType.Popup -> FlutterAdropPopupAd(context, unitId, requestId, messenger)
            AdType.Undefined -> null
        }
    }

    private fun getAd(adType: AdType, requestId: String): AdropAd? {
        return ads[keyOf(adType, requestId)]
    }

    private fun keyOf(adType: AdType, requestId: String): String = "$adType/$requestId"

}
