import Foundation
import Flutter
import AdropAds

class AdropAdManager: NSObject {
    private let messenger: FlutterBinaryMessenger
    private var ads: [String: AdropAd?] = [:]

    /// Per-call batch delegates, held strongly until the terminal callback.
    /// REQUIRED: the core stores `AdropNativeAd.delegate` weakly and `loads()`
    /// captures `[weak delegate]` — without this map the delegate deallocates
    /// and the Dart Future never resolves.
    private var pendingLoadsDelegates: [String: NativeAdLoadsDelegate] = [:]

    /// Keys of native ads delivered by the batch loads path. Swept on engine
    /// detach so their WebViews don't outlive the engine.
    private var preloadedNativeKeys: Set<String> = []

    /**
     * Optional hook invoked by [FlutterAdropNativeAd] when a backfill ad arrives, so
     * the plugin can re-bind the PlatformView's AdropNativeAdView to the new AdMob
     * GADNativeAd. Wired by the plugin to `AdropNativeAdViewFactory.rebind`.
     */
    var nativeRebindCallback: ((String) -> Void)?

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    func load(adType: AdType, unitId: String, requestId: String, useCustomClick: Bool, preferredAdChoicesPosition: Int = AdropAdChoicesPosition.topRight.rawValue, ssvOptions: AdropServerSideVerificationOptions? = nil) {
        let ad = getAd(adType: adType, requestId: requestId)
        ?? createAd(adType: adType, unitId: unitId, requestId: requestId, useCustomClick: useCustomClick, preferredAdChoicesPosition: preferredAdChoicesPosition)
        let key = keyOf(adType, requestId)
        if self.ads[key] == nil {
            self.ads[key] = ad
        }

        if let ssvOptions = ssvOptions, let rewardedAd = ad as? FlutterAdropRewardedAd {
            rewardedAd.setServerSideVerificationOptions(ssvOptions)
        }

        ad?.load()
    }

    /// Batch native load: one network call, up to 5 pre-loaded ads adopted into
    /// `FlutterAdropNativeAd` wrappers bound positionally to the Dart-minted
    /// requestIds. The adopting init swaps each ad's delegate from the per-call
    /// batch delegate to the wrapper, so per-instance events route exactly like
    /// the singular path.
    func loadsNative(unitId: String, requestIds: [String], useCustomClick: Bool, result: @escaping FlutterResult) {
        let batchKey = UUID().uuidString
        let delegate = NativeAdLoadsDelegate(
            onBatchReceived: { [weak self] nativeAds in
                guard let self = self else { return }
                var filled: [String] = []
                var metas: [[String: Any]] = []
                for (index, nativeAd) in nativeAds.enumerated() {
                    // Cap-drift guard: extras are simply not retained (ARC frees them).
                    if index >= requestIds.count { continue }
                    let requestId = requestIds[index]
                    let wrapper = FlutterAdropNativeAd(
                        adopting: nativeAd,
                        requestId: requestId,
                        useCustomClick: useCustomClick,
                        messenger: self.messenger,
                        nativeRebindCallback: self.nativeRebindCallback)
                    let key = self.keyOf(.native, requestId)
                    self.ads[key] = wrapper
                    self.preloadedNativeKeys.insert(key)
                    filled.append(requestId)
                    metas.append(wrapper.batchMetadata())
                }
                self.pendingLoadsDelegates.removeValue(forKey: batchKey)
                result(["requestIds": filled, "ads": metas])
            },
            onBatchFailed: { [weak self] errorCode in
                self?.pendingLoadsDelegates.removeValue(forKey: batchKey)
                result(FlutterError(
                    code: AdropErrorCodeToString(code: errorCode),
                    message: "AdropNativeAd.loads failed",
                    details: nil))
            })
        pendingLoadsDelegates[batchKey] = delegate
        AdropNativeAd.loads(unitId: unitId, delegate: delegate)
    }

    /// Releases every batch-loaded native ad still registered (ARC frees the
    /// underlying WebView). See `preloadedNativeKeys`.
    func destroyAllPreloadedNative() {
        for key in preloadedNativeKeys {
            ads.removeValue(forKey: key)
        }
        preloadedNativeKeys.removeAll()
    }

