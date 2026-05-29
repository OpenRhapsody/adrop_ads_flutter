package io.adrop.adrop_ads.native

import android.content.Context
import io.adrop.adrop_ads.AdType
import io.adrop.adrop_ads.AdropAd
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.ads.model.AdropErrorCode
import io.adrop.ads.nativeAd.AdropAdChoicesPosition
import io.adrop.ads.nativeAd.AdropNativeAd
import io.adrop.ads.nativeAd.AdropNativeAdListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class FlutterAdropNativeAd(
    context: Context,
    unitId: String,
    requestId: String,
    useCustomClick: Boolean,
    preferredAdChoicesPosition: Int,
    messenger: BinaryMessenger,
    /**
     * Invoked on [onAdReceived] for backfill ads to re-bind the PlatformView's
     * AdropNativeAdView to the new AdMob NativeAd. Direct ads do not need this —
     * they reuse the same WebView host. See [AdropNativeAdViewFactory.rebind].
     */
    private val nativeRebindCallback: ((String) -> Unit)? = null
): AdropAd(), AdropNativeAdListener {

    val nativeAd: AdropNativeAd = AdropNativeAd(context, unitId, "")
    private val requestId: String = requestId
    private var adropEventListenerChannel: MethodChannel?

    init {
        nativeAd.listener = this
        nativeAd.useCustomClick = useCustomClick
        // The core SDK's AdropAdChoicesPosition.fromValue gets stripped by the
        // release AAR proguard (which keeps only public methods), so map here.
        nativeAd.preferredAdChoicesPosition = when (preferredAdChoicesPosition) {
            AdropAdChoicesPosition.TOP_LEFT.value -> AdropAdChoicesPosition.TOP_LEFT
            AdropAdChoicesPosition.BOTTOM_LEFT.value -> AdropAdChoicesPosition.BOTTOM_LEFT
            AdropAdChoicesPosition.BOTTOM_RIGHT.value -> AdropAdChoicesPosition.BOTTOM_RIGHT
            else -> AdropAdChoicesPosition.TOP_RIGHT
        }
        val channelName = AdropChannel.adropEventListenerChannelOf(AdType.Native, requestId)
        adropEventListenerChannel = if (channelName != null) {
            MethodChannel(messenger, channelName)
        } else {
            null
        }
    }



    override fun load() {
        nativeAd.load()
    }

    override fun destroy() {
    }

    override fun onAdClicked(ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, metadataOf(ad))
    }

    override fun onAdFailedToReceive(ad: AdropNativeAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(
            AdropMethod.DID_FAIL_TO_RECEIVE_AD,
            mapOf("errorCode" to errorCode.name)
        )
    }

    override fun onAdReceived(ad: AdropNativeAd) {
        // Backfill: re-bind PlatformView's AdropNativeAdView so AdMob NativeAdView
        // gets setNativeAd called with the new AdMob NativeAd. Direct ads skip — the
        // reused WebView host updates its creative HTML internally.
        if (ad.isBackfilled) {
            nativeRebindCallback?.invoke(requestId)
        }
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, metadataOf(ad))
    }

    override fun onAdImpression(ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, metadataOf(ad))
    }

    override fun onAdVideoStart(ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_VIDEO_START, metadataOf(ad))
    }

    override fun onAdVideoEnd(ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_VIDEO_END, metadataOf(ad))
    }

    private fun metadataOf(ad: AdropNativeAd): Map<String, Any> {
        var creative = ad.creative
        val adPlayerCallback = "window.adPlayerVisibilityCallback"

        if (creative?.contains(adPlayerCallback) == true) {
            creative = creative.replace(adPlayerCallback, "callback(true);$adPlayerCallback")
        }

        return mapOf(
            "creativeId" to ad.creativeId,
            "headline" to ad.headline,
            "body" to ad.body,
            "displayLogo" to ad.profile.displayLogo,
            "displayName" to ad.profile.displayName,
            "extra" to ad.extra.toString(),
            "asset" to ad.asset,
            "destinationURL" to ad.destinationURL,
            "creative" to creative,
            "creativeSizeWidth" to ad.creativeSize.width,
            "creativeSizeHeight" to ad.creativeSize.height,
            "txId" to ad.txId,
            "campaignId" to ad.campaignId,
            "isBackfilled" to ad.isBackfilled,
            "callToAction" to ad.callToAction,
            "browserTarget" to ad.browserTarget,
            "creativeType" to ad.creativeType
        )
    }
}
