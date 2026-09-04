package io.adrop.adrop_ads.banner

import android.content.Context
import android.view.View
import android.view.ViewGroup
import io.adrop.adrop_ads.model.CallCreateAd
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AdropBannerViewFactory(
    private val viewManager: AdropBannerManager
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    /**
     * Wrapper currently presenting each banner, keyed `{unitId}_{requestId}`.
     * Re-attach support (batch loads): when Flutter creates platform view #2 for
     * the same banner before disposing #1 (same-frame remount) or after a list
     * recycled it, we must (a) release #1 so the engine's dispose cannot rip the
     * banner out of #2's parent, and (b) steal the banner from whatever parent
     * still holds it — an Android View cannot be added to a second parent.
     */
    private val activeViews = mutableMapOf<String, FlutterPlatformView>()

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val callData = CallCreateAd(args as? Map<String, Any?>)

        val banner = viewManager.getAd(callData.unitId, callData.requestId)
            ?: return ErrorView(context)

        val key = "${callData.unitId}_${callData.requestId}"
        activeViews[key]?.release()
        (banner.parent as? ViewGroup)?.removeView(banner)

        var wrapper: FlutterPlatformView? = null
        wrapper = FlutterPlatformView(banner) {
            // Detach-only contract: never destroy the banner here (dispose is the
            // publisher's explicit call). Identity guard — a stale dispose after a
            // takeover must not evict the new wrapper.
            if (activeViews[key] === wrapper) activeViews.remove(key)
        }
        activeViews[key] = wrapper
        return wrapper
    }
}

private class ErrorView(val context: Context) : PlatformView {

    override fun getView(): View {
        return View(context)
    }

    override fun dispose() {}
}
