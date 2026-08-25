import XCTest
@testable import ZikrCompanion

@MainActor
final class SessionStoreTests: XCTestCase {
    private var suiteNames: [String] = []

    override func tearDown() {
        for suiteName in suiteNames {
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
        }
        suiteNames = []
        super.tearDown()
    }

    func testIncrementIncreasesCount() {
        let context = makeContext()
        context.store.increment()
        XCTAssertEqual(context.store.count, 1)
    }

    func testSessionCompletesAtMorningTarget() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        XCTAssertTrue(context.store.isSessionComplete)
        XCTAssertEqual(context.store.streak, 1)
    }

    func testSessionCompletesAtEveningTarget() {
        let context = makeContext()
        context.store.selectRoutine(.evening)
        completeCurrentRoutine(in: context.store)
        XCTAssertTrue(context.store.isSessionComplete)
        XCTAssertEqual(context.store.count, 33)
    }

    func testResetCountResetsToZeroWithoutChangingStreak() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        context.store.resetCount()
        XCTAssertEqual(context.store.count, 0)
        XCTAssertFalse(context.store.isSessionComplete)
        XCTAssertEqual(context.store.streak, 1)
    }

    func testSelectRoutineResetsCount() {
        let context = makeContext()
        for _ in 0..<10 { context.store.increment() }
        context.store.selectRoutine(.evening)
        XCTAssertEqual(context.store.count, 0)
        XCTAssertEqual(context.store.selectedRoutine, .evening)
    }

    func testSelectSameRoutineDoesNotResetCount() {
        let context = makeContext()
        for _ in 0..<10 { context.store.increment() }
        context.store.selectRoutine(.morning)
        XCTAssertEqual(context.store.count, 10)
    }

    func testSameDayCompletionsIncrementStreakOnlyOnce() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        context.store.selectRoutine(.evening)
        completeCurrentRoutine(in: context.store)
        XCTAssertEqual(context.store.streak, 1)
        XCTAssertEqual(context.store.history.count, 2)
    }

    func testConsecutiveDayIncreasesStreak() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        context.clock.now = date(day: 27)
        context.store.refreshForCurrentDay()
        completeCurrentRoutine(in: context.store)
        XCTAssertEqual(context.store.streak, 2)
    }

    func testMissedDayClearsDisplayedStreak() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        context.clock.now = date(day: 28)
        context.store.refreshForCurrentDay()
        XCTAssertEqual(context.store.streak, 0)
    }

    func testCompletionAfterMissedDayStartsNewStreak() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        context.clock.now = date(day: 28)
        context.store.refreshForCurrentDay()
        completeCurrentRoutine(in: context.store)
        XCTAssertEqual(context.store.streak, 1)
    }

    func testCountResetsWhenAppStaysOpenAcrossMidnight() {
        let context = makeContext()
        for _ in 0..<25 { context.store.increment() }
        context.clock.now = date(day: 27)
        context.store.refreshForCurrentDay()
        XCTAssertEqual(context.store.count, 0)
        XCTAssertFalse(context.store.isSessionComplete)
    }

    func testFirstIncrementAfterMidnightRefreshesDayAutomatically() {
        let context = makeContext()
        for _ in 0..<25 { context.store.increment() }
        context.clock.now = date(day: 27)
        context.store.increment()
        XCTAssertEqual(context.store.count, 1)
    }

    func testCountPersistsAcrossInstancesOnSameDay() {
        let context = makeContext()
        for _ in 0..<7 { context.store.increment() }
        let restoredStore = makeStore(defaults: context.defaults, clock: context.clock)
        XCTAssertEqual(restoredStore.count, 7)
    }

    func testHistoryPersistsAcrossInstances() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        let restoredStore = makeStore(defaults: context.defaults, clock: context.clock)
        XCTAssertEqual(restoredStore.history.count, 1)
        XCTAssertEqual(restoredStore.history.first?.routineType, .morning)
    }

    func testLegacyCompletedSessionMigratesIntoHistory() {
        let context = makeContext()
        context.defaults.set(100, forKey: "zc_count")
        context.defaults.set(context.clock.now, forKey: "zc_countDate")
        context.defaults.set(context.clock.now, forKey: "zc_lastSessionDate")

        let restoredStore = makeStore(defaults: context.defaults, clock: context.clock)

        XCTAssertTrue(restoredStore.isSessionComplete)
        XCTAssertEqual(restoredStore.history.count, 1)
        XCTAssertEqual(restoredStore.history.first?.routineType, .morning)
    }

    func testCompletingSameRoutineTwiceInOneDayDoesNotDuplicateHistory() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        context.store.resetCount()
        completeCurrentRoutine(in: context.store)
        XCTAssertEqual(context.store.history.count, 1)
    }

    func testProgressComputedCorrectly() {
        let context = makeContext()
        for _ in 0..<50 { context.store.increment() }
        XCTAssertEqual(context.store.progress, 0.5, accuracy: 0.01)
    }

    func testRemainingNeverBecomesNegative() {
        let context = makeContext()
        completeCurrentRoutine(in: context.store)
        XCTAssertEqual(context.store.remaining, 0)
    }

    private func makeContext() -> TestContext {
        let suiteName = "ZikrCompanionTests.\(UUID().uuidString)"
        suiteNames.append(suiteName)
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Impossible de créer les UserDefaults de test")
        }
        defaults.removePersistentDomain(forName: suiteName)
        let clock = MutableDateProvider(now: date(day: 26))
        return TestContext(
            defaults: defaults,
            clock: clock,
            store: makeStore(defaults: defaults, clock: clock)
        )
    }

    private func makeStore(
        defaults: UserDefaults,
        clock: MutableDateProvider
    ) -> SessionStore {
        SessionStore(
            defaults: defaults,
            calendar: calendar,
            now: { clock.now }
        )
    }

    private func completeCurrentRoutine(in store: SessionStore) {
        for _ in store.count..<store.currentTarget {
            store.increment()
        }
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func date(day: Int) -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: 2026,
            month: 8,
            day: day,
            hour: 12
        )
        guard let date = calendar.date(from: components) else {
            fatalError("Date de test invalide")
        }
        return date
    }
}

@MainActor
private final class MutableDateProvider {
    var now: Date

    init(now: Date) {
        self.now = now
    }
}

@MainActor
private struct TestContext {
    let defaults: UserDefaults
    let clock: MutableDateProvider
    let store: SessionStore
}
