//
//  AdropChannel.swift
//  adrop_ads_flutter
//
//  Created by aaron on 2023/10/19.
//

import Foundation

struct AdropChannel {
    static let methodChannel = "com.openrhapsody.adrop-ads"
    static let methodBannerChannel = "\(methodChannel)/banner"

    static func methodBannerChannelOf(id: String) -> String {
        return "\(methodBannerChannel)_\(id)"
    }
}
