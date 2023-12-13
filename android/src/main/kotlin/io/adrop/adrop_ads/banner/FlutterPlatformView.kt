package io.adrop.adrop_ads.banner

import android.view.View
import io.flutter.plugin.platform.PlatformView;

class FlutterPlatformView(
    private var view: View?
) : PlatformView {

    override fun getView(): View? {
        return view
    }

    override fun dispose() {
        view = null
    }
}