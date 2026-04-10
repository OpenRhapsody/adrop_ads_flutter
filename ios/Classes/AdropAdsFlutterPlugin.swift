import Flutter
import UIKit
import WebKit
import AdropAds

public class AdropAdsFlutterPlugin: NSObject, FlutterPlugin {
    private var bannerManager: AdropBannerManager?
    private var adropAdManager : AdropAdManager?
    private var messenger: FlutterBinaryMessenger?
    private var nativeViewFactory: AdropNativeAdViewFactory?
    private let consentManager = FlutterAdropConsentManager()

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

        instance.nativeViewFactory = AdropNativeAdViewFactory(messenger: messenger, adManager: adManager)
        guard let nativeViewFactory = instance.nativeViewFactory else { return }

        registrar.register(nativeViewFactory, withId: AdropChannel.nativeEventListenerChannel)
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
        case AdropMethod.SET_THEME:
            let theme = (call.arguments as? [String: Any?])?["theme"] as? String ?? "auto"
            let converted: AdropTheme
            switch theme.lowercased() {
            case "light":
                converted = .light
            case "dark":
                converted = .dark
            default:
                converted = .auto
            }

            Adrop.setTheme(converted)
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

        case AdropMethod.SEND_EVENT:
            let name = (call.arguments as? [String: Any?])?["name"] as? String ?? ""
            let params = (call.arguments as? [String: Any?])?["params"] as? [String: Any]

            AdropMetrics.sendEvent(name: name, params: params)
            result(nil)

        case AdropMethod.LOAD_BANNER:
            let args = call.arguments as? [String: Any?]
            let unitId = args?["unitId"] as? String ?? ""
            let requestId = args?["requestId"] as? String ?? ""
            let width = args?["width"] as? CGFloat
            let height = args?["height"] as? CGFloat

            bannerManager?.load(unitId: unitId, requestId: requestId, width: width, height: height)
            result(nil)
        case AdropMethod.DISPOSE_BANNER:
            let unitId = (call.arguments as? [String: Any?])?["unitId"] as? String ?? ""
            let requestId = (call.arguments as? [String: Any?])?["requestId"] as? String ?? ""

            bannerManager?.destroy(unitId: unitId, requestId: requestId)
            result(nil)
        case AdropMethod.PLAY_BANNER:
            let unitId = (call.arguments as? [String: Any?])?["unitId"] as? String ?? ""
            let requestId = (call.arguments as? [String: Any?])?["requestId"] as? String ?? ""

            bannerManager?.play(unitId: unitId, requestId: requestId)
            result(nil)
        case AdropMethod.PAUSE_BANNER:
            let unitId = (call.arguments as? [String: Any?])?["unitId"] as? String ?? ""
            let requestId = (call.arguments as? [String: Any?])?["requestId"] as? String ?? ""

            bannerManager?.pause(unitId: unitId, requestId: requestId)
            result(nil)
        case AdropMethod.LOAD_AD:
            let adTypeIndex = (call.arguments as? [String: Any?])?["adType"] as? Int ?? 0
            if (adTypeIndex == AdType.allCases.firstIndex(of: .undefined)!) {
                result(ModuleError)
                return
            }
            let loadArgs = call.arguments as? [String: Any?]
            let userId = loadArgs?["userId"] as? String
            let customData = loadArgs?["customData"] as? String
            let ssvOptions: AdropServerSideVerificationOptions? = (userId != nil || customData != nil)
                ? AdropServerSideVerificationOptions(userId: userId, customData: customData) : nil

            adropAdManager?.load(
                adType: AdType.allCases[adTypeIndex],
                unitId: loadArgs?["unitId"] as? String ?? "",
                requestId: loadArgs?["requestId"] as? String ?? "",
                useCustomClick: loadArgs?["useCustomClick"] as? Bool ?? false,
                ssvOptions: ssvOptions
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
        case AdropMethod.CLOSE_AD:
            let adTypeIndex = (call.arguments as? [String: Any?])?["adType"] as? Int ?? 0
            if (adTypeIndex == AdType.allCases.firstIndex(of: .undefined)!) {
                result(ModuleError)
                return
            }
            adropAdManager?.close(
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
        case AdropMethod.PERFORM_CLICK:
            let requestId = (call.arguments as? [String: Any?])?["requestId"] as? String ?? ""
            nativeViewFactory?.performClick(requestId)
            result(nil)

        case AdropMethod.REQUEST_CONSENT_INFO_UPDATE:
            consentManager.requestConsentInfoUpdate(result: result)

        case AdropMethod.GET_CONSENT_STATUS:
            consentManager.getConsentStatus(result: result)

        case AdropMethod.CAN_REQUEST_ADS:
            consentManager.canRequestAds(result: result)

        case AdropMethod.RESET_CONSENT:
            consentManager.reset(result: result)

        case AdropMethod.SET_CONSENT_DEBUG_SETTINGS:
            let geographyValue = (call.arguments as? [String: Any?])?["geography"] as? Int ?? 0
            consentManager.setDebugSettings(geographyValue: geographyValue, result: result)

        case AdropMethod.REGISTER_WEB_VIEW:
            let webViewId = (call.arguments as? [String: Any?])?["webViewId"] as? Int64 ?? -1
            if webViewId >= 0 {
                registerWebView(identifier: webViewId)
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func registerWebView(identifier: Int64) {
        guard let registry = UIApplication.shared.delegate as? FlutterPluginRegistry else { return }

        guard let externalApiClass = NSClassFromString(
            "FWFWebViewFlutterWKWebViewExternalAPI"
        ) as? NSObject.Type else { return }

        let selector = NSSelectorFromString("webViewForIdentifier:withPluginRegistry:")
        guard externalApiClass.responds(to: selector) else { return }
        guard let method = class_getClassMethod(externalApiClass, selector) else { return }

        typealias WebViewLookup = @convention(c) (AnyObject, Selector, Int64, AnyObject) -> WKWebView?
        let imp = method_getImplementation(method)
        let function = unsafeBitCast(imp, to: WebViewLookup.self)

        if let webView = function(externalApiClass, selector, identifier, registry as AnyObject) {
            Adrop.registerWebView(webView)
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
