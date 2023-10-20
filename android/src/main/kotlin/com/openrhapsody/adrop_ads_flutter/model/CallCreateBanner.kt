package com.openrhapsody.adrop_ads_flutter.model

data class CallCreateBanner(
    var unitId: String
) {
    constructor(encoding: Map<String, Any?>?) : this(
        unitId = encoding?.get("unitId") as? String ?: ""
    )
}