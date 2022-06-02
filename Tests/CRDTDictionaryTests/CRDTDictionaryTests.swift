import XCTest
@testable import CRDTDictionary

final class CRDTDictionaryTests: XCTestCase {
    
    // MARK: - Add & Remove
    
    func testAddItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        XCTAssertEqual(crdtDictionary.additions.count, 1)
    }
    
    func testAddItemThenAddMoreRecentItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.add(key: "key", value: "value2", timestamp: Date.distantFuture.timeIntervalSince1970)
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
    }
    
    func testAddItemThenAddOlderItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.add(key: "key", value: "value2", timestamp: Date.distantPast.timeIntervalSince1970)
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value")
    }
    
    func testRemoveItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.remove(key: "key", value: "value", timestamp: Date().timeIntervalSince1970)
        XCTAssertEqual(crdtDictionary.removals.count, 1)
    }
    
    func testRemoveItemThenRemoveMoreRecentItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value2", timestamp: Date.distantFuture.timeIntervalSince1970)
        XCTAssertEqual(crdtDictionary.removals.count, 1)
        XCTAssertNil(crdtDictionary["key"])
    }
    
    func testAddItemThenRemoveMoreRecentItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value2", timestamp: Date.distantFuture.timeIntervalSince1970)
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertEqual(crdtDictionary.removals.count, 1)
        XCTAssertNil(crdtDictionary["key"])
    }
    
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
    
    func testAddItemThenUpdateItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.update(key: "key", value: "value2")
        XCTAssertEqual(crdtDictionary.additions.count, 1)
        XCTAssertEqual(crdtDictionary.removals.count, 0)
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
    }
    
    func testAddRemoveThenUpdateItem() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.update(key: "key", value: "value2")
        XCTAssertNil(crdtDictionary["key"])
        XCTAssertNotEqual(crdtDictionary["key"]?.value, "value2")
    }
    
    func testAddRemoveAddThenUpdate() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.update(key: "key", value: "value2")
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
    }
    
    // MARK: - Merge
    
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
    
    func testMergeTwoDictionariesCommutative() throws {
        let crdtDictionary = CRDTDictionary<String>()
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.remove(key: "key", value: "value")
        crdtDictionary.add(key: "key", value: "value")
        crdtDictionary.update(key: "key", value: "value2")
        XCTAssertNotNil(crdtDictionary["key"])
        XCTAssertEqual(crdtDictionary["key"]?.value, "value2")
    }

}
