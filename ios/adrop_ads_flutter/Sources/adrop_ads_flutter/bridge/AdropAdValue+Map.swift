import Foundation
import AdropAds

/// Serializes `AdropAdValue` for the Dart side.
///
/// Single source of truth for the payload — the keys and the `precision` spelling must match
/// `AdropAdValue.fromMap` in `lib/src/model/adrop_ad_value.dart` and the Android counterpart
/// (`AdropAdValueMap.kt`). Keeping one copy per platform is what stops the two bridges from
/// drifting apart.
extension AdropAdValue {
    func toMap() -> [String: Any] {
        var map: [String: Any] = [
            "network": network,
            "valueMicros": valueMicros,
            "currencyCode": currencyCode,
            "precision": precision.channelName
        ]
        // Omit rather than send NSNull, so Dart reads it as a plain null.
        if let adSourceName = adSourceName {
            map["adSourceName"] = adSourceName
        }
        return map
    }
}

extension AdropAdValuePrecision {
    /// Stable wire name, matching the Android and Dart spellings.
    var channelName: String {
        switch self {
        case .unknown: return "unknown"
        case .estimated: return "estimated"
        case .publisherProvided: return "publisherProvided"
        case .precise: return "precise"
        @unknown default: return "unknown"
        }
    }
}
