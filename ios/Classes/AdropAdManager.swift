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
    
    func destroy(adType: AdType, requestId: String) {
        let key = keyOf(adType, requestId)
        if self.ads[key] != nil {
            self.ads.removeValue(forKey: key)
        }
    }
    
    func createAd(adType: AdType, unitId: String, requestId: String) -> AdropAd? {
        switch adType {
        case AdType.interstitial:
            return FlutterAdropInterstitialAd(unitId: unitId, requesetId: requestId, messenger: messenger)
        case AdType.rewarded:
            return FlutterAdropRewardedAd(unitId: unitId, requesetId: requestId, messenger: messenger)
        case AdType.undefined:
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
