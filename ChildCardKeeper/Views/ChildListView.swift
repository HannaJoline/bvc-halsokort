import SwiftUI

struct ChildListView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.children) { child in
                    NavigationLink(destination: HealthCardView(childId: child.id).environmentObject(store)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(child.displayName)
                                .font(.headline)
                            if !child.personnummer.isEmpty {
                                Text(child.personnummer)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: store.deleteChild)
            }
            .overlay {
                if store.children.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Inga barn")
                            .font(.title2)
                        Text("Tryck + för att lägga till ett barn")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Barnets Hälsokort")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { let _ = store.addChild() }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
