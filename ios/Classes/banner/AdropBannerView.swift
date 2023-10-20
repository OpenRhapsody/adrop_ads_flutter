//
//  AdropBannerView.swift
//  adrop_ads_flutter
//
//  Created by aaron on 2023/10/19.
//

import Foundation
import Flutter
import UIKit
import AdropAds

class AdropBannerView: NSObject, FlutterPlatformView, AdropBannerDelegate {
    private var banner: AdropBanner
    private var methodChannel: FlutterMethodChannel
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        binaryMessenger messenger: FlutterBinaryMessenger,
        call: CallCreateBanner
    ) { 
        banner = AdropBanner(unitId: call.unitId, adSize: call.adSize)
        methodChannel = FlutterMethodChannel(name: AdropChannel.methodBannerChannelOf(id: viewId.description), binaryMessenger: messenger)

        super.init()
        banner.delegate = self
        methodChannel.setMethodCallHandler(onMethodCall)
    }

    func view() -> UIView {
        return banner
    }
    
    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch(call.method) {
        case AdropMethod.LOAD_BANNER:
            banner.load()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func onAdReceived() {
        methodChannel.invokeMethod(AdropMethod.DID_RECEIVE_AD, arguments: nil)
    }
    
    func onAdClicked() {
        methodChannel.invokeMethod(AdropMethod.DID_CLICK_AD, arguments: nil)
    }
    
    func onAdFailedToReceive(_ error: AdropAds.AdropErrorCode) {
        methodChannel.invokeMethod(AdropMethod.DID_FAILED_TO_RECEIVE, arguments: error.rawValue)
    }
}
