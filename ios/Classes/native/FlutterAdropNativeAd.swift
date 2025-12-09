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
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_CLICK_AD, arguments: metadataOf(ad))
    }

    func onAdReceived(_ ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: metadataOf(ad))
    }

    func onAdFailedToReceive(_ ad: AdropNativeAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: ["errorCode":AdropErrorCodeToString(code: errorCode)])
    }

    func onAdImpression(_ ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, arguments: metadataOf(ad))
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

    private func metadataOf(_ ad: AdropNativeAd) -> [String: Any] {
        var creative = ad.creative
        let adPlayerCallback = "window.adPlayerVisibilityCallback"
        if creative.contains(adPlayerCallback) {
            creative = creative.replacingOccurrences(of: adPlayerCallback, with: "callback(true);\(adPlayerCallback)")
        }

        return [
            "creativeId": ad.creativeId,
            "headline": ad.headline,
            "body": ad.body,
            "displayLogo": ad.profile.displayLogo,
            "displayName": ad.profile.displayName,
            "extra": dictionaryToJSONString(ad.extra) ?? "",
            "asset": ad.asset,
            "destinationURL": ad.destinationURL ?? "",
            "creative": creative,
            "creativeSizeWidth": ad.creativeSize.width,
            "creativeSizeHeight": ad.creativeSize.height,
            "txId": ad.txId,
            "campaignId": ad.campaignId,
            "isBackfilled": ad.isBackfilled,
            "callToAction": ad.callToAction
        ]
    }
}
