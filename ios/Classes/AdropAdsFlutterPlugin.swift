import Flutter
import UIKit
import AdropAds

public class AdropAdsFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AdropAdsFlutterPlugin()
        let channel = FlutterMethodChannel(name: AdropChannel.methodChannel, binaryMessenger: registrar.messenger())
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(AdropBannerViewFactory(messenger: registrar.messenger()), withId: AdropChannel.methodBannerChannel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AdropMethod.INITIALIZE:
            Adrop.initialize(production: call.arguments as? Bool ?? false)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
