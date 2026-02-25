import SwiftUI

struct HealthCardView: View {
    let childId: UUID
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var themeManager: ThemeManager
    
    private var child: Child {
        store.children.first(where: { $0.id == childId }) ?? Child()
    }
    
    var body: some View {
        TabView {
            PersondataTab(childId: childId)
                .environmentObject(store)
                .tabItem {
                    Label("Persondata", systemImage: "person.fill")
                }
            
            TillvaxtTab(childId: childId)
                .environmentObject(store)
                .tabItem {
                    Label("Tillväxt", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            UtvecklingTab(childId: childId)
                .environmentObject(store)
                .tabItem {
                    Label("Utveckling", systemImage: "figure.walk")
                }
            
            VaccinationerTab(childId: childId)
                .environmentObject(store)
                .tabItem {
                    Label("Vacciner", systemImage: "syringe.fill")
                }
        }
        .navigationTitle(child.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .tint(themeManager.current.primary)
    }
}
