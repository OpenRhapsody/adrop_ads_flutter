import Flutter
import UIKit
import XCTest

@testable import adrop_ads_flutter

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {
    
    func testGetPlatformVersion() {
        let plugin = AdropAdsFlutterPlugin()
        
        let call = FlutterMethodCall(methodName: "getPlatformVersion", arguments: [])
        
        let resultExpectation = expectation(description: "result block must be called.")
        plugin.handle(call) { result in
            XCTAssertEqual(result as! String, "iOS " + UIDevice.current.systemVersion)
            resultExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testConvertEncodable() {
        let plugin = AdropAdsFlutterPlugin()
        
        let boolValue = true
        XCTAssertNotNil(plugin.covertAnyToEncodable(boolValue))
        
        let nsnumberInteger = NSNumber(integerLiteral: 10)
        XCTAssertNotNil(plugin.covertAnyToEncodable(nsnumberInteger))
        
        XCTAssertEqual(NSNumber(floatLiteral: 3.1), 3.1)
        XCTAssertEqual(NSNumber(booleanLiteral: true), true)
        XCTAssertEqual(NSNumber(booleanLiteral: false), false)
        
        XCTAssertNotNil(plugin.covertAnyToEncodable(NSNumber(floatLiteral: 3.1)))
        XCTAssertNotNil(plugin.covertAnyToEncodable(NSNumber(booleanLiteral: true)))
        
        let nsnumberPoint = NSNumber(cgPoint: .init(x: 3, y: 3))
        XCTAssertNil(plugin.covertAnyToEncodable(nsnumberPoint))
        XCTAssertNil(plugin.covertAnyToEncodable(NSNumber(cgRect: .init())))
        XCTAssertNil(plugin.covertAnyToEncodable(NSNumber(cgSize: .init())))
        XCTAssertNil(plugin.covertAnyToEncodable(NSNumber(cgVector: .init())))
        XCTAssertNil(plugin.covertAnyToEncodable(NSNumber(cgAffineTransform: .init())))
        XCTAssertNil(plugin.covertAnyToEncodable(NSNumber(uiOffset: .init())))
        XCTAssertNil(plugin.covertAnyToEncodable(NSNumber(uiEdgeInsets: .init())))
        XCTAssertNil(plugin.covertAnyToEncodable(NSNumber(range: .init())))
        XCTAssertNil(plugin.covertAnyToEncodable(NSNumber(caTransform3D: .init())))
        
        XCTAssertNil(plugin.covertAnyToEncodable(["array not supported"]))
        XCTAssertNil(plugin.covertAnyToEncodable(["not supported": "dictionary"]))
    }
}
