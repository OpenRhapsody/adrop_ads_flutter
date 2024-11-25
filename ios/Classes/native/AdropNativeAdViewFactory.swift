import Foundation
import Flutter
import UIKit
import AdropAds

class AdropNativeAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var adManager: AdropAdManager
    
    init(messenger: FlutterBinaryMessenger, adManager: AdropAdManager) {
        self.messenger = messenger
        self.adManager = adManager
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let call = CallCreateAd(encoding: args as? [String : Any?])
        if let ad = adManager.getAd(adType: .native, requestId: call.requestId) as? FlutterAdropNativeAd {
            let adView = AdropNativeAdView()
            adView.setIsEntireClick(true)
            adView.setNativeAd(ad.nativeAd)
            
            return AdropFlutterPlatformView(view: adView)
        } else {
            return ErrorView()
        }
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

private class ErrorView: NSObject, FlutterPlatformView {
    
    func view() -> UIView {
        return UIView()
    }
    
}
