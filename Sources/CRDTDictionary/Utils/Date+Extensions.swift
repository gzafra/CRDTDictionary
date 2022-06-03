import Foundation

public extension Date {
    var gmt: Date {
        let timeZone = TimeZone.current
        let seconds: TimeInterval = Double(timeZone.secondsFromGMT(for:self))
        let localDate = Date(timeInterval: seconds, since: self)
        return localDate
    }
}
