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
import io.adrop.ads.Adrop
import io.adrop.ads.model.AdropErrorCode
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AdropAdsFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var activity: Activity? = null
    private var context: Context? = null

    private lateinit var channel: MethodChannel
    private lateinit var bannerManager: AdropBannerManager

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        val messenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(messenger, AdropChannel.METHOD_CHANNEL)
        channel.setMethodCallHandler(this)
        bannerManager = AdropBannerManager(context, messenger)

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            AdropChannel.METHOD_BANNER_CHANNEL,
            AdropBannerViewFactory(messenger, bannerManager),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        try {
            when (call.method) {
                AdropMethod.INITIALIZE -> {
                    initialize(call.arguments())
                    result.success(null)
                }

                AdropMethod.LOAD_BANNER -> {
                    bannerManager.load(call.arguments() ?: "")
                    result.success(null)
                }

                AdropMethod.AD_DISPOSE -> {
                    bannerManager.destroy(call.arguments() ?: "")
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
    private fun initialize(production: Boolean?) {
        val context = context ?: return
        if (context is Application) {
            Adrop.initialize(context, production ?: false)
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
