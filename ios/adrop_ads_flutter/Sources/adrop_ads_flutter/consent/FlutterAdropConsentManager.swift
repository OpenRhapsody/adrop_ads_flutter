import Flutter
import UIKit
import AdropAds

class FlutterAdropConsentManager {

    func requestConsentInfoUpdate(result: @escaping FlutterResult) {
        guard let consentManager = Adrop.consentManager else {
            result(FlutterError(
                code: "ERROR_CODE_INTERNAL",
                message: "ConsentManager is not available",
                details: "AdropAdsBackfill module is not installed"
            ))
            return
        }

        guard let viewController = getTopViewController() else {
            result(FlutterError(
                code: "ERROR_CODE_INTERNAL",
                message: "Top view controller is not available",
                details: "Unable to retrieve a valid UIViewController to present consent UI"
            ))
            return
        }

        consentManager.requestConsentInfoUpdate(from: viewController) { consentResult in
            result(consentResult.toMap())
        }
    }

    func showPrivacyOptionsForm(result: @escaping FlutterResult) {
        guard let consentManager = Adrop.consentManager else {
            result(FlutterError(
                code: "ERROR_CODE_INTERNAL",
                message: "ConsentManager is not available",
                details: "AdropAdsBackfill module is not installed"
            ))
            return
        }

        // 표시 화면을 고르지 않고 nil 을 넘긴다 — UMP 가 메인 윈도우의 최상단 화면에서 띄운다.
        // 이 양식은 설정 화면에서 불리고, 설정 화면은 모달인 경우가 많아 rootViewController 에서
        // present 하면 UIKit 이 거부한다.
        consentManager.showPrivacyOptionsForm(from: nil) { consentResult in
            result(consentResult.toMap())
        }
    }

    func getPrivacyOptionsRequirementStatus(result: @escaping FlutterResult) {
        guard let consentManager = Adrop.consentManager else {
            result(0) // UNKNOWN
            return
        }
        result(consentManager.getPrivacyOptionsRequirementStatus().rawValue)
    }

    func getConsentStatus(result: @escaping FlutterResult) {
        guard let consentManager = Adrop.consentManager else {
            result(0) // UNKNOWN
            return
        }
        let status = consentManager.getConsentStatus()
        result(status.rawValue)
    }

    func canRequestAds(result: @escaping FlutterResult) {
        guard let consentManager = Adrop.consentManager else {
            result(false)
            return
        }
        let canRequest = consentManager.canRequestAds()
        result(canRequest)
    }

    func reset(result: @escaping FlutterResult) {
        guard let consentManager = Adrop.consentManager else {
            result(nil)
            return
        }
        consentManager.reset()
        result(nil)
    }

    func setDebugSettings(geographyValue: Int, result: @escaping FlutterResult) {
        guard let consentManager = Adrop.consentManager else {
            result(nil)
            return
        }

        let geography: AdropConsentDebugGeography
        switch geographyValue {
        case 0:
            geography = .disabled
        case 1:
            geography = .EEA
        case 3:
            geography = .regulatedUSState
        case 4:
            geography = .other
        default:
            geography = .disabled
        }

        let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? ""
        consentManager.setDebugSettings(testDeviceIdentifiers: [deviceIdentifier], geography: geography)
        result(nil)
    }

    private func getTopViewController() -> UIViewController? {
        var keyWindow: UIWindow?
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        return keyWindow?.rootViewController
    }
}
