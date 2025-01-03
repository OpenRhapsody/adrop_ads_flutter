import Foundation

struct AdropMethod {
    static let INITIALIZE = "initialize"
    static let LOAD_BANNER = "loadBanner"
    static let DISPOSE_BANNER = "disposeBanner"

    static let LOAD_AD = "loadAd"
    static let SHOW_AD = "showAd"
    static let CUSTOMIZE_AD = "customizeAd"
    static let DISPOSE_AD = "disposeAd"
    static let SET_PROPERTY = "setProperty"
    static let GET_PROPERTY = "getProperty"
    static let LOG_EVENT = "logEvent"

    static let DID_RECEIVE_AD = "onAdReceived"
    static let DID_CLICK_AD = "onAdClicked"
    static let DID_FAILED_TO_RECEIVE = "onAdFailedToReceive"

    static let DID_DISMISS_FULL_SCREEN = "onAdDidDismissFullScreen"
    static let DID_PRESENT_FULL_SCREEN = "onAdDidPresentFullScreen"
    static let DID_FAIL_TO_SHOW_FULL_SCREEN = "onAdFailedToShowFullScreen"
    static let DID_IMPRESSION = "onAdImpression"
    static let WILL_DISMISS_FULL_SCREEN = "onAdWillDismissFullScreen"
    static let WILL_PRESENT_FULL_SCREEN = "onAdWillPresentFullScreen"
    static let HANDLE_EARN_REWARD = "handleEarnReward"
}
