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
