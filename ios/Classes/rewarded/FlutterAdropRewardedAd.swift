import Foundation
import Flutter
import AdropAds


class FlutterAdropRewardedAd: NSObject, AdropAd, AdropRewardedAdDelegate {
    
    private let messenger:FlutterBinaryMessenger
    private let adropEventListenerChannel: FlutterMethodChannel?
    private let requestId: String
    private let rewardedAd: AdropRewardedAd
    
    init(
        unitId: String,
        requesetId: String,
        messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            self.requestId = requesetId
            let methodChannelName = AdropChannel.adropEventListenerChannel(adType: AdType.rewarded, id: requesetId)
            self.adropEventListenerChannel = methodChannelName != nil ? FlutterMethodChannel(name: methodChannelName!, binaryMessenger: messenger) : nil
            
            self.rewardedAd = AdropRewardedAd(unitId: unitId)
        }
    
    func load() {
        self.rewardedAd.delegate = self
        rewardedAd.load()
    }
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        guard let viewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        rewardedAd.show(fromRootViewController: viewController) { [weak self] type, amount in
            guard let strongSelf = self else { return }
            strongSelf.adropEventListenerChannel?.invokeMethod(AdropMethod.HANDLE_EARN_REWARD,
                                            arguments: ["type": type, "amount": amount])
        }
    }
    
    func onAdReceived(_ ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: nil)
    }
    
    func onAdFailedToReceive(_ ad: AdropRewardedAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: ["errorCode":AdropErrorCodeToString(code: errorCode)])
    }
    
    
    func onAdImpression(_ ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, arguments: nil)
    }
    
    func onAdClicked(_ ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, arguments: nil)
    }
    
    func onAdWillPresentFullScreen(_ ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.WILL_PRESENT_FULL_SCREEN, arguments: nil)
    }
    
    func onAdDidPresentFullScreen(_ ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_PRESENT_FULL_SCREEN, arguments: nil)
    }
    
    func onAdWillDismissFullScreen(_ ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.WILL_DISMISS_FULL_SCREEN, arguments: nil)
    }
    
    func onAdDidDismissFullScreen(_ ad: AdropRewardedAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_DISMISS_FULL_SCREEN, arguments: nil)
    }
    
    func onAdFailedToShowFullScreen(_ ad: AdropRewardedAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAIL_TO_SHOW_FULL_SCREEN, arguments: ["errorCode": AdropErrorCodeToString(code: errorCode)])
    }
}
