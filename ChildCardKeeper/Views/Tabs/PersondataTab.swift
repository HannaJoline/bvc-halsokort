import SwiftUI

struct PersondataTab: View {
    let childId: UUID
    @EnvironmentObject var store: DataStore
    
    private var childIndex: Int? { store.binding(for: childId) }
    
    var body: some View {
        if let idx = childIndex {
            Form {
                Section("Persondata") {
                    TextField("Personnummer", text: $store.children[idx].personnummer)
                    TextField("Namn", text: $store.children[idx].namn)
                    Picker("Kön", selection: $store.children[idx].kon) {
                        Text("Ej angivet").tag("")
                        Text("Pojke").tag("Pojke")
                        Text("Flicka").tag("Flicka")
                    }
                    TextField("Adress", text: $store.children[idx].adress)
                    TextField("Telefonnummer", text: $store.children[idx].telefonnummer)
                }
                
                Section("Barnavårdscentral") {
                    TextField("Adress", text: $store.children[idx].bvcAdress)
                    TextField("Telefon", text: $store.children[idx].bvcTelefon)
                    TextField("Sjuksköterska", text: $store.children[idx].sjukskoterska)
                    TextField("Läkare", text: $store.children[idx].lakare)
                }
                
                Section("Viktiga sjukdomar, allergier, viktig medicinering") {
                    ForEach(store.children[idx].sjukdomar.indices, id: \.self) { i in
                        HStack {
                            TextField("Sjukdom/allergi/medicin", text: $store.children[idx].sjukdomar[i].sjukdom)
                            TextField("År", text: $store.children[idx].sjukdomar[i].ar)
                                .frame(width: 70)
                                .keyboardType(.numberPad)
                        }
                    }
                    .onDelete { offsets in
                        store.children[idx].sjukdomar.remove(atOffsets: offsets)
                        store.save()
                    }
                    
                    Button(action: {
                        store.children[idx].sjukdomar.append(Sjukdom())
                        store.save()
                    }) {
                        Label("Lägg till rad", systemImage: "plus.circle")
                    }
                }
            }
            .onChange(of: store.children[idx]) { _ in store.save() }
        }
    }
}
