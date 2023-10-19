package com.openrhapsody.adrop_ads_flutter.banner

import android.content.Context
import com.openrhapsody.adrop_ads_flutter.model.CallCreateBanner

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AdropBannerViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val callData = CallCreateBanner(args as? Map<String, Any?>)
        return AdropBannerView(context, viewId, messenger, callData)
    }
}