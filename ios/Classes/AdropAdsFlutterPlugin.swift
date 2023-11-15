import Flutter
import UIKit
import AdropAds

public class AdropAdsFlutterPlugin: NSObject, FlutterPlugin {
    private var bannerManager: AdropBannerManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AdropAdsFlutterPlugin()
        let channel = FlutterMethodChannel(name: AdropChannel.methodChannel, binaryMessenger: registrar.messenger())
        let bannerManager = AdropBannerManager(messenger: registrar.messenger())

        registrar.addMethodCallDelegate(instance, channel: channel)

        instance.bannerManager = bannerManager
        registrar.register(AdropBannerViewFactory(messenger: registrar.messenger(), bannerManager: bannerManager), withId: AdropChannel.methodBannerChannel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AdropMethod.INITIALIZE:
            Adrop.initialize(production: call.arguments as? Bool ?? false)
            result(nil)
        case AdropMethod.LOAD_BANNER:
            bannerManager?.load(unitId: call.arguments as? String ??  "")
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
