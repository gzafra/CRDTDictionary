import Foundation

public class CRDTDictionary<ValueType: Hashable> {
    var additions = [String: CRDTElement<ValueType>]()
    var removals = [String: CRDTElement<ValueType>]()
    
    public init() {}
    
    func add(key: String, value: ValueType, timestamp: TimeInterval = Date.now.timeIntervalSince1970) {
        let newValue = CRDTElement(value: value, timestamp: timestamp)
        
        guard let alreadyAdded = additions[key] else {
            additions[key] = newValue
            return
        }
        
        if alreadyAdded.timestamp < timestamp {
            additions[key] = newValue
        }
    }
    
    func remove(key: String, value: ValueType, timestamp: TimeInterval = Date.now.timeIntervalSince1970) {
        let newValue = CRDTElement(value: value, timestamp: timestamp)
        
        guard let alreadyRemoved = removals[key] else {
            removals[key] = newValue
            return
        }
        
        if alreadyRemoved.timestamp < timestamp {
            removals[key] = newValue
        }
    }
    
    func allItems() -> [String: CRDTElement<ValueType>] {
        additions.filter { key, addition in
            guard let removed = removals[key] else { return true }
            return removed.timestamp < addition.timestamp
        }
    }
    
    func update(key: String, value: ValueType, timestamp: TimeInterval = Date.now.gmt.timeIntervalSince1970) {
        guard allItems()[key] != nil else { return }
        add(key: key, value: value, timestamp: timestamp)
    }
    
    
    func merge(with other: CRDTDictionary<ValueType>) {
        other.additions.forEach { key, element in
            add(key: key, value: element.value, timestamp: element.timestamp)
        }
        other.removals.forEach { key, element in
            remove(key: key, value: element.value, timestamp: element.timestamp)
        }
    }
    
    subscript(key: String) -> CRDTElement<ValueType>? {
        allItems()[key]
    }
}

class CRDTElement<T: Hashable>: Hashable {
    let value: T
    let timestamp: TimeInterval

    internal init(value: T, timestamp: TimeInterval) {
        self.value = value
        self.timestamp = timestamp
    }
    
    static func == (lhs: CRDTElement, rhs: CRDTElement) -> Bool {
        lhs.value == rhs.value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}


extension Date {
    var gmt: Date {
        let timeZone = TimeZone.current
        let seconds: TimeInterval = Double(timeZone.secondsFromGMT(for:self))
        let localDate = Date(timeInterval: seconds, since: self)
        return localDate
    }
}
