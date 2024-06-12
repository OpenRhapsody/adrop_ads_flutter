import UIKit

enum AdType: String, CaseIterable {
    case undefined
    case interstitial = "interstitial"
    case rewarded = "rewarded"
    case popup = "popup"
}

protocol AdropAd: NSObject {

    func load()

    func show()

}
