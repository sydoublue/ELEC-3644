import SwiftUI

struct ActiveSessionView: View {
    let plan: WorkoutPlan
    @Binding var path: NavigationPath
    @State private var engine: SessionEngine
    @State private var startedAt = Date.now
    @State private var didFinish = false

    init(plan: WorkoutPlan, path: Binding<NavigationPath>) {
        self.plan = plan
        _path = path
        _engine = State(initialValue: SessionEngine(items: plan.items))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(phaseTitle)
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(EmberColor.accent)
            Text(headline)
                .font(.largeTitle.bold())
                .foregroundStyle(EmberColor.ink)
            Text(clock(engine.remaining))
                .font(.system(size: 76, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(EmberColor.ink)
            Text(cue)
                .font(.title3)
                .foregroundStyle(.secondary)
            if let next = engine.nextItemName, engine.phase == .work {
                Text("Next: \(next)")
                    .font(.headline)
            }
            Spacer()
            controls
            Button("End workout") {
                apply { $0.endEarly() }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(EmberColor.paper)
        .navigationTitle("Active")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            apply { $0.tick() }
        }
    }

    private var headline: String {
        switch engine.phase {
        case .work: engine.currentItem?.name ?? "Workout"
        case .rest: "Rest"
        case .finished: "Done"
        }
    }

    private var phaseTitle: String {
        switch engine.phase {
        case .work: "WORK"
        case .rest: "REST"
        case .finished: "DONE"
        }
    }

    private var cue: String {
        switch engine.phase {
        case .work: engine.currentItem?.cue ?? ""
        case .rest: "Next: \(engine.nextItemName ?? "feedback")"
        case .finished: "Saving this session."
        }
    }

    @ViewBuilder
    private var controls: some View {
        switch engine.phase {
        case .work:
            Button("Skip") {
                apply { $0.skip() }
            }
            .buttonStyle(EmberSecondaryButton())
        case .rest:
            Button("I'm good, skip the break") {
                apply { $0.skipBreak() }
            }
            .buttonStyle(EmberPrimaryButton())
            Button("Need more rest") {
                apply { $0.moreRest() }
            }
            .buttonStyle(EmberSecondaryButton())
            .disabled(engine.extraRestUsed)
        case .finished:
            EmptyView()
        }
    }

    private func apply(_ change: (inout SessionEngine) -> Void) {
        change(&engine)
        guard engine.phase == .finished, !didFinish else { return }
        didFinish = true
        let session = engine.makeSession(plan: plan, startedAt: startedAt, endedAt: .now)
        path.append(Route.feedback(FinishedSession(plan: plan, session: session)))
    }
}
