package io.adrop.adrop_ads

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.adrop.adrop_ads.popupAd.FlutterAdropPopupAd
import io.adrop.adrop_ads.interstitial.FlutterAdropInterstitialAd
import io.adrop.adrop_ads.native.FlutterAdropNativeAd
import io.adrop.adrop_ads.rewarded.FlutterAdropRewardedAd
import io.adrop.ads.model.AdropErrorCode
import io.adrop.ads.nativeAd.AdropAdChoicesPosition
import io.adrop.ads.nativeAd.AdropNativeAd
import io.adrop.ads.nativeAd.AdropNativeAdListener
import io.adrop.ads.rewardedAd.ServerSideVerificationOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class AdropAdManager {

    private val ads: MutableMap<String, AdropAd?> = mutableMapOf()

    /**
     * Keys of native ads delivered by the batch [loadsNative] path. Swept on
     * engine detach so their WebViews don't outlive the engine.
     */
    private val preloadedNativeKeys = mutableSetOf<String>()

    /**
     * Set once the engine detached ([destroyAllPreloadedNative]). A batch whose
     * network round trip completes *after* the sweep would otherwise register
     * native ads nobody sweeps again — and the core's AdropWebViewManager keys
     * them by a String the host itself holds, so they stay reachable until
     * process death. Destroy on arrival instead.
     */
    @Volatile
    private var detached = false

    /**
     * Optional hook invoked by [FlutterAdropNativeAd] when a backfill ad arrives, so
     * the plugin can re-bind the PlatformView's AdropNativeAdView to the new AdMob
     * NativeAd. Wired by the plugin to [AdropNativeAdViewFactory.rebind].
     */
    var nativeRebindCallback: ((String) -> Unit)? = null

    fun load(context: Context, adType: AdType, unitId: String, requestId: String, useCustomClick: Boolean = false, preferredAdChoicesPosition: Int = AdropAdChoicesPosition.TOP_RIGHT.value, messenger: BinaryMessenger, ssvOptions: ServerSideVerificationOptions? = null) {
        val ad = getAd(adType, requestId) ?: createAd(context, adType, unitId, requestId, useCustomClick, preferredAdChoicesPosition, messenger)
        val key = keyOf(adType, requestId)
        ads[key]?:let {
            ads[key] = ad
        }
        if (ssvOptions != null) {
            (ad as? FlutterAdropRewardedAd)?.setServerSideVerificationOptions(ssvOptions)
        }
        ad?.load()
    }

    /**
     * Batch native load: one network call, up to 5 pre-loaded ads adopted into
     * [FlutterAdropNativeAd] wrappers bound positionally to the Dart-minted
     * [requestIds]. The wrapper's init swaps each ad's listener from the
     * per-call batch listener to the wrapper, so per-instance events route
     * exactly like the singular path.
     */
    fun loadsNative(
        context: Context,
        unitId: String,
        requestIds: List<String>,
        useCustomClick: Boolean,
        messenger: BinaryMessenger,
        result: MethodChannel.Result
    ) {
        val batchListener = object : AdropNativeAdListener {
            override fun onAdsReceived(nativeAds: List<AdropNativeAd>) {
                if (detached) {
                    // Engine already swept — see [detached]. Post like the
                    // cap-drift guard below (destroy inside onAdsReceived is
                    // forbidden by the listener contract).
                    nativeAds.forEach { Handler(Looper.getMainLooper()).post { it.destroy() } }
                    result.error(
                        AdropErrorCode.ERROR_CODE_INTERNAL.name,
                        "engine detached before loads completed",
                        null
                    )
                    return
                }
                val filled = mutableListOf<String>()
                val metas = mutableListOf<Map<String, Any>>()
                nativeAds.forEachIndexed { index, nativeAd ->
                    if (index >= requestIds.size) {
                        // Cap-drift guard — destroying inside onAdsReceived is
                        // forbidden (AdropNativeAdListener KDoc), so post it.
                        Handler(Looper.getMainLooper()).post { nativeAd.destroy() }
                        return@forEachIndexed
                    }
                    val requestId = requestIds[index]
                    val wrapper = FlutterAdropNativeAd(
                        context,
                        unitId,
                        requestId,
                        useCustomClick,
                        AdropAdChoicesPosition.TOP_RIGHT.value,
                        messenger,
                        nativeRebindCallback,
                        nativeAd
                    )
                    val key = keyOf(AdType.Native, requestId)
                    ads[key] = wrapper
                    preloadedNativeKeys.add(key)
                    filled.add(requestId)
                    metas.add(wrapper.batchMetadata())
                }
                result.success(mapOf("requestIds" to filled, "ads" to metas))
            }

            override fun onAdsFailedToReceive(errorCode: AdropErrorCode) {
                result.error(errorCode.name, "AdropNativeAd.loads failed", null)
            }

            // Singular callbacks can only fire between auto-attach and the
            // wrapper adoption above — nothing is mounted yet, drop them.
            override fun onAdReceived(ad: AdropNativeAd) {}
            override fun onAdClicked(ad: AdropNativeAd) {}
            override fun onAdFailedToReceive(ad: AdropNativeAd, errorCode: AdropErrorCode) {}
        }

        AdropNativeAd.loads(context, unitId, null, batchListener)
    }

    /** Destroys every batch-loaded native ad still registered. See [preloadedNativeKeys]. */
    fun destroyAllPreloadedNative() {
        detached = true
        preloadedNativeKeys.toList().forEach { key ->
            ads[key]?.destroy()
            ads.remove(key)
        }
        preloadedNativeKeys.clear()
    }

    fun show(adType: AdType, requestId: String, activity: Activity) {
        getAd(adType, requestId)?.show(activity)
    }

    fun close(adType: AdType, requestId: String) {
        when (adType) {
            AdType.Interstitial -> {
                val interstitialAd = ads[keyOf(adType, requestId)] as? FlutterAdropInterstitialAd
                interstitialAd?: return

                interstitialAd.close()
            }
            AdType.Popup -> {
                val popupAd = ads[keyOf(adType, requestId)] as? FlutterAdropPopupAd
                popupAd?: return

                popupAd.close()
            }
            else -> return
        }
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
        preloadedNativeKeys.remove(key)
    }

    private fun createAd(context: Context, adType: AdType, unitId: String, requestId: String, useCustomClick: Boolean, preferredAdChoicesPosition: Int, messenger: BinaryMessenger): AdropAd? {
        return when (adType) {
            AdType.Interstitial -> FlutterAdropInterstitialAd(context, unitId, requestId, messenger)
            AdType.Rewarded -> FlutterAdropRewardedAd(context, unitId, requestId, messenger)
            AdType.Popup -> FlutterAdropPopupAd(context, unitId, requestId, messenger)
            AdType.Native -> FlutterAdropNativeAd(context, unitId, requestId, useCustomClick, preferredAdChoicesPosition, messenger, nativeRebindCallback)
            AdType.Undefined -> null
        }
    }

    fun getAd(adType: AdType, requestId: String): AdropAd? {
        return ads[keyOf(adType, requestId)]
    }

    private fun keyOf(adType: AdType, requestId: String): String = "$adType/$requestId"

}
