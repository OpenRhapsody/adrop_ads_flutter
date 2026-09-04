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

    /**
     * Clears the view reference WITHOUT running [onDispose]. Called when another
     * platform view adopts the same pre-loaded banner (re-attach): the engine's
     * later dispose of this wrapper removes the embedded view from its *current*
     * parent, which after the takeover is the new wrapper's parent — nulling the
     * reference first turns that removal into a no-op.
     */
    fun release() {
        view = null
    }

    override fun dispose() {
        onDispose?.invoke()
        view = null
    }
}