import XCTest
@testable import BathTime

@MainActor
final class BathTimeTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeEntryLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        let added = store.add(CareEventEntry(title: "Test entry"))
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCannotAddBeyondFreeLimitWhenNotPro() {
        store.isPro = false
        while store.entries.count < Store.freeEntryLimit {
            _ = store.add(CareEventEntry(title: "Filler"))
        }
        let added = store.add(CareEventEntry(title: "Overflow"))
        XCTAssertFalse(added)
    }

    func testProUserCanExceedFreeLimit() {
        store.isPro = true
        for _ in 0..<(Store.freeEntryLimit + 5) {
            _ = store.add(CareEventEntry(title: "Pro filler"))
        }
        XCTAssertGreaterThan(store.entries.count, Store.freeEntryLimit)
    }

    func testDeleteEntryRemovesIt() {
        let entry = CareEventEntry(title: "To delete")
        _ = store.add(entry)
        XCTAssertTrue(store.entries.contains(where: { $0.id == entry.id }))
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testDeleteAtOffsetsRemovesCorrectEntry() {
        store.entries = []
        let a = CareEventEntry(title: "A")
        let b = CareEventEntry(title: "B")
        store.entries = [a, b]
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.title, "B")
    }

    func testSettingsPersistAcrossReload() {
        store.settings.remindersEnabled = false
        store.saveSettings()
        let reloaded = Store()
        XCTAssertFalse(reloaded.settings.remindersEnabled)
    }
}
