import Foundation

enum Pattern: String, Codable, CaseIterable, Hashable {
    case push, squat, hinge, core, mobility
}

enum Area: String, Codable, CaseIterable, Identifiable, Hashable {
    case shoulders, lowerBack, knees, wrists

    var id: String { rawValue }

    var label: String {
        switch self {
        case .shoulders: "Shoulders"
        case .lowerBack: "Lower back"
        case .knees: "Knees"
        case .wrists: "Wrists"
        }
    }

    var easeName: String {
        switch self {
        case .shoulders: "Shoulder"
        case .lowerBack: "Back"
        case .knees: "Knee"
        case .wrists: "Wrist"
        }
    }
}

enum Place: String, Codable, CaseIterable, Identifiable, Hashable {
    case dorm, home, hotel, outdoors

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dorm: "Dorm"
        case .home: "Home"
        case .hotel: "Hotel"
        case .outdoors: "Outdoors"
        }
    }
}

enum Feeling: Int, Codable, CaseIterable, Identifiable, Hashable {
    case veryLow = 1
    case low = 2
    case okay = 3
    case good = 4
    case great = 5

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .veryLow: "Very low"
        case .low: "Low"
        case .okay: "Okay"
        case .good: "Good"
        case .great: "Great"
        }
    }

    static func from(difficulty: Int) -> Feeling {
        Feeling(rawValue: min(5, max(1, difficulty))) ?? .okay
    }
}

struct Exercise: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var pattern: Pattern
    var level: Int
    var loads: Set<Area>
    var isJump: Bool
    var isLunge: Bool
    var cue: String
}

struct SetupInput: Codable, Hashable {
    var difficulty: Int
    var durationMinutes: Int
    var place: Place?
    var discomfortAreas: Set<Area>

    var feeling: Feeling { Feeling.from(difficulty: difficulty) }
}

struct PlanItem: Identifiable, Codable, Hashable {
    var id: String
    var exerciseId: String
    var name: String
    var pattern: Pattern
    var workSec: Int
    var restSec: Int
    var cue: String
    var isSelfMassage: Bool
}

struct WorkoutPlan: Identifiable, Codable, Hashable {
    var planId: UUID
    var createdAt: Date
    var setup: SetupInput
    var items: [PlanItem]
    var totalSec: Int
    var reason: String

    var id: UUID { planId }
}

enum SessionStatus: String, Codable, Hashable {
    case completed, stopped
}

enum ItemResult: String, Codable, Hashable {
    case completed, skipped
}

enum RestAction: String, Codable, Hashable {
    case none, skippedBreak, extraRest
}

struct SessionItemRecord: Identifiable, Codable, Hashable {
    var index: Int
    var exerciseId: String
    var name: String
    var result: ItemResult
    var elapsedSec: Int
    var restAction: RestAction

    var id: String { "\(index)-\(exerciseId)" }
}

struct WorkoutSession: Identifiable, Codable, Hashable {
    var sessionId: UUID
    var planId: UUID
    var startedAt: Date
    var endedAt: Date
    var status: SessionStatus
    var items: [SessionItemRecord]

    var id: UUID { sessionId }
}

enum Perceived: String, Codable, CaseIterable, Identifiable, Hashable {
    case tooEasy, aboutRight, tooHard

    var id: String { rawValue }

    var label: String {
        switch self {
        case .tooEasy: "Too easy"
        case .aboutRight: "About right"
        case .tooHard: "Too hard"
        }
    }
}

struct Feedback: Identifiable, Codable, Hashable {
    var id: UUID
    var sessionId: UUID
    var perceived: Perceived
    var areas: Set<Area>
    var createdAt: Date
}

enum ActivityOrigin: String, Codable, Hashable {
    case inApp, external
}

struct Activity: Identifiable, Codable, Hashable {
    var activityId: UUID
    var occurredAt: Date
    var origin: ActivityOrigin
    var title: String
    var durationMin: Int
    var kind: String
    var sessionId: UUID?

    var id: UUID { activityId }
}

struct StoreSnapshot: Codable, Hashable {
    var lastDifficulty: Int
    var lastDuration: Int
    var plans: [WorkoutPlan]
    var sessions: [WorkoutSession]
    var feedback: [Feedback]
    var activities: [Activity]

    static let empty = StoreSnapshot(
        lastDifficulty: 3,
        lastDuration: 10,
        plans: [],
        sessions: [],
        feedback: [],
        activities: []
    )
}
