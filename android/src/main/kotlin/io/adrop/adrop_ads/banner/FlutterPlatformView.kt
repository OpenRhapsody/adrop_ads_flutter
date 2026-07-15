package io.adrop.adrop_ads.banner

import android.view.View
import io.flutter.plugin.platform.PlatformView

class FlutterPlatformView(
    private var view: View?,
    /**
     * Invoked once when the Flutter engine disposes this PlatformView (widget
     * unmount). Native ads use this to destroy the core AdropNativeAdView
     * (VisibilityTracker release + backfill handler cleanup). Banners pass null.
     */
    private val onDispose: (() -> Unit)? = null
) : PlatformView {

    override fun getView(): View? {
        return view
    }

    override fun dispose() {
        onDispose?.invoke()
        view = null
    }
}