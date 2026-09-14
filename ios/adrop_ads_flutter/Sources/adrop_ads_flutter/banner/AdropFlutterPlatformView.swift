import Flutter

class AdropFlutterPlatformView: NSObject, FlutterPlatformView {
    
    var adropView: UIView
    
    init(view: UIView) {
        self.adropView = view
    }
    
    func view() -> UIView {
        return self.adropView
    }
    
}
