import Foundation
import Observation

@Observable
final class AppStore {
    private(set) var snapshot: StoreSnapshot
    private let fileURL: URL

    init(directory: URL? = nil) {
        let folder = directory ?? FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Ember", isDirectory: true)
        fileURL = folder.appendingPathComponent("store.json")
        snapshot = Self.load(from: fileURL) ?? .empty
    }

    var activitiesNewestFirst: [Activity] {
        snapshot.activities.sorted { $0.occurredAt > $1.occurredAt }
    }

    var statusLine: String {
        guard let latest = snapshot.feedback.max(by: { $0.createdAt < $1.createdAt }) else {
            return "No session yet"
        }
        let areas = Area.allCases.filter { latest.areas.contains($0) }.map(\.label)
        if areas.isEmpty {
            return "Last time: \(latest.perceived.label.lowercased())"
        }
        return "Last time: \(latest.perceived.label.lowercased()) · \(areas.joined(separator: ", ").lowercased())"
    }

    func prefilledSetup() -> SetupInput {
        let areas = snapshot.feedback.max(by: { $0.createdAt < $1.createdAt })?.areas ?? []
        return SetupInput(
            difficulty: snapshot.lastDifficulty,
            durationMinutes: snapshot.lastDuration,
            place: nil,
            discomfortAreas: areas
        )
    }

    func rememberSetup(_ setup: SetupInput) {
        snapshot.lastDifficulty = setup.difficulty
        snapshot.lastDuration = setup.durationMinutes
        persist()
    }

    func saveFinished(plan: WorkoutPlan, session: WorkoutSession, perceived: Perceived, areas: Set<Area>) {
        if !snapshot.plans.contains(where: { $0.planId == plan.planId }) {
            snapshot.plans.append(plan)
        }
        snapshot.sessions.append(session)
        let feedback = Feedback(
            id: UUID(),
            sessionId: session.sessionId,
            perceived: perceived,
            areas: areas,
            createdAt: session.endedAt
        )
        snapshot.feedback.append(feedback)
        switch perceived {
        case .tooHard: snapshot.lastDifficulty = max(1, plan.setup.difficulty - 1)
        case .tooEasy: snapshot.lastDifficulty = min(5, plan.setup.difficulty + 1)
        case .aboutRight: snapshot.lastDifficulty = plan.setup.difficulty
        }
        snapshot.lastDuration = plan.setup.durationMinutes
        let minutes = max(1, Int((Double(plan.totalSec) / 60).rounded()))
        snapshot.activities.append(
            Activity(
                activityId: UUID(),
                occurredAt: session.endedAt,
                origin: .inApp,
                title: "Daily Pick",
                durationMin: minutes,
                kind: "workout",
                sessionId: session.sessionId
            )
        )
        persist()
    }

    func addExternal(title: String, minutes: Int, kind: String, at date: Date = .now) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        snapshot.activities.append(
            Activity(
                activityId: UUID(),
                occurredAt: date,
                origin: .external,
                title: trimmed.isEmpty ? "Activity" : trimmed,
                durationMin: max(1, minutes),
                kind: kind.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "sport" : kind,
                sessionId: nil
            )
        )
        persist()
    }

    func detail(for activity: Activity) -> String {
        if activity.origin == .external {
            return "Outside · \(activity.kind)"
        }
        guard let session = snapshot.sessions.first(where: { $0.sessionId == activity.sessionId }),
              let plan = snapshot.plans.first(where: { $0.planId == session.planId }) else {
            return "In app"
        }
        let place = plan.setup.place?.label.lowercased() ?? "any place"
        let feel = snapshot.feedback.first { $0.sessionId == session.sessionId }?.perceived.label.lowercased()
        return [ "In app", place, feel ].compactMap { $0 }.joined(separator: " · ")
    }

    func reset() {
        snapshot = .empty
        persist()
    }

    private func persist() {
        let folder = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private static func load(from url: URL) -> StoreSnapshot? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(StoreSnapshot.self, from: data)
    }
}
