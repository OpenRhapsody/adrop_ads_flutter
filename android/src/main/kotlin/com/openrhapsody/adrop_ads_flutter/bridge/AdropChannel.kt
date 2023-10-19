package com.openrhapsody.adrop_ads_flutter.bridge

object AdropChannel {
    const val METHOD_CHANNEL = "com.openrhapsody.adrop-ads"
    const val METHOD_BANNER_CHANNEL = "$METHOD_CHANNEL/banner"

    fun methodBannerChannelOf(id: Int): String = "${METHOD_BANNER_CHANNEL}_${id}"
}