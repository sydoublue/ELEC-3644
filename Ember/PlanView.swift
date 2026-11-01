import SwiftUI

struct PlanView: View {
    let plan: WorkoutPlan
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(headline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(plan.reason)
                    .font(.body)
                    .foregroundStyle(EmberColor.ink)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))

                ForEach(Array(plan.items.enumerated()), id: \.element.id) { offset, item in
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(offset + 1)")
                            .font(.headline)
                            .foregroundStyle(EmberColor.accent)
                            .frame(width: 24, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.headline)
                            Text(timing(item))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                }

                Button("Start workout") {
                    path.append(Route.active(plan))
                }
                .buttonStyle(EmberPrimaryButton())
            }
            .padding(24)
        }
        .background(EmberColor.paper)
        .navigationTitle("Plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headline: String {
        var parts = ["\(plan.setup.durationMinutes) min", plan.setup.feeling.label]
        if let place = plan.setup.place {
            parts.append(place.label.lowercased())
        }
        return parts.joined(separator: " · ")
    }

    private func timing(_ item: PlanItem) -> String {
        if item.isSelfMassage {
            return "\(item.workSec)s · cooldown"
        }
        return "\(item.workSec)s work · \(item.restSec)s rest"
    }
}
