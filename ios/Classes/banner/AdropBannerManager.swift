import Foundation
import Flutter
import AdropAds

class AdropBannerManager: NSObject, AdropBannerDelegate {
    let messenger: FlutterBinaryMessenger
    var ads: [String: AdropBanner?] = [:]
    var requestIdMap: [AdropBanner: String] = [:]
    var received: [String: Bool] = [:]

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(unitId: String, requestId: String) -> AdropBanner {
        let key = keyOf(unitId, requestId)
        if let banner = ads[key] { return banner! }
        let banner = AdropBanner(unitId: unitId)
        banner.delegate = self
        ads[key] = banner
        requestIdMap[banner] = requestId

        return banner
    }

    func load(unitId: String, requestId: String) {
        create(unitId: unitId, requestId: requestId).load()
    }

    func getAd(unitId: String, requestId: String) -> AdropBanner? {
        return ads[keyOf(unitId, requestId)] as? AdropBanner
    }

    func destroy(unitId: String, requestId: String) {
        let key = keyOf(unitId, requestId)

        DispatchQueue.main.async { [weak self] in
            guard let optionalBanner = self?.ads[key], let banner = optionalBanner else {
                return
            }

            self?.ads.removeValue(forKey: key)
            self?.requestIdMap.removeValue(forKey: banner)
        }
    }

    private func keyOf(_ unitId: String, _ requestId: String) -> String {
        return "\(unitId)_\(requestId)"
    }

    private func adropChannel()-> FlutterMethodChannel {
        return FlutterMethodChannel(name: AdropChannel.invokeChannel, binaryMessenger: messenger)
    }

    func onAdClicked(_ banner: AdropAds.AdropBanner) {
        let args: [String: Any] = ["unitId": banner.unitId, "creativeId": banner.creativeId, "requestId": requestIdMap[banner]]
        adropChannel().invokeMethod(AdropMethod.DID_CLICK_AD, arguments: args)
    }

    func onAdFailedToReceive(_ banner: AdropBanner, _ error: AdropErrorCode) {
        let args: [String: Any] = ["unitId": banner.unitId, "error": AdropErrorCodeToString(code: error), "requestId": requestIdMap[banner]]
        adropChannel().invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: args)

    }

    func onAdReceived(_ banner: AdropBanner) {
        let args: [String: Any] = [
            "unitId": banner.unitId,
            "creativeId": banner.creativeId,
            "requestId": requestIdMap[banner],
            "creativeSizeWidth": banner.creativeSize.width,
            "creativeSizeHeight": banner.creativeSize.height
        ]
        adropChannel().invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: args)
    }
}
