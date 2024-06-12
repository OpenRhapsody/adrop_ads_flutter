import Foundation

extension UIColor {
    convenience init(fromFlutterColor value: UInt32) {
        let alpha = CGFloat((value & 0xFF000000) >> 24) / 255.0
        let red = CGFloat((value & 0x00FF0000) >> 16) / 255.0
        let green = CGFloat((value & 0x0000FF00) >> 8) / 255.0
        let blue = CGFloat(value & 0x000000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
