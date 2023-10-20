package com.openrhapsody.adrop_ads_flutter

import android.app.Activity
import android.app.Application
import android.content.Context
import androidx.annotation.NonNull
import com.openrhapsody.adrop_ads_flutter.banner.AdropBannerViewFactory
import com.openrhapsody.adrop_ads_flutter.bridge.AdropChannel
import com.openrhapsody.adrop_ads_flutter.bridge.AdropError
import com.openrhapsody.adrop_ads_flutter.bridge.AdropMethod
import com.openrhapsody.ads.model.AdropErrorCode
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

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, AdropChannel.METHOD_CHANNEL)
        channel.setMethodCallHandler(this)

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            AdropChannel.METHOD_BANNER_CHANNEL,
            AdropBannerViewFactory(flutterPluginBinding.binaryMessenger),
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