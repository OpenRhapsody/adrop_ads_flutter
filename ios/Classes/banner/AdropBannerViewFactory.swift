import Foundation
import Flutter
import UIKit

class AdropBannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var bannerManager: AdropBannerManager
    
    init(messenger: FlutterBinaryMessenger, bannerManager: AdropBannerManager) {
        self.messenger = messenger
        self.bannerManager = bannerManager
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let call = CallCreateAd(encoding: args as? [String : Any?])
        if let banner = bannerManager.getAd(unitId: call.unitId) {
            return AdropFlutterPlatformView(view: banner)
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
