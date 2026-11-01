import XCTest
@testable import Ember

@MainActor
final class EmberTests: XCTestCase {
    func testHotelKneesPlanFollowsTheTable() {
        let setup = SetupInput(difficulty: 3, durationMinutes: 6, place: .hotel, discomfortAreas: [.knees])
        let plan = WorkoutGenerator.makePlan(from: setup, now: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(plan.items.map(\.name), [
            "Knee push-up",
            "Hip hinge",
            "Glute bridge",
            "Plank",
            "Thoracic rotation",
            "Knee ease"
        ])
        XCTAssertEqual(plan.items.last?.workSec, 60)
        XCTAssertEqual(plan.items.last?.restSec, 0)
        XCTAssertTrue(plan.items.last?.isSelfMassage == true)
        XCTAssertEqual(plan.totalSec, 360)
        XCTAssertEqual(plan.reason, "No squats, lunges, or jumps: knees were marked and the place is a hotel.")
        let again = WorkoutGenerator.makePlan(from: setup, now: Date(timeIntervalSince1970: 1))
        XCTAssertEqual(again.items.map(\.name), plan.items.map(\.name))
    }

    func testShouldersReplaceThePushSlot() {
        let setup = SetupInput(difficulty: 3, durationMinutes: 5, place: .home, discomfortAreas: [.shoulders])
        let plan = WorkoutGenerator.makePlan(from: setup)
        XCTAssertEqual(plan.items.first?.name, "Squat")
        XCTAssertFalse(plan.items.contains { $0.name == "Plank" })
    }

    func testSkipBreakAndExtraRest() {
        let items = [
            PlanItem(id: "a", exerciseId: "a", name: "A", pattern: .push, workSec: 2, restSec: 2, cue: "", isSelfMassage: false),
            PlanItem(id: "b", exerciseId: "b", name: "B", pattern: .core, workSec: 2, restSec: 0, cue: "", isSelfMassage: false)
        ]
        var engine = SessionEngine(items: items)
        engine.tick()
        engine.tick()
        XCTAssertEqual(engine.phase, .rest)
        XCTAssertEqual(engine.remaining, 2)
        engine.moreRest()
        XCTAssertEqual(engine.remaining, 17)
        engine.moreRest()
        XCTAssertEqual(engine.remaining, 17)
        XCTAssertEqual(engine.records[0].restAction, .extraRest)
        engine.skipBreak()
        XCTAssertEqual(engine.index, 1)
        XCTAssertEqual(engine.phase, .work)
        XCTAssertEqual(engine.records[0].result, .completed)
    }

    func testEndEarlyMarksTheSessionStopped() {
        let items = [
            PlanItem(id: "a", exerciseId: "a", name: "A", pattern: .push, workSec: 10, restSec: 5, cue: "", isSelfMassage: false)
        ]
        var engine = SessionEngine(items: items)
        engine.tick()
        engine.endEarly()
        XCTAssertEqual(engine.phase, .finished)
        XCTAssertEqual(engine.status, .stopped)
        XCTAssertEqual(engine.records[0].result, .skipped)
        XCTAssertEqual(engine.records[0].elapsedSec, 1)
    }

    func testFeedbackSetsTheNextDifficultyOnce() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = AppStore(directory: directory)
        let setup = SetupInput(difficulty: 3, durationMinutes: 10, place: .hotel, discomfortAreas: [.knees])
        store.rememberSetup(setup)
        let plan = WorkoutGenerator.makePlan(from: setup)
        let session = WorkoutSession(
            sessionId: UUID(),
            planId: plan.planId,
            startedAt: Date(timeIntervalSince1970: 10),
            endedAt: Date(timeIntervalSince1970: 20),
            status: .completed,
            items: []
        )
        store.saveFinished(plan: plan, session: session, perceived: .tooHard, areas: [.knees])

        let next = store.prefilledSetup()
        XCTAssertEqual(next.difficulty, 2)
        XCTAssertEqual(next.durationMinutes, 10)
        XCTAssertEqual(next.discomfortAreas, [.knees])
        XCTAssertEqual(store.snapshot.lastDifficulty, 2)
        XCTAssertEqual(store.prefilledSetup().difficulty, 2)
        XCTAssertEqual(store.statusLine, "Last time: too hard · knees")
        XCTAssertEqual(store.activitiesNewestFirst.first?.title, "Daily Pick")

        let reloaded = AppStore(directory: directory)
        XCTAssertEqual(reloaded.snapshot.activities.count, 1)
        XCTAssertEqual(reloaded.prefilledSetup().difficulty, 2)
    }
}
