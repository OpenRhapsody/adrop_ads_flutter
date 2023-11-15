import Foundation

struct AdropChannel {
    static let methodChannel = "io.adrop.adrop-ads"
    static let methodBannerChannel = "\(methodChannel)/banner"

    static func methodBannerChannelOf(id: String) -> String {
        return "\(methodBannerChannel)_\(id)"
    }
}
