import Foundation

class DataStore: ObservableObject {
    @Published var children: [Child] = []
    
    private static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("children.json")
    }
    
    init() {
        load()
    }
    
    func load() {
        guard let data = try? Data(contentsOf: Self.fileURL),
              let decoded = try? JSONDecoder().decode([Child].self, from: data) else { return }
        children = decoded
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(children) else { return }
        try? data.write(to: Self.fileURL, options: .atomic)
    }
    
    func addChild() -> Child {
        var child = Child()
        children.append(child)
        save()
        return child
    }
    
    func deleteChild(at offsets: IndexSet) {
        children.remove(atOffsets: offsets)
        save()
    }
    
    func update(_ child: Child) {
        if let idx = children.firstIndex(where: { $0.id == child.id }) {
            children[idx] = child
            save()
        }
    }
    
    func binding(for childId: UUID) -> Int? {
        children.firstIndex(where: { $0.id == childId })
    }
}
