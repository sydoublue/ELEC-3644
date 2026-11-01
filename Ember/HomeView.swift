import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 16) {
                Text("EMBER")
                    .font(.caption.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(EmberColor.accent)
                Text("Daily Pick")
                    .font(.largeTitle.bold())
                    .foregroundStyle(EmberColor.ink)
                Text(store.statusLine)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Start") {
                    path.append(Route.setup)
                }
                .buttonStyle(EmberPrimaryButton())
                Button("Log") {
                    path.append(Route.log)
                }
                .buttonStyle(EmberSecondaryButton())
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(EmberColor.paper)
            .navigationTitle("Ember")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape") {
                        path.append(Route.settings)
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .setup:
                    SetupView(path: $path)
                case .plan(let plan):
                    PlanView(plan: plan, path: $path)
                case .active(let plan):
                    ActiveSessionView(plan: plan, path: $path)
                case .feedback(let finished):
                    FeedbackView(finished: finished, path: $path)
                case .log:
                    LogView()
                case .settings:
                    SettingsView()
                }
            }
        }
    }
}

enum Route: Hashable {
    case setup
    case plan(WorkoutPlan)
    case active(WorkoutPlan)
    case feedback(FinishedSession)
    case log
    case settings
}

struct FinishedSession: Hashable {
    var plan: WorkoutPlan
    var session: WorkoutSession
}
