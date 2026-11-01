import Foundation

enum SessionPhase: String, Codable, Hashable {
    case work, rest, finished
}

struct SessionEngine {
    var items: [PlanItem]
    var index: Int
    var phase: SessionPhase
    var remaining: Int
    var extraRestUsed: Bool
    var records: [SessionItemRecord]
    var status: SessionStatus

    init(items: [PlanItem]) {
        self.items = items
        index = 0
        records = items.enumerated().map { offset, item in
            SessionItemRecord(
                index: offset,
                exerciseId: item.exerciseId,
                name: item.name,
                result: .skipped,
                elapsedSec: 0,
                restAction: .none
            )
        }
        if items.isEmpty {
            phase = .finished
            remaining = 0
            extraRestUsed = false
            status = .stopped
        } else {
            phase = .work
            remaining = items[0].workSec
            extraRestUsed = false
            status = .completed
        }
    }

    var currentItem: PlanItem? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }

    var nextItemName: String? {
        let next = index + 1
        guard items.indices.contains(next) else { return nil }
        return items[next].name
    }

    mutating func tick() {
        guard phase != .finished else { return }
        if remaining > 0 {
            remaining -= 1
        }
        if remaining == 0 {
            completePhase()
        }
    }

    mutating func skip() {
        guard phase == .work, items.indices.contains(index) else { return }
        records[index].result = .skipped
        records[index].elapsedSec = max(0, items[index].workSec - remaining)
        advance()
    }

    mutating func skipBreak() {
        guard phase == .rest, items.indices.contains(index) else { return }
        if records[index].restAction == .none {
            records[index].restAction = .skippedBreak
        }
        advance()
    }

    mutating func moreRest() {
        guard phase == .rest, !extraRestUsed else { return }
        extraRestUsed = true
        remaining += 15
        if items.indices.contains(index) {
            records[index].restAction = .extraRest
        }
    }

    mutating func endEarly() {
        guard phase != .finished else { return }
        if items.indices.contains(index), phase == .work {
            records[index].result = .skipped
            records[index].elapsedSec = max(0, items[index].workSec - remaining)
        }
        if index + 1 < records.count {
            for cursor in (index + 1)..<records.count {
                records[cursor].result = .skipped
                records[cursor].elapsedSec = 0
            }
        }
        phase = .finished
        status = .stopped
        remaining = 0
    }

    func makeSession(plan: WorkoutPlan, startedAt: Date, endedAt: Date = .now) -> WorkoutSession {
        WorkoutSession(
            sessionId: UUID(),
            planId: plan.planId,
            startedAt: startedAt,
            endedAt: endedAt,
            status: status,
            items: records
        )
    }

    private mutating func completePhase() {
        guard items.indices.contains(index) else {
            phase = .finished
            status = .completed
            return
        }
        switch phase {
        case .work:
            records[index].result = .completed
            records[index].elapsedSec = items[index].workSec
            if items[index].restSec > 0 {
                phase = .rest
                remaining = items[index].restSec
                extraRestUsed = false
            } else {
                advance()
            }
        case .rest:
            advance()
        case .finished:
            break
        }
    }

    private mutating func advance() {
        let next = index + 1
        guard items.indices.contains(next) else {
            phase = .finished
            status = .completed
            remaining = 0
            return
        }
        index = next
        phase = .work
        remaining = items[next].workSec
        extraRestUsed = false
    }
}
