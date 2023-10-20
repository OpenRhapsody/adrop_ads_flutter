//
//  CallCreateBanner.swift
//  adrop_ads_flutter
//
//  Created by aaron on 2023/10/19.
//

import Foundation
import AdropAds

struct CallCreateBanner {
    var unitId: String
    var adSize: AdropBannerSize

    init(unitId: String, adSize: AdropBannerSize) {
        self.unitId = unitId
        self.adSize = adSize
    }

    init(encoding: [String: Any?]?) {
        self.unitId = encoding?["unitId"] as? String ?? ""
        if let adSizeRawValue = encoding?["adSize"] as? String,
           let adSize = AdropBannerSize(rawValue: adSizeRawValue) {
            self.adSize = adSize
        } else {
            self.adSize = .H50
        }
    }
}
