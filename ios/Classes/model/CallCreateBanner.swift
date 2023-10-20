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

    init(unitId: String) {
        self.unitId = unitId
    }

    init(encoding: [String: Any?]?) {
        self.unitId = encoding?["unitId"] as? String ?? ""
    }
}
