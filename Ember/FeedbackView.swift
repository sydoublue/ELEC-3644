import SwiftUI

struct FeedbackView: View {
    @Environment(AppStore.self) private var store
    let finished: FinishedSession
    @Binding var path: NavigationPath
    @State private var perceived: Perceived?
    @State private var areas: Set<Area> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("How was that?")
                    .font(.title.bold())
                    .foregroundStyle(EmberColor.ink)
                ForEach(Perceived.allCases) { option in
                    Button {
                        perceived = option
                    } label: {
                        HStack {
                            Text(option.label)
                            Spacer()
                            if perceived == option {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(perceived == option ? EmberColor.accent : .white, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(perceived == option ? .white : EmberColor.ink)
                    }
                    .buttonStyle(.plain)
                }
                Text("Any area uncomfortable?")
                    .font(.headline)
                    .padding(.top, 8)
                ForEach(Area.allCases) { area in
                    Toggle(area.label, isOn: Binding(
                        get: { areas.contains(area) },
                        set: { isOn in
                            if isOn { areas.insert(area) } else { areas.remove(area) }
                        }
                    ))
                }
                Button("Done") {
                    guard let perceived else { return }
                    store.saveFinished(
                        plan: finished.plan,
                        session: finished.session,
                        perceived: perceived,
                        areas: areas
                    )
                    path = NavigationPath()
                }
                .buttonStyle(EmberPrimaryButton(enabled: perceived != nil))
                .disabled(perceived == nil)
            }
            .padding(24)
        }
        .background(EmberColor.paper)
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
