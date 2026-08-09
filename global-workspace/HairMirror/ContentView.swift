import SwiftUI

/// 主框架：三大页面 —— 测脸型 / 发型库 / 我的
struct ContentView: View {
    var body: some View {
        TabView {
            AnalyzeView()
                .tabItem {
                    Label("测脸型", systemImage: "camera.viewfinder")
                }

            HairLibraryView()
                .tabItem {
                    Label("发型库", systemImage: "scissors")
                }

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
