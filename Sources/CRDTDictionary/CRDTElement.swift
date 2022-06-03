import Foundation

public final class CRDTElement<T: Hashable>: Hashable {
    public let value: T
    public let timestamp: TimeInterval

    internal init(value: T, timestamp: TimeInterval) {
        self.value = value
        self.timestamp = timestamp
    }
    
    public static func == (lhs: CRDTElement, rhs: CRDTElement) -> Bool {
        lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
