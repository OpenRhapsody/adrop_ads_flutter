package io.adrop.adrop_ads.native

import android.content.Context
import android.view.View
import io.adrop.adrop_ads.AdType
import io.adrop.adrop_ads.AdropAdManager
import io.adrop.adrop_ads.banner.FlutterPlatformView
import io.adrop.adrop_ads.model.CallCreateAd
import io.adrop.ads.nativeAd.AdropNativeAdView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AdropNativeAdViewFactory(
    private val viewManager: AdropAdManager
) : PlatformViewFactory(StandardMessageCodec.INSTANCE)  {

    private val viewMap = mutableMapOf<String, FlutterPlatformView>()

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val callData = CallCreateAd(args as? Map<String, Any?>)

        val ad = viewManager.getAd(AdType.Native, callData.requestId) as? FlutterAdropNativeAd
        if (ad == null) {
            return ErrorView(context)
        } else {
            val nativeAdView = AdropNativeAdView(context, null)
            nativeAdView.isEntireClick = true
            nativeAdView.setNativeAd(ad.nativeAd)

            val platformView = FlutterPlatformView(nativeAdView)
            viewMap[callData.requestId] = platformView as FlutterPlatformView

            return platformView
        }
    }

    fun performClick(requestId: String) {
        val nativeAdView = viewMap[requestId]?.getView()
        nativeAdView?: return

        nativeAdView.performClick()
    }

    /**
     * Re-bind the AdropNativeAd to the existing PlatformView's AdropNativeAdView.
     *
     * Needed for backfill ads because PlatformView is created once (in [create]) and
     * reused across `ad.load()` calls. The core `AdropNativeAdView.setNativeAd` is
     * never re-invoked through the PlatformView lifecycle, so for backfill flows AdMob's
     * `NativeAdView.setNativeAd(admobNativeAd)` is never called for the new AdMob
     * NativeAd instance and OM SDK never starts tracking it (impression callback dead).
     *
     * Direct ads do not need this — they reuse the same `ad.host` (WebView) which
     * updates its creative HTML internally on each `ad.load()`.
     *
     * Safe to call when PlatformView hasn't been created yet (no-op).
     */
    fun rebind(requestId: String) {
        val view = viewMap[requestId]?.getView() as? AdropNativeAdView ?: return
        val ad = (viewManager.getAd(AdType.Native, requestId) as? FlutterAdropNativeAd)?.nativeAd ?: return
        view.setNativeAd(ad)
    }
}

private class ErrorView(val context: Context) : PlatformView {

    override fun getView(): View {
        return View(context)
    }

    override fun dispose() {}
}
