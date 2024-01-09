import Flutter
import UIKit
import AdropAds

public class AdropAdsFlutterPlugin: NSObject, FlutterPlugin {
    private var bannerManager: AdropBannerManager?
    private var messenger: FlutterBinaryMessenger?
    private var adropAdManager : AdropAdManager?
    
    private let ModuleError = FlutterError(
        code: "ERROR_CODE_INTERNAL",
        message: "Module is undefined",
        details: "Expected adType enum index larger than 0"
    )
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AdropAdsFlutterPlugin()
        let messenger = registrar.messenger()
        instance.messenger = messenger
        instance.adropAdManager = AdropAdManager(messenger: messenger)
        
        let invokeChannel = FlutterMethodChannel(name: AdropChannel.invokeChannel, binaryMessenger: messenger)
        let bannerManager = AdropBannerManager(messenger: messenger)
        registrar.addMethodCallDelegate(instance, channel: invokeChannel)
        
        instance.bannerManager = bannerManager
        registrar.register(AdropBannerViewFactory(messenger: messenger, bannerManager: bannerManager), withId: AdropChannel.bannerEventListenerChannel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AdropMethod.INITIALIZE:
            Adrop.initialize(production: call.arguments as? Bool ?? false)
            result(nil)
        case AdropMethod.LOAD_BANNER:
            bannerManager?.load(unitId: call.arguments as? String ??  "")
            result(nil)
        case AdropMethod.DISPOSE_BANNER:
            bannerManager?.destroy(unitId: call.arguments as? String ?? "")
            result(nil)
        case AdropMethod.LOAD_AD:
            let adTypeIndex = (call.arguments as? [String: Any?])?["adType"] as? Int ?? 0
            if (adTypeIndex == AdType.allCases.firstIndex(of: .undefined)!) {
                result(ModuleError)
                return
            }
            adropAdManager?.load(
                adType: AdType.allCases[adTypeIndex],
                unitId: (call.arguments as? [String: Any?])?["unitId"] as? String ?? "",
                requestId: (call.arguments as? [String: Any?])?["requestId"] as? String ?? ""
            )
            result(nil)
        case AdropMethod.SHOW_AD:
            let adTypeIndex = (call.arguments as? [String: Any?])?["adType"] as? Int ?? 0
            if (adTypeIndex == AdType.allCases.firstIndex(of: .undefined)!) {
                result(ModuleError)
                return
            }
            adropAdManager?.show(
                adType: AdType.allCases[adTypeIndex],
                requestId: (call.arguments as? [String: Any?])?["requestId"] as? String ?? ""
            )
            result(nil)
        case AdropMethod.DISPOSE_AD:
            let adTypeIndex = (call.arguments as? [String: Any?])?["adType"] as? Int ?? 0
            if (adTypeIndex == AdType.allCases.firstIndex(of: .undefined)!) {
                result(ModuleError)
                return
            }
            adropAdManager?.destroy(
                adType: AdType.allCases[adTypeIndex],
                requestId: (call.arguments as? [String: Any?])?["requestId"] as? String ?? ""
            )
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
