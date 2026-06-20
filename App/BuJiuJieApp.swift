import SwiftUI

@main
@MainActor
struct BuJiuJieApp: App {
    @StateObject private var store = DecisionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
