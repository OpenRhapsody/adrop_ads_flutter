package io.adrop.adrop_ads.bridge

import io.adrop.ads.model.AdropAdValue
import io.adrop.ads.model.AdropAdValuePrecision

/**
 * Serializes [AdropAdValue] for the Dart side.
 *
 * Single source of truth for the payload — the keys and the `precision` spelling must match
 * `AdropAdValue.fromMap` in `lib/src/model/adrop_ad_value.dart` and the iOS counterpart
 * (`AdropAdValue+Map.swift`). Keeping one copy per platform is what stops the two bridges
 * from drifting apart.
 */
fun AdropAdValue.toMap(): Map<String, Any?> = mapOf(
    "network" to network,
    "adSourceName" to adSourceName,
    "valueMicros" to valueMicros,
    "currencyCode" to currencyCode,
    "precision" to precision.channelName,
    "externalUid" to externalUid
)

/** Stable wire name; never `name.lowercase()`, which would emit `publisher_provided`. */
val AdropAdValuePrecision.channelName: String
    get() = when (this) {
        AdropAdValuePrecision.UNKNOWN -> "unknown"
        AdropAdValuePrecision.ESTIMATED -> "estimated"
        AdropAdValuePrecision.PUBLISHER_PROVIDED -> "publisherProvided"
        AdropAdValuePrecision.PRECISE -> "precise"
    }
