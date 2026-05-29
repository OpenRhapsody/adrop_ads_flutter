import Foundation
import Flutter
import AdropAds


class FlutterAdropNativeAd: NSObject, AdropAd, AdropNativeAdDelegate {

    private let messenger:FlutterBinaryMessenger
    private let adropEventListenerChannel: FlutterMethodChannel?
    private let requestId: String
    /// Invoked on `onAdReceived` for backfill ads to re-bind the PlatformView's
    /// AdropNativeAdView to the new AdMob GADNativeAd. Direct ads do not need this —
    /// they reuse the same WebView host. See `AdropNativeAdViewFactory.rebind`.
    private let nativeRebindCallback: ((String) -> Void)?
    let nativeAd: AdropNativeAd

    init(
        unitId: String,
        requestId: String,
        useCustomClick: Bool,
        preferredAdChoicesPosition: Int,
        messenger: FlutterBinaryMessenger,
        nativeRebindCallback: ((String) -> Void)? = nil) {
            self.messenger = messenger
            self.requestId = requestId
            self.nativeRebindCallback = nativeRebindCallback
            let methodChannelName = AdropChannel.adropEventListenerChannel(adType: .native, id: requestId)
            self.adropEventListenerChannel = methodChannelName != nil ? FlutterMethodChannel(name: methodChannelName!, binaryMessenger: messenger) : nil
            self.nativeAd = AdropNativeAd(unitId: unitId)
            self.nativeAd.useCustomClick = useCustomClick
            self.nativeAd.preferredAdChoicesPosition = AdropAdChoicesPosition(rawValue: preferredAdChoicesPosition) ?? .topRight
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
        // Backfill: re-bind PlatformView's AdropNativeAdView so AdMob GADNativeAdView
        // gets its nativeAd rebound. Direct ads skip — the reused WebView host updates
        // its creative HTML internally.
        if ad.isBackfilled {
            nativeRebindCallback?(requestId)
        }
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: metadataOf(ad))
    }

    func onAdFailedToReceive(_ ad: AdropNativeAd, _ errorCode: AdropErrorCode) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: ["errorCode":AdropErrorCodeToString(code: errorCode)])
    }

    func onAdImpression(_ ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_IMPRESSION, arguments: metadataOf(ad))
    }

    func onAdVideoStart(_ ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_VIDEO_START, arguments: metadataOf(ad))
    }

    func onAdVideoEnd(_ ad: AdropNativeAd) {
        adropEventListenerChannel?.invokeMethod(AdropMethod.DID_VIDEO_END, arguments: metadataOf(ad))
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
            "callToAction": ad.callToAction,
            "browserTarget": ad.browserTargetValue.rawValue,
            "creativeType": ad.creativeType
        ]
    }
}
