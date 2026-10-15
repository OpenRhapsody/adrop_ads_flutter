import Foundation
import AdropAds

// Serializes AdropConsentResult for the Dart side.
//
// Single source of truth for the payload — the keys must match `AdropConsentResult.fromMap` in
// `lib/src/consent/adrop_consent_result.dart` and the Android counterpart (`AdropConsentResultMap.kt`).
// requestConsentInfoUpdate and showPrivacyOptionsForm both answer with this payload.
extension AdropConsentResult {
    func toMap() -> [String: Any] {
        var map: [String: Any] = [
            "status": status.rawValue,
            "canRequestAds": canRequestAds,
            "canShowPersonalizedAds": canShowPersonalizedAds
        ]
        if let error = error {
            map["error"] = error.localizedDescription
        }
        return map
    }
}
