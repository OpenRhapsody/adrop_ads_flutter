import Foundation

extension Date {
    var currentTimeMillis: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    init(millis: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
    }
}
