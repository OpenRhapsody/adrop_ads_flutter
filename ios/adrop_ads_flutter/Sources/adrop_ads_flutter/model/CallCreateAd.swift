import Foundation
import AdropAds

struct CallCreateAd {
    var unitId: String
    var requestId: String
    
    init(unitId: String, requestId: String) {
        self.unitId = unitId
        self.requestId = requestId
    }
    
    init(encoding: [String: Any?]?) {
        self.unitId = encoding?["unitId"] as? String ?? ""
        self.requestId = encoding?["requestId"] as? String ?? ""
    }
}