    func show(adType: AdType, requestId: String) {
        if let ad = self.ads[keyOf(adType, requestId)] {
            ad?.show()
        }
    }

    func customize(adType: AdType, requestId: String, data: [String:Any]) {
        switch adType {
        case AdType.popup:
            guard let ad = self.ads[self.keyOf(adType, requestId)] as? FlutterAdropPopupAd else { return }

            ad.customize(data)
        default:
            return
        }
    }

    func close(adType: AdType, requestId: String) {
        switch adType {
        case AdType.popup:
            guard let ad = self.ads[self.keyOf(adType, requestId)] as? FlutterAdropPopupAd else { return }

            ad.close()
        default:
            return
        }
    }

    func destroy(adType: AdType, requestId: String) {
        let key = keyOf(adType, requestId)
        preloadedNativeKeys.remove(key)

        switch adType {
        case AdType.popup:
            guard let ad = self.ads[self.keyOf(adType, requestId)] as? FlutterAdropPopupAd else { return }

            DispatchQueue.main.async { [weak self] in
                ad.destroy()
                self?.removeAds(key)
            }

        default:
            removeAds(key)
        }
    }

    private func removeAds(_ key: String) {
        DispatchQueue.main.async { [weak self] in
            self?.ads.removeValue(forKey: key)
        }
    }

    func createAd(adType: AdType, unitId: String, requestId: String, useCustomClick: Bool = false, preferredAdChoicesPosition: Int = AdropAdChoicesPosition.topRight.rawValue) -> AdropAd? {
        switch adType {
        case .interstitial:
            return FlutterAdropInterstitialAd(unitId: unitId, requestId: requestId, messenger: messenger)
        case .rewarded:
            return FlutterAdropRewardedAd(unitId: unitId, requestId: requestId, messenger: messenger)
        case .popup:
            return FlutterAdropPopupAd(unitId: unitId, requestId: requestId, messenger: messenger)
        case .native:
            return FlutterAdropNativeAd(unitId: unitId, requestId: requestId, useCustomClick: useCustomClick, preferredAdChoicesPosition: preferredAdChoicesPosition, messenger: messenger, nativeRebindCallback: nativeRebindCallback)
        case .undefined:
            return nil
        }
    }

    func getAd(adType: AdType, requestId: String) -> AdropAd? {
        guard let ad = self.ads[keyOf(adType, requestId)] else {
            return nil
        }

        return ad

    }

    private func keyOf(_ adType: AdType, _ requestId: String) -> String {
        return "\(adType)/\(requestId)"
    }
}

/// Per-call delegate for `AdropNativeAd.loads`. Captures the Flutter result
/// closures; the manager keeps a strong reference until the terminal callback
/// (the core holds delegates weakly). Separate class from the banner batch
/// delegate — the two @objc protocols share selector names and cannot be
/// adopted by one NSObject (ios-sdk.md §2).
private class NativeAdLoadsDelegate: NSObject, AdropNativeAdDelegate {
    private let onBatchReceived: ([AdropNativeAd]) -> Void
    private let onBatchFailed: (AdropErrorCode) -> Void

    init(onBatchReceived: @escaping ([AdropNativeAd]) -> Void,
         onBatchFailed: @escaping (AdropErrorCode) -> Void) {
        self.onBatchReceived = onBatchReceived
        self.onBatchFailed = onBatchFailed
        super.init()
    }

    func onAdsReceived(_ ads: [AdropNativeAd]) {
        onBatchReceived(ads)
    }

    func onAdsFailedToReceive(_ errorCode: AdropErrorCode) {
        onBatchFailed(errorCode)
    }

    // Required by the protocol; singular callbacks can only fire between
    // auto-attach and the wrapper adoption — nothing is mounted yet, drop them.
    func onAdReceived(_ ad: AdropNativeAd) {}
    func onAdFailedToReceive(_ ad: AdropNativeAd, _ errorCode: AdropErrorCode) {}
}
