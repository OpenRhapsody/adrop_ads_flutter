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
        requestId: String,
        messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            self.requestId = requestId
            let methodChannelName = AdropChannel.adropEventListenerChannel(adType: AdType.interstitial, id: requestId)
            self.adropEventListenerChannel = methodChannelName != nil ? FlutterMethodChannel(name: methodChannelName!, binaryMessenger: messenger) : nil

            self.interstitialAd = AdropInterstitialAd(unitId: unitId)
        }

    func load() {
        self.interstitialAd.delegate = self
        interstitialAd.load()
    }

    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        guard let viewController = windowScene.windows.first?.rootViewController else {
            return
        }

        interstitialAd.show(fromRootViewController: viewController)
    }

    func onAdReceived(_ ad: AdropInterstitialAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: ["creativeId": ad.creativeId])
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
