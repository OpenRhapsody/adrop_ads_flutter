package com.openrhapsody.adrop_ads_flutter.banner

import android.content.Context
import android.view.View
import com.openrhapsody.adrop_ads_flutter.bridge.AdropChannel
import com.openrhapsody.adrop_ads_flutter.bridge.AdropError
import com.openrhapsody.adrop_ads_flutter.bridge.AdropMethod
import com.openrhapsody.adrop_ads_flutter.model.CallCreateBanner
import com.openrhapsody.ads.banner.AdropBanner
import com.openrhapsody.ads.banner.AdropBannerListener
import com.openrhapsody.ads.model.AdropErrorCode
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class AdropBannerView(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    callData: CallCreateBanner,
) : PlatformView, MethodChannel.MethodCallHandler, AdropBannerListener {
    private var banner: AdropBanner
    private val methodChannel: MethodChannel

    init {
        banner = AdropBanner(context, callData.unitId)
        banner.listener = this

        methodChannel = MethodChannel(messenger, AdropChannel.methodBannerChannelOf(viewId))
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return banner
    }

    override fun dispose() {
        banner.destroy()
    }

    override fun onAdReceived() {
        methodChannel.invokeMethod(AdropMethod.DID_RECEIVE_AD, null)
    }

    override fun onAdClicked() {
        methodChannel.invokeMethod(AdropMethod.DID_CLICK_AD, null)
    }

    override fun onAdFailedToReceive(error: AdropErrorCode) {
        methodChannel.invokeMethod(AdropMethod.DID_FAIL_TO_RECEIVE_AD, error.name)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                AdropMethod.LOAD_BANNER -> {
                    banner.load()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        } catch (e: AdropError) {
            result.error(e.code, e.message, null)
        } catch (e: Exception) {
            e.printStackTrace()
        } catch (e: Error) {
            e.printStackTrace()
        }
    }
}