import Flutter
import UIKit
import AdropAds

public class AdropAdsFlutterPlugin: NSObject, FlutterPlugin {
    private var bannerManager: AdropBannerManager?
    private var adropAdManager : AdropAdManager?
    private var messenger: FlutterBinaryMessenger?

    private let ModuleError = FlutterError(
        code: "ERROR_CODE_INTERNAL",
        message: "Module is undefined",
        details: "Expected adType enum index larger than 0"
    )

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AdropAdsFlutterPlugin()
        let messenger = registrar.messenger()
        instance.messenger = messenger

        let adManager = AdropAdManager(messenger: messenger)
        instance.adropAdManager = adManager

        let invokeChannel = FlutterMethodChannel(name: AdropChannel.invokeChannel, binaryMessenger: messenger)
        let bannerManager = AdropBannerManager(messenger: messenger)
        registrar.addMethodCallDelegate(instance, channel: invokeChannel)

        instance.bannerManager = bannerManager
        registrar.register(AdropBannerViewFactory(messenger: messenger, bannerManager: bannerManager), withId: AdropChannel.bannerEventListenerChannel)
        registrar.register(AdropNativeAdViewFactory(messenger: messenger, adManager: adManager), withId: AdropChannel.nativeEventListenerChannel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AdropMethod.INITIALIZE:
            let args = call.arguments as? [String: Any?]
            let production = args?["production"] as? Bool ?? false
            let targetCountries = args?["targetCountries"] as? [String]
            let useInAppBrowser = args?["useInAppBrowser"] as? Bool ?? false
            Adrop.initialize(production: production, useInAppBrowser: useInAppBrowser, targetCountries: targetCountries)
            result(nil)
        case AdropMethod.SET_UID:
            let uid = (call.arguments as? [String: Any?])?["uid"] as? String ?? ""
            if (uid.isEmpty) {
                result(FlutterError(
                    code: "ERROR_CODE_INTERNAL",
                    message: "Invalid uid",
                    details: "Expected not empty string"
                ))
                return
            }
            
            Adrop.setUID(uid)
            result(nil)
        case AdropMethod.SET_PROPERTY:
            let key = (call.arguments as? [String: Any?])?["key"] as? String ?? ""
            let value = (call.arguments as? [String: Any?])?["value"] as? Any ?? [:]
            AdropMetrics.setProperty(key: key, value: convertToEncodable(value))
            result(nil)
        case AdropMethod.GET_PROPERTY:
            result(AdropMetrics.properties())
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
        case AdropMethod.CUSTOMIZE_AD:
            let adTypeIndex = (call.arguments as? [String: Any?])?["adType"] as? Int ?? 0
            if (adTypeIndex == AdType.allCases.firstIndex(of: .undefined)!) {
                result(ModuleError)
                return
            }
            adropAdManager?.customize(
                adType: AdType.allCases[adTypeIndex],
                requestId:(call.arguments as? [String: Any?])?["requestId"] as? String ?? "",
                data: (call.arguments as? [String: Any?])?["data"] as? [String:Any] ?? [:])
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
        case let numberValue as NSNumber:
            if CFGetTypeID(numberValue) == CFBooleanGetTypeID() {
                return numberValue.boolValue
            } else if CFGetTypeID(numberValue) == CFNumberGetTypeID() {
                if numberValue is Int {
                    return  numberValue.intValue
                } else if numberValue is Double || numberValue is Float {
                    return numberValue.doubleValue
                } else {
                    return nil
                }
            } else {
                return nil
            }
        case let boolValue as Bool:
            return boolValue
        case let stringValue as String:
            return stringValue
        case let intValue as Int:
            return intValue
        case let doubleValue as Double:
            return doubleValue
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
