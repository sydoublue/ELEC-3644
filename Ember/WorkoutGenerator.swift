import Foundation

enum WorkoutGenerator {
    /// Proposal table in section 2.2. The same SetupInput always returns the same plan.
    static func makePlan(
        from setup: SetupInput,
        now: Date = .now,
        library: [Exercise] = ExerciseLibrary.all
    ) -> WorkoutPlan {
        let (work, rest) = bout(for: setup.difficulty)
        let boutLength = work + rest
        let massageSeconds = setup.discomfortAreas.isEmpty ? 0 : 60
        let remaining = max(0, setup.durationMinutes * 60 - massageSeconds)
        let slotCount = max(1, Int((Double(remaining) / Double(boutLength)).rounded()))
        let cycle = Pattern.allCases

        var used: Set<String> = []
        var items: [PlanItem] = []

        for slot in 0..<slotCount {
            let start = slot % cycle.count
            var chosen: Exercise?
            for offset in 0..<cycle.count {
                let pattern = cycle[(start + offset) % cycle.count]
                let candidates = library.filter { $0.pattern == pattern && allows($0, setup: setup) }
                if let pick = pick(from: candidates, difficulty: setup.difficulty, used: used) {
                    chosen = pick
                    break
                }
            }
            if chosen == nil {
                let fallback = library.filter { allows($0, setup: setup) }
                chosen = pick(from: fallback, difficulty: setup.difficulty, used: used)
                    ?? library.first { $0.id == "dead-bug" }
            }
            guard let exercise = chosen else { continue }
            used.insert(exercise.id)
            items.append(
                PlanItem(
                    id: "\(slot)-\(exercise.id)",
                    exerciseId: exercise.id,
                    name: exercise.name,
                    pattern: exercise.pattern,
                    workSec: work,
                    restSec: rest,
                    cue: exercise.cue,
                    isSelfMassage: false
                )
            )
        }

        if !setup.discomfortAreas.isEmpty {
            let name = massageName(for: setup.discomfortAreas)
            items.append(
                PlanItem(
                    id: "massage-\(name)",
                    exerciseId: "self-massage",
                    name: name,
                    pattern: .mobility,
                    workSec: 60,
                    restSec: 0,
                    cue: "Slow and easy. Stop if it feels sharp. This is a cooldown, not treatment.",
                    isSelfMassage: true
                )
            )
        }

        let total = items.reduce(0) { $0 + $1.workSec + $1.restSec }
        return WorkoutPlan(
            planId: UUID(),
            createdAt: now,
            setup: setup,
            items: items,
            totalSec: total,
            reason: reason(for: setup)
        )
    }

    static func bout(for difficulty: Int) -> (work: Int, rest: Int) {
        switch difficulty {
        case ...2: (30, 30)
        case 3: (40, 20)
        default: (50, 10)
        }
    }

    static func allows(_ exercise: Exercise, setup: SetupInput) -> Bool {
        if (setup.place == .dorm || setup.place == .hotel) && exercise.isJump {
            return false
        }
        if setup.discomfortAreas.contains(.knees),
           exercise.pattern == .squat || exercise.isLunge || exercise.isJump {
            return false
        }
        let loadFilters: Set<Area> = [.shoulders, .lowerBack, .wrists]
        for area in setup.discomfortAreas.intersection(loadFilters) where exercise.loads.contains(area) {
            return false
        }
        return true
    }

    static func massageName(for areas: Set<Area>) -> String {
        let names = Area.allCases.filter { areas.contains($0) }.map(\.easeName)
        switch names.count {
        case 0: return "Ease"
        case 1: return "\(names[0]) ease"
        default:
            let head = names.dropLast().joined(separator: ", ")
            return "\(head) and \(names.last ?? "") ease"
        }
    }

    static func reason(for setup: SetupInput) -> String {
        var removed: [String] = []
        var because: [String] = []
        if setup.discomfortAreas.contains(.knees) {
            removed.append("no squats, lunges, or jumps")
            because.append("knees were marked")
        }
        if setup.discomfortAreas.contains(.shoulders) {
            removed.append("no moves that load the shoulders")
            because.append("shoulders were marked")
        }
        if setup.discomfortAreas.contains(.lowerBack) {
            removed.append("no moves that load the lower back")
            because.append("the lower back was marked")
        }
        if setup.discomfortAreas.contains(.wrists) {
            removed.append("no moves that load the wrists")
            because.append("wrists were marked")
        }
        if setup.place == .dorm || setup.place == .hotel {
            if !removed.contains("no squats, lunges, or jumps") {
                removed.append("no jumps")
            }
            because.append("the place is a \(setup.place?.label.lowercased() ?? "room")")
        }
        if removed.isEmpty {
            return "A balanced bodyweight session for \(setup.durationMinutes) minutes."
        }
        let lead = removed[0].prefix(1).uppercased() + removed[0].dropFirst()
        let rest = removed.dropFirst()
        let filter = ([String(lead)] + rest).joined(separator: "; ")
        return "\(filter): \(because.joined(separator: " and "))."
    }

    private static func pick(from candidates: [Exercise], difficulty: Int, used: Set<String>) -> Exercise? {
        candidates.min { lhs, rhs in
            let left = (used.contains(lhs.id) ? 1 : 0, abs(lhs.level - difficulty), lhs.id)
            let right = (used.contains(rhs.id) ? 1 : 0, abs(rhs.level - difficulty), rhs.id)
            return left < right
        }
    }

}
