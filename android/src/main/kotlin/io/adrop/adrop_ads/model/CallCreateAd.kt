package io.adrop.adrop_ads.model


data class CallCreateAd(
    var unitId: String,
    var requestId: String = "",
    var useCustomClick: Boolean = false
) {
    constructor(encoding: Map<String, Any?>?) : this(
        unitId = encoding?.get("unitId") as? String ?: "",
        requestId = encoding?.get("requestId") as? String ?: "",
        useCustomClick = encoding?.get("useCustomClick") as? Boolean ?: false
    )
}