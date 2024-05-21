import Flutter
import UIKit
import AdropAds

public class AdropAdsFlutterPlugin: NSObject, FlutterPlugin {
    private var bannerManager: AdropBannerManager?
    private var messenger: FlutterBinaryMessenger?
    private var adropAdManager : AdropAdManager?
    private let pageTracker = PageTracker()

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
        case AdropMethod.SET_PROPERTY:
            let key = (call.arguments as? [String: Any?])?["key"] as? String ?? ""
            let value = (call.arguments as? [String: Any?])?["value"] as? String ?? ""
            AdropMetrics.setProperty(key: key, value: value)
            result(nil)
        case AdropMethod.LOG_EVENT:
            let name = (call.arguments as? [String: Any?])?["name"] as? String ?? ""
            let params = (call.arguments as? [String: Any?])?["params"] as? [String:Any] ?? [:]
            var encodableParams: [String: Encodable] = [:]

            for (key, value) in params {
                if let encodableValue = convertToEncodable(value) {
                    encodableParams[key] = encodableValue
                }
            }
            AdropMetrics.logEvent(name: name, params: encodableParams)
        case AdropMethod.PAGE_TRACK:
            let page = (call.arguments as? [String: Any?])?["page"] as? String ?? ""
            let size = (call.arguments as? [String: Any?])?["size"] as? Int ?? 0
            pageTracker.track(page: page, sizeOfRoutes: size)
            result(nil)
        case AdropMethod.PAGE_ATTACH:
            let page = (call.arguments as? [String: Any?])?["page"] as? String ?? ""
            let unitId = (call.arguments as? [String: Any?])?["unitId"] as? String ?? ""
            pageTracker.attach(unitId: unitId, page: page)
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

    private func convertToEncodable(_ value: Any) -> Encodable? {
        switch value {
        case let stringValue as String:
            return stringValue
        case let boolValue as Bool:
            return boolValue
        case let numberValue as NSNumber:
            if (CFGetTypeID(numberValue) != CFNumberGetTypeID()) {
                return nil
            } else if (numberValue is Int) {
                return numberValue.intValue
            } else if (numberValue is Float || numberValue is Double) {
                return numberValue.doubleValue
            } else {
                return nil
            }
        case _ as [Any]:
            // array not supported
            return nil
        case _ as [String: Any]:
            // dictionary not supported
            return nil
        default:
            if let encodableValue = value as? Encodable {
                return encodableValue
            } else {
                return nil
            }
        }
    }

    func covertAnyToEncodable(_ value: Any) -> Encodable? {
        return convertToEncodable(value)
    }
}
