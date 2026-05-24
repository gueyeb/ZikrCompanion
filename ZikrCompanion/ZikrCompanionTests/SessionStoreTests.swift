import XCTest
@testable import ZikrCompanion

@MainActor
final class SessionStoreTests: XCTestCase {

    private func makeDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return defaults
    }

    private func makeStore(_ defaults: UserDefaults) -> SessionStore {
        SessionStore(defaults: defaults)
    }

    // MARK: - Increment

    func testIncrementIncreasesCount() {
        let store = makeStore(makeDefaults())
        store.increment()
        XCTAssertEqual(store.count, 1)
    }

    func testSessionCompletesAtMorningTarget() {
        let d = makeDefaults()
        d.set(RoutineType.morning.rawValue, forKey: "zc_selectedRoutine")
        let store = makeStore(d)
        for _ in 0..<99 { store.increment() }
        XCTAssertFalse(store.isSessionComplete)
        store.increment()
        XCTAssertTrue(store.isSessionComplete)
    }

    func testSessionCompletesAtEveningTarget() {
        let d = makeDefaults()
        d.set(RoutineType.evening.rawValue, forKey: "zc_selectedRoutine")
        let store = makeStore(d)
        for _ in 0..<32 { store.increment() }
        XCTAssertFalse(store.isSessionComplete)
        store.increment()
        XCTAssertTrue(store.isSessionComplete)
    }

    // MARK: - Reset

    func testResetCountResetsToZero() {
        let store = makeStore(makeDefaults())
        store.increment()
        store.increment()
        store.resetCount()
        XCTAssertEqual(store.count, 0)
        XCTAssertFalse(store.isSessionComplete)
    }

    // MARK: - Routine Switch

    func testSelectRoutineResetsCount() {
        let store = makeStore(makeDefaults())
        for _ in 0..<10 { store.increment() }
        store.selectRoutine(.evening)
        XCTAssertEqual(store.count, 0)
        XCTAssertEqual(store.selectedRoutine, .evening)
    }

    func testSelectSameRoutineDoesNotResetCount() {
        let store = makeStore(makeDefaults())
        for _ in 0..<10 { store.increment() }
        store.selectRoutine(.morning)
        XCTAssertEqual(store.count, 10)
    }

    // MARK: - Streak

    func testFirstCompletionSetsStreakToOne() {
        let d = makeDefaults()
        d.set(RoutineType.morning.rawValue, forKey: "zc_selectedRoutine")
        let store = makeStore(d)
        for _ in 0..<100 { store.increment() }
        XCTAssertEqual(store.streak, 1)
    }

    func testSameDayCompletionDoesNotIncrementStreak() {
        let d = makeDefaults()
        d.set(RoutineType.morning.rawValue, forKey: "zc_selectedRoutine")
        d.set(Date(), forKey: "zc_lastSessionDate")
        d.set(5, forKey: "zc_streak")
        let store = makeStore(d)
        for _ in 0..<100 { store.increment() }
        XCTAssertEqual(store.streak, 5)
    }

    func testConsecutiveDayIncreasesStreak() {
        let d = makeDefaults()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        d.set(RoutineType.morning.rawValue, forKey: "zc_selectedRoutine")
        d.set(yesterday, forKey: "zc_lastSessionDate")
        d.set(3, forKey: "zc_streak")
        let store = makeStore(d)
        for _ in 0..<100 { store.increment() }
        XCTAssertEqual(store.streak, 4)
    }

    func testMissedDayResetsStreakToOne() {
        let d = makeDefaults()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        d.set(RoutineType.morning.rawValue, forKey: "zc_selectedRoutine")
        d.set(twoDaysAgo, forKey: "zc_lastSessionDate")
        d.set(10, forKey: "zc_streak")
        let store = makeStore(d)
        for _ in 0..<100 { store.increment() }
        XCTAssertEqual(store.streak, 1)
    }

    // MARK: - Persistence

    func testCountPersistedAcrossInstances() {
        let d = makeDefaults()
        let store = makeStore(d)
        for _ in 0..<7 { store.increment() }
        let store2 = makeStore(d)
        XCTAssertEqual(store2.count, 7)
    }

    func testCountResetsOnNewDay() {
        let d = makeDefaults()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        d.set(50, forKey: "zc_count")
        d.set(yesterday, forKey: "zc_countDate")
        let store = makeStore(d)
        XCTAssertEqual(store.count, 0)
    }

    func testCountPreservedSameDay() {
        let d = makeDefaults()
        d.set(50, forKey: "zc_count")
        d.set(Date(), forKey: "zc_countDate")
        let store = makeStore(d)
        XCTAssertEqual(store.count, 50)
    }

    // MARK: - Computed helpers

    func testProgressComputedCorrectly() {
        let store = makeStore(makeDefaults())
        for _ in 0..<50 { store.increment() }
        XCTAssertEqual(store.progress, 0.5, accuracy: 0.01)
    }

    func testRemainingComputedCorrectly() {
        let store = makeStore(makeDefaults())
        for _ in 0..<30 { store.increment() }
        XCTAssertEqual(store.remaining, 70)
    }

    func testProgressCapsAtOne() {
        let d = makeDefaults()
        d.set(RoutineType.morning.rawValue, forKey: "zc_selectedRoutine")
        let store = makeStore(d)
        for _ in 0..<105 { store.increment() }
        XCTAssertEqual(store.progress, 1.0)
    }
}
