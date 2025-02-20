import Foundation

struct AdropChannel {
    static let invokeChannel = "io.adrop.adrop-ads"
    static let bannerEventListenerChannel = "\(invokeChannel)/banner"
    static let nativeEventListenerChannel = "\(invokeChannel)/native"
    
    static func bannerEventListenerChannelOf(id: String) -> String {
        return "\(bannerEventListenerChannel)_\(id)"
    }
    
    static func adropEventListenerChannel(adType: AdType, id: String) -> String? {
        switch adType {
        case AdType.interstitial:
            return "\(invokeChannel)/interstitial_\(id)"
        case AdType.rewarded:
            return "\(invokeChannel)/rewarded_\(id)"
        case AdType.popup:
            return "\(invokeChannel)/popup_\(id)"
        case AdType.native:
            return "\(invokeChannel)/native_\(id)"
        case AdType.undefined:
            return nil
        }
    }
}
