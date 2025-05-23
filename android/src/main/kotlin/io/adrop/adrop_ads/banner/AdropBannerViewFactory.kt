package io.adrop.adrop_ads.banner

import android.content.Context
import android.view.View
import io.adrop.adrop_ads.model.CallCreateAd
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AdropBannerViewFactory(
    private val viewManager: AdropBannerManager
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val callData = CallCreateAd(args as? Map<String, Any?>)

        val banner = viewManager.getAd(callData.unitId, callData.requestId)
        return if (banner == null) {
            return ErrorView(context)
        } else {
            return FlutterPlatformView(banner)
        }
    }
}

private class ErrorView(val context: Context) : PlatformView {

    override fun getView(): View {
        return View(context)
    }

    override fun dispose() {}
}
