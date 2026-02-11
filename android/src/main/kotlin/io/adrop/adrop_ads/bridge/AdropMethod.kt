package io.adrop.adrop_ads.bridge

object AdropMethod {
    const val INITIALIZE = "initialize"
    const val SET_UID = "setUid"
    const val SET_THEME = "setTheme"
    const val LOAD_BANNER = "loadBanner"
    const val DISPOSE_BANNER = "disposeBanner"
    const val LOAD_AD = "loadAd"
    const val SHOW_AD = "showAd"
    const val CLOSE_AD = "closeAd"
    const val CUSTOMIZE_AD = "customizeAd"
    const val DISPOSE_AD = "disposeAd"
    const val SET_PROPERTY = "setProperty"
    const val GET_PROPERTY = "getProperty"
    const val LOG_EVENT = "logEvent"
    const val PERFORM_CLICK = "performClick"

    // Consent methods
    const val REQUEST_CONSENT_INFO_UPDATE = "requestConsentInfoUpdate"
    const val GET_CONSENT_STATUS = "getConsentStatus"
    const val CAN_REQUEST_ADS = "canRequestAds"
    const val RESET_CONSENT = "resetConsent"
    const val SET_CONSENT_DEBUG_SETTINGS = "setConsentDebugSettings"

    const val DID_RECEIVE_AD = "onAdReceived"
    const val DID_CLICK_AD = "onAdClicked"
    const val DID_FAIL_TO_RECEIVE_AD = "onAdFailedToReceive"

    const val DID_DISMISS_FULL_SCREEN = "onAdDidDismissFullScreen"
    const val DID_PRESENT_FULL_SCREEN = "onAdDidPresentFullScreen"
    const val DID_FAIL_TO_SHOW_FULL_SCREEN = "onAdFailedToShowFullScreen"
    const val DID_IMPRESSION = "onAdImpression"
    const val HANDLE_EARN_REWARD = "handleEarnReward"
    const val DID_BACK_BUTTON_PRESSED = "onAdBackButtonPressed"
}
