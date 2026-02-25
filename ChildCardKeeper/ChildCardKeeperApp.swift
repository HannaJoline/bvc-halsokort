import SwiftUI

@main
struct ChildCardKeeperApp: App {
    @StateObject private var store = DataStore()
    
    var body: some Scene {
        WindowGroup {
            ChildListView()
                .environmentObject(store)
        }
    }
}
