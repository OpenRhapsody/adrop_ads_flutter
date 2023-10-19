//
//  AdropBannerViewFactory.swift
//  adrop_ads_flutter
//
//  Created by aaron on 2023/10/19.
//

import Foundation
import Flutter
import UIKit

class AdropBannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let call = CallCreateBanner(encoding: args as? [String : Any?])
        return AdropBannerView(frame: frame, viewIdentifier: viewId, binaryMessenger: messenger, call: call)
    }
}

