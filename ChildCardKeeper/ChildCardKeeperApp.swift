import SwiftUI

@main
struct ChildCardKeeperApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ChildListView()
                .environmentObject(store)
                .environmentObject(themeManager)
        }
    }
}
