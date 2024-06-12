import UIKit
import Flutter
import AdropAds

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

        let splashViewController = AdropSplashAdViewController(unitId: "PUBLIC_TEST_UNIT_ID_SPLASH")
        splashViewController.backgroundColor = UIColor(white: 1, alpha: 1)
        splashViewController.logoImage = UIImage(named: "splashLogo")
        splashViewController.mainViewController = controller
        splashViewController.timeout = 0.5
        splashViewController.delegate = self

        self.window?.rootViewController = splashViewController
        self.window?.makeKeyAndVisible()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate: AdropSplashAdDelegate {
    func onAdReceived(_ ad: AdropAds.AdropSplashAd) {
        print("onAdReceived \(ad.unitId)")
    }
    
    func onAdFailedToReceive(_ ad: AdropAds.AdropSplashAd, _ errorCode: AdropAds.AdropErrorCode) {
        print("onAdFailedToReceive: \(ad.unitId) error: \(AdropErrorCodeToString(code: errorCode))")
    }
    
    func onAdImpression(_ ad: AdropSplashAd) {
        print("onAdImpression: \(ad.unitId)")
    }
}


