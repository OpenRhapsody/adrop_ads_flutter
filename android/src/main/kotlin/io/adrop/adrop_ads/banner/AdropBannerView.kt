package io.adrop.adrop_ads.banner

import android.content.Context
import android.view.View
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropError
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.adrop_ads.model.CallCreateBanner

import io.adrop.ads.banner.AdropBanner
import io.adrop.ads.banner.AdropBannerListener
import io.adrop.ads.model.AdropErrorCode
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class AdropBannerView(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    callData: CallCreateBanner,
    private val bannerManager: AdropBannerManager
) : PlatformView, MethodChannel.MethodCallHandler, AdropBannerListener {
    private val methodChannel: MethodChannel
    private var unitId: String
    private var errorView: View

    init {
        unitId = callData.unitId
        val banner = bannerManager.create(unitId)

        banner?.apply { listener = this@AdropBannerView }

        errorView = View(context)

        methodChannel = MethodChannel(messenger, AdropChannel.methodBannerChannelOf(viewId))
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return bannerManager.getAd(unitId) ?: errorView
    }

    override fun dispose() {
        bannerManager.destroy(unitId)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                AdropMethod.LOAD_BANNER -> {
                    bannerManager.load(unitId)
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

    override fun onAdClicked(banner: AdropBanner) {
        methodChannel.invokeMethod(AdropMethod.DID_CLICK_AD, banner.getUnitId())
        bannerManager.onAdClicked(banner)
    }

    override fun onAdFailedToReceive(banner: AdropBanner, error: AdropErrorCode) {
        val args = mapOf<String, String?>("unitId" to banner.getUnitId(), "error" to error.name)
        methodChannel.invokeMethod(AdropMethod.DID_FAIL_TO_RECEIVE_AD, args)
        bannerManager.onAdFailedToReceive(banner, error)
    }

    override fun onAdReceived(banner: AdropBanner) {
        methodChannel.invokeMethod(AdropMethod.DID_RECEIVE_AD, banner.getUnitId())
        bannerManager.onAdReceived(banner)
    }
}
