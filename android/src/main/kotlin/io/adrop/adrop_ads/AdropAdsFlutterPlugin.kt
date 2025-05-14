package io.adrop.adrop_ads

import android.app.Activity
import android.app.Application
import android.content.Context
import androidx.annotation.NonNull
import io.adrop.adrop_ads.banner.AdropBannerManager
import io.adrop.adrop_ads.banner.AdropBannerViewFactory
import io.adrop.adrop_ads.bridge.AdropChannel
import io.adrop.adrop_ads.bridge.AdropError
import io.adrop.adrop_ads.bridge.AdropMethod
import io.adrop.adrop_ads.metrics.FlutterAdropMetrics
import io.adrop.adrop_ads.native.AdropNativeAdViewFactory
import io.adrop.ads.Adrop
import io.adrop.ads.metrics.AdropEventParam
import io.adrop.ads.metrics.AdropMetrics
import io.adrop.ads.model.AdropErrorCode
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class AdropAdsFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var activity: Activity? = null
    private var context: Context? = null

    private lateinit var invokeChannel: MethodChannel
    private lateinit var bannerManager: AdropBannerManager
    private lateinit var messenger: BinaryMessenger
    private val adManager = AdropAdManager()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        messenger = flutterPluginBinding.binaryMessenger
        invokeChannel = MethodChannel(messenger, AdropChannel.INVOKE_CHANNEL)
        invokeChannel.setMethodCallHandler(this)
        bannerManager = AdropBannerManager(context, messenger)

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            AdropChannel.BANNER_EVENT_LISTENER_CHANNEL,
            AdropBannerViewFactory(bannerManager),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            AdropChannel.NATIVE_EVENT_LISTENER_CHANNEL,
            AdropNativeAdViewFactory(adManager),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        invokeChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        try {
            when (call.method) {
                AdropMethod.INITIALIZE -> {
                    val production = call.argument("production") as Boolean? ?: false
                    val targetCountries = call.argument("targetCountries") as List<String>?
                    initialize(production, targetCountries?.toTypedArray())
                    result.success(null)
                }
                AdropMethod.SET_UID -> {
                    val uid = call.argument("uid") as String? ?: ""
                    if (uid.isEmpty()) {
                        result.error(
                            AdropErrorCode.ERROR_CODE_INTERNAL.name,
                            "Invalid uid",
                            "Expected not empty string"
                        )
                        return
                    }

                    Adrop.setUID(uid)
                    result.success(null)
                }

                AdropMethod.SET_PROPERTY -> {
                    val key = call.argument("key") as String? ?: ""
                    val value = call.argument("value") as Any? ?: arrayOf<Int>()

                    FlutterAdropMetrics.setProperty(key, value)

                    result.success(null)
                }

                AdropMethod.GET_PROPERTY -> {
                    result.success(FlutterAdropMetrics.properties())
                }

                AdropMethod.LOG_EVENT -> {
                    val name = call.argument("name") as String? ?: ""
                    val mapValue = call.argument("params") as? Map<String, Any> ?: HashMap()

                    val builder = AdropEventParam.Builder()
                    mapValue.keys.forEach {
                        when (val value = mapValue[it]) {
                            is String -> builder.putString(it, value)
                            is Int -> builder.putInt(it, value)
                            is Float -> builder.putFloat(it, value)
                            is Double -> builder.putFloat(it, value.toFloat())
                            is Boolean -> builder.putBoolean(it, value)
                            else -> {}
                        }
                    }

                    AdropMetrics.logEvent(name, builder.build())
                    result.success(null)
                }

                AdropMethod.LOAD_BANNER -> {
                    val unitId = call.argument("unitId") as String? ?: ""
                    val requestId = call.argument("requestId") as String? ?: ""
                    bannerManager.load(unitId, requestId)
                    result.success(null)
                }

                AdropMethod.DISPOSE_BANNER -> {
                    val unitId = call.argument("unitId") as String? ?: ""
                    val requestId = call.argument("requestId") as String? ?: ""
                    bannerManager.destroy(unitId, requestId)
                    result.success(null)
                }

                AdropMethod.LOAD_AD -> {
                    if (context == null) {
                        result.error(AdropErrorCode.ERROR_CODE_INITIALIZE.name, "method call received before context initialized", null)
                        return
                    }
                    val adTypeIndex = call.argument("adType") as Int? ?: 0
                    if (adTypeIndex == AdType.Undefined.ordinal) {
                        result.error(AdropErrorCode.ERROR_CODE_INTERNAL.name, "AdType is undefined", "Expected adType enum index larger than 0")
                        return
                    }
                    adManager.load(
                        context!!,
                        AdType.values()[adTypeIndex],
                        call.argument("unitId") as String? ?: "",
                        call.argument("requestId") as String? ?: "",
                        messenger
                    )
                    result.success(null)
                }

                AdropMethod.SHOW_AD -> {
                    if (activity == null) {
                        result.error(AdropErrorCode.ERROR_CODE_INITIALIZE.name, "method call received before activity initialized", null)
                        return
                    }
                    val adTypeIndex = call.argument("adType") as Int? ?: 0
                    if (adTypeIndex == AdType.Undefined.ordinal) {
                        result.error(AdropErrorCode.ERROR_CODE_INTERNAL.name, "AdType is undefined", "Expected adType enum index larger than 0")
                        return
                    }

                    val requestId = call.argument("requestId") as String? ?: ""

                    adManager.show(
                        AdType.values()[adTypeIndex],
                        requestId,
                        activity!!
                    )
                    result.success(null)
                }

                AdropMethod.CUSTOMIZE_AD -> {
                    val adTypeIndex = call.argument("adType") as Int? ?: 0
                    if (adTypeIndex == AdType.Undefined.ordinal) {
                        result.error(AdropErrorCode.ERROR_CODE_INTERNAL.name, "AdType is undefined", "Expected adType enum index larger than 0")
                        return
                    }

                    adManager.customize(
                        AdType.values()[adTypeIndex],
                        call.argument("requestId") as String? ?: "",
                        call.argument("data") as? Map<String, Any> ?: HashMap()
                        )
                    result.success(null)
                }

                AdropMethod.DISPOSE_AD -> {
                    val adTypeIndex = call.argument("adType") as Int? ?: 0
                    if (adTypeIndex == AdType.Undefined.ordinal) {
                        result.error(AdropErrorCode.ERROR_CODE_INTERNAL.name, "AdType is undefined", "Expected adType enum index larger than 0")
                        return
                    }
                    adManager.destroy(
                        AdType.values()[adTypeIndex],
                        call.argument("requestId") as String? ?: ""
                    )
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

    @Throws(AdropError::class)
    private fun initialize(production: Boolean?, targetCountries: Array<String>? = null) {
        val context = context ?: return
        if (context is Application) {
            Adrop.initialize(context, production ?: false, targetCountries ?: arrayOf())
            return
        } else {
            throw AdropError(AdropErrorCode.ERROR_CODE_INITIALIZE)
        }
    }

    /** ActivityAware **/

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        this.context = binding.activity.applicationContext
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        this.context = binding.activity.applicationContext
    }

    override fun onDetachedFromActivity() {
    }
}
