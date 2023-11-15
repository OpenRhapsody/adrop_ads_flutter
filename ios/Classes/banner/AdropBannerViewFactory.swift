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
        let call = CallCreateBanner(encoding: args as? [String : Any?])
        return AdropBannerView(frame: frame, viewIdentifier: viewId, binaryMessenger: messenger, call: call, bannerManager: bannerManager)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
