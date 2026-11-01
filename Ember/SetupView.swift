import SwiftUI

struct SetupView: View {
    @Environment(AppStore.self) private var store
    @Binding var path: NavigationPath
    @State private var difficulty = 3
    @State private var duration = 10
    @State private var place: Place?
    @State private var areas: Set<Area> = []
    @State private var showMore = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("How are you feeling today?")
                    .font(.title2.bold())
                    .foregroundStyle(EmberColor.ink)
                VStack(spacing: 8) {
                    ForEach(Feeling.allCases) { feeling in
                        Button {
                            difficulty = feeling.rawValue
                        } label: {
                            HStack {
                                Text(feeling.label)
                                Spacer()
                                if difficulty == feeling.rawValue {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                difficulty == feeling.rawValue ? EmberColor.accent : .white,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .foregroundStyle(difficulty == feeling.rawValue ? .white : EmberColor.ink)
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration")
                        .font(.headline)
                    Text("\(duration) min")
                        .font(.title.bold())
                        .foregroundStyle(EmberColor.accent)
                    Slider(
                        value: Binding(
                            get: { Double(duration) },
                            set: { duration = Int($0.rounded()) }
                        ),
                        in: 5...30,
                        step: 1
                    )
                    .tint(EmberColor.accent)
                }

                DisclosureGroup("More", isExpanded: $showMore) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Place", selection: $place) {
                            Text("Not set").tag(Optional<Place>.none)
                            ForEach(Place.allCases) { item in
                                Text(item.label).tag(Optional(item))
                            }
                        }
                        .pickerStyle(.menu)
                        Text("Discomfort")
                            .font(.subheadline.weight(.semibold))
                        ForEach(Area.allCases) { area in
                            Toggle(area.label, isOn: Binding(
                                get: { areas.contains(area) },
                                set: { isOn in
                                    if isOn { areas.insert(area) } else { areas.remove(area) }
                                }
                            ))
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))

                Button("See workout") {
                    let setup = SetupInput(
                        difficulty: difficulty,
                        durationMinutes: duration,
                        place: place,
                        discomfortAreas: areas
                    )
                    store.rememberSetup(setup)
                    path.append(Route.plan(WorkoutGenerator.makePlan(from: setup)))
                }
                .buttonStyle(EmberPrimaryButton())
            }
            .padding(24)
        }
        .background(EmberColor.paper)
        .navigationTitle("Setup")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let prefill = store.prefilledSetup()
            difficulty = prefill.difficulty
            duration = prefill.durationMinutes
            areas = prefill.discomfortAreas
            showMore = !prefill.discomfortAreas.isEmpty
        }
    }
}
