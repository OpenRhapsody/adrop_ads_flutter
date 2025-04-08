import Foundation
import Flutter
import AdropAds

class AdropAdManager: NSObject {
    private let messenger: FlutterBinaryMessenger
    private var ads: [String: AdropAd?] = [:]

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    func load(adType: AdType, unitId: String, requestId: String) {
        let ad = getAd(adType: adType, requestId: requestId)
        ?? createAd(adType: adType, unitId: unitId, requestId: requestId)
        let key = keyOf(adType, requestId)
        if self.ads[key] == nil {
            self.ads[key] = ad
        }

        ad?.load()
    }

    func show(adType: AdType, requestId: String) {
        if let ad = self.ads[keyOf(adType, requestId)] {
            ad?.show()
        }
    }

    func customize(adType: AdType, requestId: String, data: [String:Any]) {
        switch adType {
        case AdType.popup:
            guard let ad = self.ads[self.keyOf(adType, requestId)] as? FlutterAdropPopupAd else { return }

            ad.customize(data)
        default:
            return
        }
    }

    func destroy(adType: AdType, requestId: String) {
        let key = keyOf(adType, requestId)

        switch adType {
        case AdType.popup:
            guard let ad = self.ads[self.keyOf(adType, requestId)] as? FlutterAdropPopupAd else { return }
            
            DispatchQueue.main.async { [weak self] in
                ad.destroy()
                self?.removeAds(key)
            }
            
        default:
            removeAds(key)
        }
    }
    
    private func removeAds(_ key: String) {
        DispatchQueue.main.async { [weak self] in
            self?.ads.removeValue(forKey: key)
        }
    }

    func createAd(adType: AdType, unitId: String, requestId: String) -> AdropAd? {
        switch adType {
        case .interstitial:
            return FlutterAdropInterstitialAd(unitId: unitId, requestId: requestId, messenger: messenger)
        case .rewarded:
            return FlutterAdropRewardedAd(unitId: unitId, requestId: requestId, messenger: messenger)
        case .popup:
            return FlutterAdropPopupAd(unitId: unitId, requestId: requestId, messenger: messenger)
        case .native:
            return FlutterAdropNativeAd(unitId: unitId, requestId: requestId, messenger: messenger)
        case .undefined:
            return nil
        }
    }

    func getAd(adType: AdType, requestId: String) -> AdropAd? {
        guard let ad = self.ads[keyOf(adType, requestId)] else {
            return nil
        }

        return ad

    }

    private func keyOf(_ adType: AdType, _ requestId: String) -> String {
        return "\(adType)/\(requestId)"
    }
}
