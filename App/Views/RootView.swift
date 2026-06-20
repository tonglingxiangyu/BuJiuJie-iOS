import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("做决定", systemImage: "wand.and.stars")
                }

            HistoryView()
                .tabItem {
                    Label("记录", systemImage: "clock.arrow.circlepath")
                }
        }
        .tint(AppPalette.primary)
    }
}

