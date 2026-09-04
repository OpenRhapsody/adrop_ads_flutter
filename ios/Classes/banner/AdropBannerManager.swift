import Foundation
import Flutter
import AdropAds

class AdropBannerManager: NSObject, AdropBannerDelegate {
    let messenger: FlutterBinaryMessenger
    var ads: [String: AdropBanner?] = [:]
    var requestIdMap: [AdropBanner: String] = [:]

    /// Per-call batch delegates, held strongly until the terminal callback.
    /// REQUIRED: the core stores `AdropBanner.delegate` weakly and `loads()`
    /// captures `[weak delegate]` — without this map the delegate deallocates
    /// and the Dart Future never resolves.
    private var pendingLoadsDelegates: [String: BannerLoadsDelegate] = [:]

    /// Keys of banners delivered by the batch loads path. Swept on engine
    /// detach so their WebViews don't outlive the engine.
    private var preloadedKeys: Set<String> = []

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

    func load(unitId: String, requestId: String, width: CGFloat? = nil, height: CGFloat? = nil) {
        let banner = create(unitId: unitId, requestId: requestId)
        if let width = width, let height = height {
            banner.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        banner.load()
    }

    /// Batch load: one network call, up to 5 pre-loaded banners bound
    /// positionally to the Dart-minted requestIds. After registration each
    /// banner's delegate is swapped to this manager so per-instance events
    /// route exactly like the singular path (batch-loads-api.md §2).
    func loads(unitId: String, requestIds: [String], result: @escaping FlutterResult) {
        let batchKey = UUID().uuidString
        let delegate = BannerLoadsDelegate(
            onBatchReceived: { [weak self] banners in
                guard let self = self else { return }
                var filled: [String] = []
                var metas: [[String: Any]] = []
                for (index, banner) in banners.enumerated() {
                    if index >= requestIds.count {
                        // Cap-drift guard: native returned more rows than minted ids.
                        DispatchQueue.main.async { banner.destroy() }
                        continue
                    }
                    let requestId = requestIds[index]
                    let key = self.keyOf(unitId, requestId)
                    banner.delegate = self
                    self.ads[key] = banner
                    self.requestIdMap[banner] = requestId
                    self.preloadedKeys.insert(key)
                    filled.append(requestId)
                    metas.append(self.metadataOf(banner))
                }
                self.pendingLoadsDelegates.removeValue(forKey: batchKey)
                result(["requestIds": filled, "ads": metas])
            },
            onBatchFailed: { [weak self] errorCode in
                self?.pendingLoadsDelegates.removeValue(forKey: batchKey)
                result(FlutterError(
                    code: AdropErrorCodeToString(code: errorCode),
                    message: "AdropBanner.loads failed",
                    details: nil))
            })
        pendingLoadsDelegates[batchKey] = delegate
        AdropBanner.loads(unitId: unitId, delegate: delegate)
    }

    /// Destroys every batch-loaded banner still registered. See `preloadedKeys`.
    func destroyAllPreloaded() {
        for key in preloadedKeys {
            if let optionalBanner = ads[key], let banner = optionalBanner {
                banner.destroy()
                requestIdMap.removeValue(forKey: banner)
            }
            ads.removeValue(forKey: key)
        }
        preloadedKeys.removeAll()
    }

    func play(unitId: String, requestId: String) {
        let banner = getAd(unitId: unitId, requestId: requestId)
        banner?.play()
    }

    func pause(unitId: String, requestId: String) {
        let banner = getAd(unitId: unitId, requestId: requestId)
        banner?.pause()
    }

    func getAd(unitId: String, requestId: String) -> AdropBanner? {
        return ads[keyOf(unitId, requestId)] as? AdropBanner
    }

    func destroy(unitId: String, requestId: String) {
        let key = keyOf(unitId, requestId)

        DispatchQueue.main.async { [weak self] in
            self?.preloadedKeys.remove(key)
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
        adropChannel().invokeMethod(AdropMethod.DID_CLICK_AD, arguments: metadataOf(banner))
    }

    func onAdFailedToReceive(_ banner: AdropBanner, _ error: AdropErrorCode) {
        let args: [String: Any] = ["unitId": banner.unitId, "error": AdropErrorCodeToString(code: error), "requestId": requestIdMap[banner]]
        adropChannel().invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: args)

    }

    func onAdReceived(_ banner: AdropBanner) {
        adropChannel().invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: metadataOf(banner))
    }

    func onAdImpression(_ banner: AdropBanner) {
        adropChannel().invokeMethod(AdropMethod.DID_IMPRESSION, arguments: metadataOf(banner))
    }

    func onAdVideoStart(_ banner: AdropBanner) {
        adropChannel().invokeMethod(AdropMethod.DID_VIDEO_START, arguments: metadataOf(banner))
    }

    func onAdVideoEnd(_ banner: AdropBanner) {
        adropChannel().invokeMethod(AdropMethod.DID_VIDEO_END, arguments: metadataOf(banner))
    }

    private func metadataOf(_ banner: AdropBanner) -> [String: Any] {
        return [
            "unitId": banner.unitId,
            "creativeId": banner.creativeId,
            "requestId": requestIdMap[banner],
            "txId": banner.txId,
            "campaignId": banner.campaignId,
            "destinationURL": banner.destinationURL,
            "creativeSizeWidth": banner.creativeSize.width,
            "creativeSizeHeight": banner.creativeSize.height,
            "browserTarget": banner.browserTargetValue.rawValue,
            "creativeType": banner.creativeType
        ]
    }
}

/// Per-call delegate for `AdropBanner.loads`. Captures the Flutter result
/// closures; the manager keeps a strong reference until the terminal callback
/// (the core holds delegates weakly).
private class BannerLoadsDelegate: NSObject, AdropBannerDelegate {
    private let onBatchReceived: ([AdropBanner]) -> Void
    private let onBatchFailed: (AdropErrorCode) -> Void

    init(onBatchReceived: @escaping ([AdropBanner]) -> Void,
         onBatchFailed: @escaping (AdropErrorCode) -> Void) {
        self.onBatchReceived = onBatchReceived
        self.onBatchFailed = onBatchFailed
        super.init()
    }

    func onAdsReceived(_ banners: [AdropBanner]) {
        onBatchReceived(banners)
    }

    func onAdsFailedToReceive(_ errorCode: AdropErrorCode) {
        onBatchFailed(errorCode)
    }

    // Required by the protocol; singular callbacks can only fire between
    // auto-attach and the delegate swap — nothing is mounted yet, drop them.
    func onAdReceived(_ banner: AdropBanner) {}
    func onAdFailedToReceive(_ banner: AdropBanner, _ errorCode: AdropErrorCode) {}
}
