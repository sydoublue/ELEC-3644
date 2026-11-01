import SwiftUI

struct LogView: View {
    @Environment(AppStore.self) private var store
    @State private var showingAdd = false

    var body: some View {
        Group {
            if store.activitiesNewestFirst.isEmpty {
                ContentUnavailableView("No activities yet", systemImage: "list.bullet", description: Text("A finished Daily Pick, or something you did outside the app, shows up here."))
            } else {
                List(store.activitiesNewestFirst) { activity in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(activity.title) · \(activity.durationMin) min")
                            .font(.headline)
                        Text(store.detail(for: activity))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(EmberColor.paper)
        .navigationTitle("Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add activity") { showingAdd = true }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddActivitySheet()
        }
    }
}

private struct AddActivitySheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var minutes = 40
    @State private var kind = "sport"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Basketball", text: $title)
                Stepper("\(minutes) min", value: $minutes, in: 1...300)
                TextField("Kind", text: $kind)
            }
            .navigationTitle("Add activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addExternal(title: title, minutes: minutes, kind: kind)
                        dismiss()
                    }
                }
            }
        }
    }
}
