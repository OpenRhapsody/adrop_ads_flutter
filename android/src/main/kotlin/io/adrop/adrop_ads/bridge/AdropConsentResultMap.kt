package io.adrop.adrop_ads.bridge

import io.adrop.ads.consent.AdropConsentResult

/**
 * Serializes [AdropConsentResult] for the Dart side.
 *
 * Single source of truth for the payload — the keys must match `AdropConsentResult.fromMap` in
 * `lib/src/consent/adrop_consent_result.dart` and the iOS counterpart (`AdropConsentResult+Map.swift`).
 * requestConsentInfoUpdate and showPrivacyOptionsForm both answer with this payload.
 */
fun AdropConsentResult.toMap(): Map<String, Any?> = mapOf(
    "status" to status.value,
    "canRequestAds" to canRequestAds,
    "canShowPersonalizedAds" to canShowPersonalizedAds,
    "error" to error?.message
)
