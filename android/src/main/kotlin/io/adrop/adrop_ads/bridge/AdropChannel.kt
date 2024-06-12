package io.adrop.adrop_ads.bridge

import io.adrop.adrop_ads.AdType

object AdropChannel {
    const val INVOKE_CHANNEL = "io.adrop.adrop-ads"
    const val BANNER_EVENT_LISTENER_CHANNEL = "$INVOKE_CHANNEL/banner"

    fun adropEventListenerChannelOf(adType: AdType, id: String): String? {
        return when (adType) {
            AdType.Interstitial -> "$INVOKE_CHANNEL/interstitial_$id"
            AdType.Rewarded -> "$INVOKE_CHANNEL/rewarded_$id"
            AdType.Popup -> "$INVOKE_CHANNEL/popup_$id"
            AdType.Undefined -> null
        }
    }
}
