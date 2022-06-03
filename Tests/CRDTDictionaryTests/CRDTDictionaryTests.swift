import XCTest
@testable import CRDTDictionary

final class CRDTDictionaryTests: XCTestCase {
    
    // MARK: - Add & Remove
    
    /**
     Tests the addition of one key-value pair
     */
    func testAddItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        XCTAssertEqual(crdtDictionary.additions.count, 1)
    }
    
    /**
     Tests the addition of one key-value pair and inmediately adding another value with same key
     */
    func testAddItemThenAddMoreRecentItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.add(key: "key", value: "value2")
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
    }
    
    /**
     Tests the addition of one key-value pair then adding another value with an older timestamp
     */
    func testAddItemThenAddOlderItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.add(key: "key", value: "value2", timestamp: Date.distantPast.timeIntervalSince1970)
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value")
    }
    
    /**
     Tests the removal of one key-value pair
     */
    func testRemoveItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.remove(key: "key", value: "value", timestamp: Date().timeIntervalSince1970)
        XCTAssertEqual(crdtDictionary.removals.count, 1)
    }
    
    /**
     Tests the removal of one key-value pair and inmediately removing another value with same key
     */
    func testRemoveItemThenRemoveMoreRecentItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value2")
        XCTAssertEqual(crdtDictionary.removals.count, 1)
        XCTAssertNil(crdtDictionary["key"])
    }
    
    /**
     Tests the addition of one key-value pair and inmediately removing a value with same key
     */
    func testAddItemThenRemoveMoreRecentItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value2")
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertEqual(crdtDictionary.removals.count, 1)
        XCTAssertNil(crdtDictionary["key"])
    }
    
    /**
     Tests the addition of one key-value pair then removing another value with an older timestamp
     */
    func testAddItemThenRemoveOlderItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value2", timestamp: Date.distantPast.timeIntervalSince1970)
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertEqual(crdtDictionary.removals.count, 1)
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value")
    }
    
    // MARK: - Update
    
    /**
     Tests the addition of one key-value pair then updating it with another value
     */
    func testAddItemThenUpdateItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.update(key: "key", value: "value2")
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertEqual(crdtDictionary.removals.count, 0)
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
    }
    
    /**
     Tests the addition of one key-value pair then inmediately removing that key-value pair and trying to update it afterwards
     */
    func testAddRemoveThenUpdateItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.update(key: "key", value: "value2")
        XCTAssertNil(crdtDictionary["key"])
        XCTAssertNotEqual(crdtDictionary["key"]?.value, "value2")
    }
    
    /**
     Tests the addition of one key-value pair, inmediately removing it and adding another value with same key inmediately after, then updating it
     */
    func testAddRemoveAddThenUpdate() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.add(key: "key", value: "value", timestamp: Date.now.addingTimeInterval(1).timeIntervalSince1970)
        crdtDictionary.update(key: "key", value: "value2", timestamp: Date.now.addingTimeInterval(2).timeIntervalSince1970)
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
    }
    
    // MARK: - Merge
    /**
     Tests merging of two dictionaries with only additions
     */
    func testMergeTwoDictionariesOnlyAdditions() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value", timestamp: Date.distantFuture.timeIntervalSince1970)
        crdtDictionary.add(key: "key2", value: "value")
        
        let otherCrdtDictionary = CRDTDictionary<String>()
        otherCrdtDictionary.add(key: "key", value: "value2")
        otherCrdtDictionary.add(key: "key2", value: "value2")
        
        crdtDictionary.merge(with: otherCrdtDictionary)

        XCTAssertEqual(crdtDictionary.additions.count, 2)
        XCTAssertEqual(crdtDictionary["key"]?.value, "value")
        XCTAssertEqual(crdtDictionary["key2"]?.value, "value2")
    }
    
    /**
     Tests merging of two dictionaries with additions and removals
     */
    func testMergeTwoDictionariesAdditionsAndRemovals() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.add(key: "key2", value: "value")
        crdtDictionary.remove(key: "key2", value: "value")
        crdtDictionary.add(key: "key2", value: "value3", timestamp: Date.distantFuture.timeIntervalSince1970)
        
        let otherCrdtDictionary = CRDTDictionary<String>()
        otherCrdtDictionary.add(key: "key", value: "value2")
        otherCrdtDictionary.add(key: "key2", value: "value2")
        otherCrdtDictionary.remove(key: "key2", value: "value2")
        
        crdtDictionary.merge(with: otherCrdtDictionary)

        XCTAssertEqual(crdtDictionary.additions.count, 2)
        XCTAssertEqual(crdtDictionary.removals.count, 2)
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
        XCTAssertEqual(crdtDictionary["key2"]?.value, "value3")
    }
    
    /**
     Tests indempotency property of dictionaries: Merging with the same dictionary twice.
     */
    func testMergeTwoDictionariesIdempotent() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.add(key: "key2", value: "value")
        crdtDictionary.remove(key: "key2", value: "value")
        crdtDictionary.add(key: "key2", value: "value3", timestamp: Date.distantFuture.timeIntervalSince1970)
        
        let otherCrdtDictionary = CRDTDictionary<String>()
        otherCrdtDictionary.add(key: "key", value: "value2")
        otherCrdtDictionary.add(key: "key2", value: "value2")
        otherCrdtDictionary.remove(key: "key2", value: "value2")
        
        crdtDictionary.merge(with: otherCrdtDictionary)
        crdtDictionary.merge(with: otherCrdtDictionary)

        XCTAssertEqual(crdtDictionary.additions.count, 2)
        XCTAssertEqual(crdtDictionary.removals.count, 2)
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
        XCTAssertEqual(crdtDictionary["key2"]?.value, "value3")
    }
    
    /**
     Tests commutative property of dictionaries: Merging 2 dictionaries in different order should result in the same dictionary state.
     */
    func testMergeTwoDictionariesCommutative() throws {
        let lhsDictionary = CRDTDictionary<String>()
        lhsDictionary.add(key: "key", value: "value", timestamp: Date.distantFuture.timeIntervalSince1970)
        lhsDictionary.add(key: "key2", value: "value")
        
        let rhsDictionary = CRDTDictionary<String>()
        rhsDictionary.add(key: "key", value: "value2")
        rhsDictionary.add(key: "key2", value: "value2")
        
        let firstMergeDictionary = CRDTDictionary<String>()
        firstMergeDictionary.merge(with: lhsDictionary)
        firstMergeDictionary.merge(with: rhsDictionary)
        
        let secondMergeDictionary = CRDTDictionary<String>()
        secondMergeDictionary.merge(with: lhsDictionary)
        secondMergeDictionary.merge(with: rhsDictionary)

        XCTAssertEqual(firstMergeDictionary.additions.count, secondMergeDictionary.additions.count)
        XCTAssertEqual(firstMergeDictionary.removals.count, secondMergeDictionary.removals.count)
        XCTAssertEqual(firstMergeDictionary["key"]?.value, secondMergeDictionary["key"]?.value)
        XCTAssertEqual(firstMergeDictionary["key2"]?.value, secondMergeDictionary["key2"]?.value)
    }
    
    /**
     Tests associative property of dictionaries: Merging 2 dictionaries together and then another time should result in same dictionary state.
     */
    func testMergeTwoDictionariesAssociative() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.add(key: "key2", value: "value")
        crdtDictionary.remove(key: "key2", value: "value")
        crdtDictionary.add(key: "key2", value: "value3", timestamp: Date.distantFuture.timeIntervalSince1970)
        
        let otherCrdtDictionary = CRDTDictionary<String>()
        otherCrdtDictionary.add(key: "key", value: "value2")
        otherCrdtDictionary.add(key: "key2", value: "value2")
        otherCrdtDictionary.remove(key: "key2", value: "value2")
        
        crdtDictionary.merge(with: otherCrdtDictionary)
        otherCrdtDictionary.merge(with: crdtDictionary)

        XCTAssertEqual(crdtDictionary.additions.count, otherCrdtDictionary.additions.count)
        XCTAssertEqual(crdtDictionary.removals.count, otherCrdtDictionary.removals.count)
        XCTAssertEqual(crdtDictionary["key"]?.value, otherCrdtDictionary["key"]?.value)
        XCTAssertEqual(crdtDictionary["key2"]?.value, otherCrdtDictionary["key2"]?.value)
    }
}
