import Foundation
import Flutter
import AdropAds


class FlutterAdropInterstitialAd: NSObject, AdropAd, AdropInterstitialAdDelegate {
    
    private let messenger:FlutterBinaryMessenger
    private let adropEventListenerChannel: FlutterMethodChannel?
    private let requestId: String
    private let interstitialAd: AdropInterstitialAd
    
    init(
        unitId: String,
        requesetId: String,
        messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            self.requestId = requesetId
            let methodChannelName = AdropChannel.adropEventListenerChannel(adType: AdType.interstitial, id: requesetId)
            self.adropEventListenerChannel = methodChannelName != nil ? FlutterMethodChannel(name: methodChannelName!, binaryMessenger: messenger) : nil
            
            self.interstitialAd = AdropInterstitialAd(unitId: unitId)
        }
    
    func load() {
        self.interstitialAd.delegate = self
        interstitialAd.load()
    }
    
    func show() {
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        
        guard let viewController = appDelegate.window??.rootViewController else {
            return
        }
        
        interstitialAd.show(fromRootViewController: viewController)
    }
    
    func onAdReceived(_ ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: nil)
    }
    
    func onAdFailedToReceive(_ ad: AdropInterstitialAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: ["errorCode":AdropErrorCodeToString(code: errorCode)])
    }
    
    
    func onAdImpression(_ ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, arguments: nil)
    }
    
    func onAdClicked(_ ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, arguments: nil)
    }
    
    func onAdWillPresentFullScreen(_ ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.WILL_PRESENT_FULL_SCREEN, arguments: nil)
    }
    
    func onAdDidPresentFullScreen(_ ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_PRESENT_FULL_SCREEN, arguments: nil)
    }
    
    func onAdWillDismissFullScreen(_ ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.WILL_DISMISS_FULL_SCREEN, arguments: nil)
    }
    
    func onAdDidDismissFullScreen(_ ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_DISMISS_FULL_SCREEN, arguments: nil)
    }
    
    func onAdFailedToShowFullScreen(_ ad: AdropInterstitialAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_SHOW_FULL_SCREEN, arguments: ["errorCode": AdropErrorCodeToString(code: errorCode)])
    }
}
