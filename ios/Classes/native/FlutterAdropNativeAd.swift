import Foundation
import Flutter
import AdropAds


class FlutterAdropNativeAd: NSObject, AdropAd, AdropNativeAdDelegate {

    private let messenger:FlutterBinaryMessenger
    private let adropEventListenerChannel: FlutterMethodChannel?
    private let requestId: String
    let nativeAd: AdropNativeAd

    init(
        unitId: String,
        requestId: String,
        useCustomClick: Bool,
        messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            self.requestId = requestId
            let methodChannelName = AdropChannel.adropEventListenerChannel(adType: .native, id: requestId)
            self.adropEventListenerChannel = methodChannelName != nil ? FlutterMethodChannel(name: methodChannelName!, binaryMessenger: messenger) : nil
            self.nativeAd = AdropNativeAd(unitId: unitId)
            self.nativeAd.useCustomClick = useCustomClick
        }

    func load() {
        self.nativeAd.delegate = self
        nativeAd.load()
    }

    func show() {

    }

    func onAdClicked(_ ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, arguments: nil)
    }

    func onAdReceived(_ ad: AdropNativeAd) {
        let arguments: [String: Any] = [
            "creativeId": ad.creativeId,
            "headline": ad.headline,
            "body": ad.body,
            "displayLogo": ad.profile.displayLogo,
            "displayName": ad.profile.displayName,
            "extra": dictionaryToJSONString(ad.extra),
            "asset": ad.asset,
            "destinationURL": ad.destinationURL,
            "creative": ad.creative,
            "creativeSizeWidth": ad.creativeSize.width,
            "creativeSizeHeight": ad.creativeSize.height
        ]
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: arguments)
    }

    func onAdFailedToReceive(_ ad: AdropNativeAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: ["errorCode":AdropErrorCodeToString(code: errorCode)])
    }

    func dictionaryToJSONString(_ dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            return "{}"
        }
    }
}
