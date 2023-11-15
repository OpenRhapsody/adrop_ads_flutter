import Foundation
import Flutter
import AdropAds

class AdropBannerManager: NSObject, AdropBannerDelegate {
    let messenger: FlutterBinaryMessenger
    var ads: [String: AdropBanner?] = [:]
    var received: [String: Bool] = [:]
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(unitId: String) -> AdropBanner {
        if let banner = ads[unitId] { return banner! }
        let banner = AdropBanner(unitId: unitId)
        banner.delegate = self
        ads[unitId] = banner
        
        return banner
    }
    
    func load(unitId: String) {
        create(unitId: unitId).load()
    }
    
    func getAd(unitId: String) -> AdropBanner? {
        return ads[unitId] as? AdropBanner
    }
    
    func destroy(unitId: String) {
        if ads[unitId] != nil {
            ads.removeValue(forKey: unitId)
        }
    }
    
    private func adropChannel()-> FlutterMethodChannel {
        return FlutterMethodChannel(name: AdropChannel.methodChannel, binaryMessenger: messenger)
    }
    
    func onAdClicked(_ banner: AdropAds.AdropBanner) {
        adropChannel().invokeMethod(AdropMethod.DID_CLICK_AD, arguments: banner.id)
    }
    
    func onAdFailedToReceive(_ banner: AdropBanner, _ error: AdropErrorCode) {
        let args: [String: Any] = ["unitId": banner.id, "error": AdropErrorCodeToString(code: error)]
        adropChannel().invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: args)
        
    }
    
    func onAdReceived(_ banner: AdropBanner) {
        adropChannel().invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: banner.id)
    }
}
