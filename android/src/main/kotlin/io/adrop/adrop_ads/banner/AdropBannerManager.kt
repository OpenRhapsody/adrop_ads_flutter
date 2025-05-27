package io.adrop.adrop_ads.banner


import android.content.Context
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.ads.banner.AdropBanner
import io.adrop.ads.banner.AdropBannerListener
import io.adrop.ads.model.AdropErrorCode
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel


class AdropBannerManager(
    private val context: Context?,
    messenger: BinaryMessenger
) : AdropBannerListener {

    private val adropChannel = MethodChannel(messenger, AdropChannel.INVOKE_CHANNEL)
    private val ads: MutableMap<String, AdropBanner?> = mutableMapOf()
    private val requestIdMap: MutableMap<AdropBanner, String> = mutableMapOf()

    private fun create(unitId: String, requestId: String): AdropBanner? {
        if (context == null) return null

        val key = keyOf(unitId, requestId)
        return ads[key] ?: let {
            val banner = ads[key] ?: AdropBanner(context, unitId)
            banner.listener = this
            ads[key] = banner
            requestIdMap[banner] = requestId
            banner
        }
    }

    fun load(unitId: String, requestId: String) {
        create(unitId, requestId)?.load()
    }

    fun getAd(unitId: String, requestId: String): AdropBanner? {
        return ads[keyOf(unitId, requestId)]
    }

    fun destroy(unitId: String, requestId: String) {
        val key = keyOf(unitId, requestId)
        ads[key]?.let {
            requestIdMap.remove(it)
            ads.remove(key)
        }
    }

    private fun keyOf(unitId: String, requestId: String): String {
        return "${unitId}_${requestId}"
    }

    override fun onAdClicked(banner: AdropBanner) {
        val unitId = banner.getUnitId()
        ads[unitId] = banner

        val args = mapOf("unitId" to unitId, "creativeId" to banner.creativeId, "requestId" to requestIdMap[banner])
        adropChannel.invokeMethod(AdropMethod.DID_CLICK_AD, args)
    }

    override fun onAdFailedToReceive(banner: AdropBanner, error: AdropErrorCode) {
        val unitId = banner.getUnitId()
        ads[unitId] = banner

        val args = mapOf("unitId" to unitId, "error" to error.name, "requestId" to requestIdMap[banner])
        adropChannel.invokeMethod(AdropMethod.DID_FAIL_TO_RECEIVE_AD, args)
    }

    override fun onAdReceived(banner: AdropBanner) {
        val unitId = banner.getUnitId()
        ads[unitId] = banner

        val args = mapOf(
            "unitId" to unitId,
            "creativeId" to banner.creativeId,
            "requestId" to requestIdMap[banner],
            "creativeSizeWidth" to banner.creativeSize.width,
            "creativeSizeHeight" to banner.creativeSize.height
        )

        adropChannel.invokeMethod(AdropMethod.DID_RECEIVE_AD, args)
    }

    override fun onAdImpression(banner: AdropBanner) {
    }
}
