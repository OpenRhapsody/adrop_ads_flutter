import Foundation
import Flutter
import AdropAds

class FlutterAdropPopupAd: NSObject, AdropAd, AdropPopupAdDelegate {
    
    private let messenger:FlutterBinaryMessenger
    private let adropEventListenerChannel: FlutterMethodChannel?
    private let requestId: String
    private let popupAd: AdropPopupAd
    
    init(
        unitId: String,
        requesetId: String,
        messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            self.requestId = requesetId
            let methodChannelName = AdropChannel.adropEventListenerChannel(adType: AdType.popup, id: requesetId)
            self.adropEventListenerChannel = methodChannelName != nil ? FlutterMethodChannel(name: methodChannelName!, binaryMessenger: messenger) : nil
            
            self.popupAd = AdropPopupAd(unitId: unitId)
        }
    
    func load() {
        self.popupAd.delegate = self
        popupAd.load()
    }
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        guard let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        popupAd.show(fromRootViewController: rootViewController)
    }
    
    func customize(_ data: [String:Any]) {
        if let closeTextColor = data["closeTextColor"] as? UInt32 {
            popupAd.closeTextColor = UIColor(fromFlutterColor: closeTextColor)
        }
        if let hideForTodayTextColor = data["hideForTodayTextColor"] as? UInt32 {
            popupAd.hideForTodayTextColor = UIColor(fromFlutterColor: hideForTodayTextColor)
        }
        if let backgroundColor = data["backgroundColor"] as? UInt32 {
            popupAd.backgroundColor = UIColor(fromFlutterColor: backgroundColor)
        }
    }
    
    func onAdReceived(_ ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: nil)
    }
    
    func onAdFailedToReceive(_ ad: AdropPopupAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: ["errorCode":AdropErrorCodeToString(code: errorCode)])
    }
    
    
    func onAdImpression(_ ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, arguments: nil)
    }
    
    func onAdClicked(_ ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, arguments: nil)
    }
    
    func onAdWillPresentFullScreen(_ ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.WILL_PRESENT_FULL_SCREEN, arguments: nil)
    }
    
    func onAdDidPresentFullScreen(_ ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_PRESENT_FULL_SCREEN, arguments: nil)
    }
    
    func onAdWillDismissFullScreen(_ ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.WILL_DISMISS_FULL_SCREEN, arguments: nil)
    }
    
    func onAdDidDismissFullScreen(_ ad: AdropPopupAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_DISMISS_FULL_SCREEN, arguments: nil)
    }
    
    func onAdFailedToShowFullScreen(_ ad: AdropPopupAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_SHOW_FULL_SCREEN, arguments: ["errorCode": AdropErrorCodeToString(code: errorCode)])
    }
}
