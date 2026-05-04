import SwiftUI

enum AppTab: Hashable {
    case closet, generate, scan, profile
}

struct RootView: View {
    @State private var selection: AppTab = .closet

    var body: some View {
        TabView(selection: $selection) {
            ClosetView()
                .tag(AppTab.closet)
                .tabItem {
                    Label("Closet", systemImage: "tshirt")
                }

            OutfitGeneratorView()
                .tag(AppTab.generate)
                .tabItem {
                    Label("Generate", systemImage: "sparkles")
                }

            ScanReviewView()
                .tag(AppTab.scan)
                .tabItem {
                    Label("Scan", systemImage: "camera")
                }

            ProfileView()
                .tag(AppTab.profile)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .tint(AppColor.primary)
    }
}

#Preview {
    RootView()
        .environmentObject(ClosetRepository())
}
