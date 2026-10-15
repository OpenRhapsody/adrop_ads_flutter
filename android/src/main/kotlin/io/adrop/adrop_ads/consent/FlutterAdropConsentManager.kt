package io.adrop.adrop_ads.consent

import android.app.Activity
import android.content.Context
import android.provider.Settings
import io.adrop.adrop_ads.bridge.toMap
import io.adrop.ads.Adrop
import io.adrop.ads.consent.AdropConsentDebugGeography
import io.adrop.ads.consent.AdropConsentListener
import io.adrop.ads.consent.AdropConsentManager
import io.adrop.ads.consent.AdropConsentResult
import io.adrop.ads.model.AdropErrorCode
import io.flutter.plugin.common.MethodChannel.Result
import java.security.MessageDigest

class FlutterAdropConsentManager {

    fun requestConsentInfoUpdate(activity: Activity?, result: Result) {
        withManagerAndActivity(activity, result) { consentManager, foreground ->
            consentManager.requestConsentInfoUpdate(foreground, replyWith(result))
        }
    }

    fun showPrivacyOptionsForm(activity: Activity?, result: Result) {
        withManagerAndActivity(activity, result) { consentManager, foreground ->
            consentManager.showPrivacyOptionsForm(foreground, replyWith(result))
        }
    }

    fun getPrivacyOptionsRequirementStatus(context: Context?, result: Result) {
        val consentManager = Adrop.consentManager
        if (consentManager == null || context == null) {
            result.success(0) // UNKNOWN
            return
        }
        result.success(consentManager.getPrivacyOptionsRequirementStatus(context).value)
    }

    /** 양식을 띄우는 두 메서드의 공통 사전 검사 — 백필 미포함·Activity 없음은 Dart 쪽에 같은 에러로 돌려준다. */
    private inline fun withManagerAndActivity(
        activity: Activity?,
        result: Result,
        block: (AdropConsentManager, Activity) -> Unit
    ) {
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
        block(consentManager, activity)
    }

    private fun replyWith(result: Result) = object : AdropConsentListener {
        override fun onConsentInfoUpdated(consentResult: AdropConsentResult) {
            result.success(consentResult.toMap())
        }
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
