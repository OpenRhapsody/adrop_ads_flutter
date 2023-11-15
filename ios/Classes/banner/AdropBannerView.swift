import Foundation
import Flutter
import UIKit
import AdropAds

class AdropBannerView: NSObject, FlutterPlatformView, AdropBannerDelegate {
    private let banner: AdropBanner
    private let bannerManager: AdropBannerManager
    private let methodChannel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        binaryMessenger messenger: FlutterBinaryMessenger,
        call: CallCreateBanner,
        bannerManager: AdropBannerManager
    ) {
        self.bannerManager = bannerManager
        self.methodChannel = FlutterMethodChannel(name: AdropChannel.methodBannerChannelOf(id: viewId.description), binaryMessenger: messenger)
        self.banner = bannerManager.create(unitId: call.unitId)

        super.init()
        banner.delegate = self
        methodChannel.setMethodCallHandler(onMethodCall)
    }

    func view() -> UIView {
        return banner
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch(call.method) {
        case AdropMethod.LOAD_BANNER:
            banner.load()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func onAdReceived(_ banner: AdropBanner) {
        methodChannel.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: nil)
        bannerManager.onAdReceived(banner)
    }

    func onAdClicked(_ banner: AdropBanner) {
        methodChannel.invokeMethod(AdropMethod.DID_CLICK_AD, arguments: nil)
        bannerManager.onAdClicked(banner)
    }

    func onAdFailedToReceive(_ banner: AdropBanner, _ error: AdropAds.AdropErrorCode) {
        methodChannel.invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: AdropErrorCodeToString(code: error))
        bannerManager.onAdFailedToReceive(banner, error)
    }
}
