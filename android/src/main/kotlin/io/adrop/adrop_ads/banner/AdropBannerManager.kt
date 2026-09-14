package io.adrop.adrop_ads.banner


import android.content.Context
import android.os.Handler
import android.os.Looper
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.toMap
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.ads.banner.AdropBanner
import io.adrop.ads.banner.AdropBannerListener
import io.adrop.ads.model.AdropAdValue
import io.adrop.ads.model.AdropPaidEventListener
import io.adrop.ads.model.AdropErrorCode
import io.adrop.ads.model.CreativeSize
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel


class AdropBannerManager(
    private val context: Context?,
    messenger: BinaryMessenger
) : AdropBannerListener {

    private val adropChannel = MethodChannel(messenger, AdropChannel.INVOKE_CHANNEL)
    private val ads: MutableMap<String, AdropBanner?> = mutableMapOf()
    private val requestIdMap: MutableMap<AdropBanner, String> = mutableMapOf()

    /**
     * Keys of banners delivered by the batch [loads] path. Swept on engine
     * detach so their WebViews don't outlive the engine.
     */
    private val preloadedKeys = mutableSetOf<String>()

    /**
     * Set once the engine detached ([destroyAllPreloaded]). A batch whose network
     * round trip completes *after* the sweep would otherwise register banners
     * nobody sweeps again — and the core's VisibilityTracker listener chain
     * (task → listener → banner → host key) keeps them reachable until process
     * death, so they must be destroyed on arrival instead.
     */
    @Volatile
    private var detached = false

    private fun create(unitId: String, requestId: String, width: Double, height: Double): AdropBanner? {
        if (context == null) return null

        val key = keyOf(unitId, requestId)
        return ads[key] ?: let {
            val banner = ads[key] ?: AdropBanner(context, unitId)
            banner.listener = this
            banner.paidEventListener = AdropPaidEventListener(::onBannerPaidEvent)
            ads[key] = banner
            requestIdMap[banner] = requestId
            if (width > 0 && height > 0) banner.adSize = CreativeSize(width, height)

            banner
        }
    }

    fun load(unitId: String, requestId: String, width: Double, height: Double) {
        create(unitId, requestId, width, height)?.load()
    }

    /**
     * Batch load: one network call, up to 5 pre-loaded banners bound
     * positionally to the Dart-minted [requestIds]. The per-call listener only
     * handles the terminal batch callbacks; after registration each banner's
     * listener is swapped to this manager so per-instance events route exactly
     * like the singular path (sanctioned by docs/decisions/batch-loads-api.md §2).
     */
    fun loads(unitId: String, requestIds: List<String>, result: MethodChannel.Result) {
        val context = context ?: run {
            result.error(
                AdropErrorCode.ERROR_CODE_INITIALIZE.name,
                "loads called before plugin context initialized",
                null
            )
            return
        }

        val batchListener = object : AdropBannerListener {
            override fun onAdsReceived(banners: List<AdropBanner>) {
                if (detached) {
                    // Engine already swept — see [detached]. Post like the
                    // cap-drift guard below (destroy inside onAdsReceived races
                    // the queued WebView load).
                    banners.forEach { Handler(Looper.getMainLooper()).post { it.destroy() } }
                    result.error(
                        AdropErrorCode.ERROR_CODE_INTERNAL.name,
                        "engine detached before loads completed",
                        null
                    )
                    return
                }
                val filled = mutableListOf<String>()
                val metas = mutableListOf<Map<String, Any?>>()
                banners.forEachIndexed { index, banner ->
                    if (index >= requestIds.size) {
                        // Cap-drift guard: native returned more rows than minted ids.
                        // Post — destroying inside onAdsReceived races the queued
                        // WebView load (AdropBannerListener KDoc).
                        // Main looper, NOT View.post: an unattached View queues the
                        // runnable in its mRunQueue, drained only by
                        // dispatchAttachedToWindow — and this banner is never
                        // mounted, so View.post would never run it (leaked WebView).
                        Handler(Looper.getMainLooper()).post { banner.destroy() }
                        return@forEachIndexed
                    }
                    val requestId = requestIds[index]
                    val key = keyOf(unitId, requestId)
                    banner.listener = this@AdropBannerManager
                    ads[key] = banner
                    requestIdMap[banner] = requestId
                    preloadedKeys.add(key)
                    filled.add(requestId)
                    metas.add(metadataOf(banner))
                }
                result.success(mapOf("requestIds" to filled, "ads" to metas))
            }

            override fun onAdsFailedToReceive(errorCode: AdropErrorCode) {
                result.error(errorCode.name, "AdropBanner.loads failed", null)
            }

            // Singular callbacks can only fire between auto-attach and the swap
            // above — nothing is mounted yet, so they are intentionally dropped.
            override fun onAdReceived(banner: AdropBanner) {}
            override fun onAdClicked(banner: AdropBanner) {}
            override fun onAdFailedToReceive(banner: AdropBanner, error: AdropErrorCode) {}
        }

        AdropBanner.loads(context, unitId, null, batchListener)
    }

    /** Destroys every batch-loaded banner still registered. See [preloadedKeys]. */
    fun destroyAllPreloaded() {
        detached = true
        preloadedKeys.toList().forEach { key ->
            ads[key]?.let {
                it.destroy()
                requestIdMap.remove(it)
            }
            ads.remove(key)
        }
        preloadedKeys.clear()
    }

    fun play(unitId: String, requestId: String) {
        ads[keyOf(unitId, requestId)]?.play()
    }

    fun pause(unitId: String, requestId: String) {
        ads[keyOf(unitId, requestId)]?.pause()
    }

    fun getAd(unitId: String, requestId: String): AdropBanner? {
        return ads[keyOf(unitId, requestId)]
    }

    fun destroy(unitId: String, requestId: String) {
        val key = keyOf(unitId, requestId)
        ads[key]?.let {
            it.destroy()
            requestIdMap.remove(it)
            ads.remove(key)
        }
        preloadedKeys.remove(key)
    }

    private fun keyOf(unitId: String, requestId: String): String {
        return "${unitId}_${requestId}"
    }

    override fun onAdClicked(banner: AdropBanner) {
        adropChannel.invokeMethod(AdropMethod.DID_CLICK_AD, metadataOf(banner))
    }

    override fun onAdFailedToReceive(banner: AdropBanner, error: AdropErrorCode) {
        val args = mapOf("unitId" to banner.getUnitId(), "error" to error.name, "requestId" to requestIdMap[banner])
        adropChannel.invokeMethod(AdropMethod.DID_FAIL_TO_RECEIVE_AD, args)
    }

    override fun onAdReceived(banner: AdropBanner) {
        adropChannel.invokeMethod(AdropMethod.DID_RECEIVE_AD, metadataOf(banner))
    }

    override fun onAdImpression(banner: AdropBanner) {
        adropChannel.invokeMethod(AdropMethod.DID_IMPRESSION, metadataOf(banner))
    }

    override fun onAdVideoStart(banner: AdropBanner) {
        adropChannel.invokeMethod(AdropMethod.DID_VIDEO_START, metadataOf(banner))
    }

    override fun onAdVideoEnd(banner: AdropBanner) {
        adropChannel.invokeMethod(AdropMethod.DID_VIDEO_END, metadataOf(banner))
    }

    private fun onBannerPaidEvent(banner: AdropBanner, value: AdropAdValue) {
        adropChannel.invokeMethod(AdropMethod.DID_PAID_EVENT, mapOf(
            *metadataOf(banner).toList().toTypedArray(),
            "value" to value.toMap()
        ))
    }

    private fun metadataOf(banner: AdropBanner): Map<String, Any?> {
        return mapOf(
            "unitId" to banner.getUnitId(),
            "creativeId" to banner.creativeId,
            "txId" to banner.txId,
            "campaignId" to banner.campaignId,
            "requestId" to requestIdMap[banner],
            "destinationURL" to banner.destinationURL,
            "creativeSizeWidth" to banner.creativeSize.width,
            "creativeSizeHeight" to banner.creativeSize.height,
            "browserTarget" to banner.browserTarget,
            "creativeType" to banner.creativeType
        )
    }
}
