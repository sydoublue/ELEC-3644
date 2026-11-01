import SwiftUI

@main
struct EmberApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .tint(EmberColor.accent)
        }
    }
}
