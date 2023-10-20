package com.openrhapsody.adrop_ads_flutter.model

import com.openrhapsody.ads.banner.AdropBannerSize

data class CallCreateBanner(
    var unitId: String,
    var adSize: AdropBannerSize
) {
    constructor(encoding: Map<String, Any?>?) : this(
        unitId = encoding?.get("unitId") as? String ?: "",
        adSize = AdropBannerSize.valueOf(encoding?.get("adSize") as? String ?: AdropBannerSize.H50.name)
    )
}