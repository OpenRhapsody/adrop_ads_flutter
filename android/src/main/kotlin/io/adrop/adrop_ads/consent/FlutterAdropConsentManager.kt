package io.adrop.adrop_ads.consent

import android.app.Activity
import android.content.Context
import android.provider.Settings
import io.adrop.ads.Adrop
import io.adrop.ads.consent.AdropConsentDebugGeography
import io.adrop.ads.consent.AdropConsentListener
import io.adrop.ads.consent.AdropConsentResult
import io.adrop.ads.model.AdropErrorCode
import io.flutter.plugin.common.MethodChannel.Result
import java.security.MessageDigest

class FlutterAdropConsentManager {

    fun requestConsentInfoUpdate(activity: Activity?, result: Result) {
        val consentManager = Adrop.consentManager
        if (consentManager == null) {
            result.error(
                AdropErrorCode.ERROR_CODE_INTERNAL.name,
                "ConsentManager is not available",
                "AdropAdsBackfill module is not installed"
            )
            return
        }
        if (activity == null) {
            result.error(
                AdropErrorCode.ERROR_CODE_INITIALIZE.name,
                "Activity is not available",
                null
            )
            return
        }
        consentManager.requestConsentInfoUpdate(activity, object : AdropConsentListener {
            override fun onConsentInfoUpdated(consentResult: AdropConsentResult) {
                val resultMap = hashMapOf<String, Any?>(
                    "status" to consentResult.status.value,
                    "canRequestAds" to consentResult.canRequestAds,
                    "canShowPersonalizedAds" to consentResult.canShowPersonalizedAds,
                    "error" to consentResult.error?.message
                )
                result.success(resultMap)
            }
        })
    }

    fun getConsentStatus(context: Context?, result: Result) {
        val consentManager = Adrop.consentManager
        if (consentManager == null || context == null) {
            result.success(0) // UNKNOWN
            return
        }
        val status = consentManager.getConsentStatus(context)
        result.success(status.value)
    }

    fun canRequestAds(context: Context?, result: Result) {
        val consentManager = Adrop.consentManager
        if (consentManager == null || context == null) {
            result.success(false)
            return
        }
        val canRequest = consentManager.canRequestAds(context)
        result.success(canRequest)
    }

    fun reset(context: Context?, result: Result) {
        val consentManager = Adrop.consentManager
        if (consentManager == null || context == null) {
            result.success(null)
            return
        }
        consentManager.reset(context)
        result.success(null)
    }

    fun setDebugSettings(context: Context?, geographyValue: Int, result: Result) {
        val consentManager = Adrop.consentManager
        if (consentManager == null || context == null) {
            result.success(null)
            return
        }

        val androidId = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ANDROID_ID
        )
        val hash = MessageDigest.getInstance("MD5")
            .digest(androidId.toByteArray())
            .joinToString("") { "%02X".format(it) }

        val geography = when (geographyValue) {
            0 -> AdropConsentDebugGeography.DISABLED
            1 -> AdropConsentDebugGeography.EEA
            3 -> AdropConsentDebugGeography.REGULATED_US_STATE
            4 -> AdropConsentDebugGeography.OTHER
            else -> AdropConsentDebugGeography.DISABLED
        }

        consentManager.setDebugSettings(listOf(hash), geography)
        result.success(null)
    }
}
