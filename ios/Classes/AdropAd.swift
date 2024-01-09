import UIKit

enum AdType: String, CaseIterable {
    case undefined
    case interstitial = "interstitial"
    case rewarded = "rewarded"
}

protocol AdropAd: NSObject {

    func load()
    
    func show()
    
}
