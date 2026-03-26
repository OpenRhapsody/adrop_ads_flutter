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
}

private class ErrorView: NSObject, FlutterPlatformView {
    
    func view() -> UIView {
        return UIView()
    }
    
}
