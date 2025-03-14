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

    private fun create(unitId: String): AdropBanner? {
        if (context == null) return null

        return ads[unitId] ?: let {
            val banner = ads[unitId] ?: AdropBanner(context, unitId)
            banner.listener = this
            ads[unitId] = banner
            banner
        }
    }

    fun load(unitId: String) {
        create(unitId)?.load()
    }

    fun getAd(unitId: String): AdropBanner? = ads[unitId]

    fun destroy(unitId: String) {
        ads[unitId]?.let {
            ads.remove(unitId)
        }
    }

    override fun onAdClicked(banner: AdropBanner) {
        val unitId = banner.getUnitId()
        ads[unitId] = banner

        val args = mapOf<String, String?>("unitId" to unitId, "creativeId" to banner.creativeId)
        adropChannel.invokeMethod(AdropMethod.DID_CLICK_AD, args)
    }

    override fun onAdFailedToReceive(banner: AdropBanner, error: AdropErrorCode) {
        val unitId = banner.getUnitId()
        ads[unitId] = banner

        val args = mapOf<String, String?>("unitId" to unitId, "error" to error.name)
        adropChannel.invokeMethod(AdropMethod.DID_FAIL_TO_RECEIVE_AD, args)
    }

    override fun onAdReceived(banner: AdropBanner) {
        val unitId = banner.getUnitId()
        ads[unitId] = banner

        val args = mapOf<String, String?>("unitId" to unitId, "creativeId" to banner.creativeId)
        adropChannel.invokeMethod(AdropMethod.DID_RECEIVE_AD, args)
    }

    override fun onAdImpression(banner: AdropBanner) {
    }
}
