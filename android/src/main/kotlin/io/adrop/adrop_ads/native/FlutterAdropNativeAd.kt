package io.adrop.adrop_ads.native

import android.content.Context
import io.adrop.adrop_ads.AdType
import io.adrop.adrop_ads.AdropAd
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.ads.model.AdropErrorCode
import io.adrop.ads.nativeAd.AdropNativeAd
import io.adrop.ads.nativeAd.AdropNativeAdListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class FlutterAdropNativeAd(
    context: Context,
    unitId: String,
    requestId: String,
    useCustomClick: Boolean,
    messenger: BinaryMessenger
): AdropAd(), AdropNativeAdListener {

    val nativeAd: AdropNativeAd = AdropNativeAd(context, unitId, "")
    private var adropEventListenerChannel: MethodChannel?

    init {
        nativeAd.listener = this
        nativeAd.useCustomClick = useCustomClick
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

    override fun onAdClick(ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, metadataOf(ad))
    }

    override fun onAdFailedToReceive(ad: AdropNativeAd, errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(
            AdropMethod.DID_FAIL_TO_RECEIVE_AD,
            mapOf("errorCode" to errorCode.name)
        )
    }

    override fun onAdReceived(ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, metadataOf(ad))
    }

    override fun onAdImpression(ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, metadataOf(ad))
    }

    private fun metadataOf(ad: AdropNativeAd): Map<String, Any> {
        return mapOf(
            "creativeId" to ad.creativeId,
            "headline" to ad.headline,
            "body" to ad.body,
            "displayLogo" to ad.profile.displayLogo,
            "displayName" to ad.profile.displayName,
            "extra" to ad.extra.toString(),
            "asset" to ad.asset,
            "destinationURL" to ad.destinationURL,
            "creative" to ad.creative,
            "creativeSizeWidth" to ad.creativeSize.width,
            "creativeSizeHeight" to ad.creativeSize.height,
            "txId" to ad.txId,
            "campaignId" to ad.campaignId
        )
    }
}
