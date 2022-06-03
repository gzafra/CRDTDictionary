import Foundation
import AppKit


public protocol CRDTDictionaryProtocol {
    associatedtype ValueType: Hashable
    func add(key: String, value: ValueType, timestamp: TimeInterval)
    func remove(key: String, value: ValueType, timestamp: TimeInterval)
    func elements() -> [String: CRDTElement<ValueType>]
    func update(key: String, value: ValueType, timestamp: TimeInterval)
    func merge(with other: CRDTDictionary<ValueType>)
    subscript(key: String) -> ValueType? { get }
}

public final class CRDTDictionary<ValueType: Hashable>: CRDTDictionaryProtocol {
    internal var additions = [String: CRDTElement<ValueType>]()
    internal var removals = [String: CRDTElement<ValueType>]()
    
    public init() {}
    
    public func add(key: String, value: ValueType, timestamp: TimeInterval = Date.now.timeIntervalSince1970) {
        let newValue = CRDTElement(value: value, timestamp: timestamp)
        
        guard let alreadyAdded = additions[key] else {
            additions[key] = newValue
            return
        }
        
        if alreadyAdded.timestamp < timestamp {
            additions[key] = newValue
        }
    }
    
    public func remove(key: String, value: ValueType, timestamp: TimeInterval = Date.now.timeIntervalSince1970) {
        let newValue = CRDTElement(value: value, timestamp: timestamp)
        
        guard let alreadyRemoved = removals[key] else {
            removals[key] = newValue
            return
        }
        
        if alreadyRemoved.timestamp < timestamp {
            removals[key] = newValue
        }
    }
    
    public func elements() -> [String: CRDTElement<ValueType>] {
        additions.filter { key, addition in
            guard let removed = removals[key] else { return true }
            return removed.timestamp < addition.timestamp
        }
    }
    
    public func update(key: String, value: ValueType, timestamp: TimeInterval = Date.now.gmt.timeIntervalSince1970) {
        guard elements()[key] != nil else { return }
        add(key: key, value: value, timestamp: timestamp)
    }
    
    
    public func merge(with other: CRDTDictionary<ValueType>) {
        other.additions.forEach { key, element in
            add(key: key, value: element.value, timestamp: element.timestamp)
        }
        other.removals.forEach { key, element in
            remove(key: key, value: element.value, timestamp: element.timestamp)
        }
    }
    
    public subscript(key: String) -> ValueType? {
        elements()[key]?.value
    }
}
