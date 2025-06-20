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
}

private class ErrorView(val context: Context) : PlatformView {

    override fun getView(): View {
        return View(context)
    }

    override fun dispose() {}
}
