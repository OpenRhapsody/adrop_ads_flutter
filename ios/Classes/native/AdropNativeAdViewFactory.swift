import Foundation
import Flutter
import UIKit
import AdropAds

class AdropNativeAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var adManager: AdropAdManager
    private var viewMap = [String:FlutterPlatformView]()
    
    init(messenger: FlutterBinaryMessenger, adManager: AdropAdManager) {
        self.messenger = messenger
        self.adManager = adManager
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let call = CallCreateAd(encoding: args as? [String : Any?])
        if let ad = adManager.getAd(adType: .native, requestId: call.requestId) as? FlutterAdropNativeAd {
            let containerView = UIView(frame: frame)
            containerView.clipsToBounds = true

            let adView = AdropNativeAdView()
            adView.setIsEntireClick(true)

            // Add adView to containerView first so it has a superview
            // before setNativeAd (required by backfill's performDirectInjection)
            containerView.addSubview(adView)
            adView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                adView.topAnchor.constraint(equalTo: containerView.topAnchor),
                adView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])

            adView.setNativeAd(ad.nativeAd)

            let platformView = AdropFlutterPlatformView(view: containerView)
            viewMap[call.requestId] = platformView
            return platformView
        } else {
            return ErrorView()
        }
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func performClick(_ requestId: String) {
        guard let platformView = viewMap[requestId] as? AdropFlutterPlatformView else {
            return
        }

        let containerView = platformView.view()
        guard let nativeView = containerView.subviews.first(where: { $0 is AdropNativeAdView }) as? AdropNativeAdView else {
            return
        }

        nativeView.performClick()
    }

    /**
     * Re-bind the AdropNativeAd to the existing PlatformView's AdropNativeAdView.
     *
     * Needed for backfill ads because the PlatformView is created once (in [create])
     * and reused across `ad.load()` calls. The core `AdropNativeAdView.setNativeAd` is
     * never re-invoked through the PlatformView lifecycle, so for backfill flows AdMob's
     * `GADNativeAdView.nativeAd` is never re-bound to the new GADNativeAd instance and
     * OM SDK never starts tracking it (impression callback dead).
     *
     * Direct ads do not need this — they reuse the same WebView host which updates its
     * creative HTML internally on each `ad.load()`.
     *
     * Safe to call when PlatformView hasn't been created yet (no-op).
     */
    func rebind(_ requestId: String) {
        guard let platformView = viewMap[requestId] as? AdropFlutterPlatformView else { return }
        let containerView = platformView.view()
        guard let adView = containerView.subviews.first(where: { $0 is AdropNativeAdView }) as? AdropNativeAdView else { return }
        guard let ad = (adManager.getAd(adType: .native, requestId: requestId) as? FlutterAdropNativeAd)?.nativeAd else { return }
        adView.setNativeAd(ad)
    }
}

private class ErrorView: NSObject, FlutterPlatformView {
    
    func view() -> UIView {
        return UIView()
    }
    
}
