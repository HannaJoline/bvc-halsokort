import SwiftUI

struct PersondataTab: View {
    let childId: UUID
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var themeManager: ThemeManager
    
    private var childIndex: Int? { store.binding(for: childId) }
    private var theme: AppTheme { themeManager.current }
    
    var body: some View {
        if let idx = childIndex {
            Form {
                Section {
                    TextField("Personnummer", text: $store.children[idx].personnummer)
                    TextField("Namn", text: $store.children[idx].namn)
                    Picker("Kön", selection: $store.children[idx].kon) {
                        Text("Ej angivet").tag("")
                        Text("Pojke").tag("Pojke")
                        Text("Flicka").tag("Flicka")
                    }
                    TextField("Adress", text: $store.children[idx].adress)
                    TextField("Telefonnummer", text: $store.children[idx].telefonnummer)
                } header: {
                    Label("Persondata", systemImage: "person.fill")
                        .foregroundColor(theme.primary)
                        .font(.headline)
                }
                .listRowBackground(theme.cardBackground)
                
                Section {
                    TextField("Adress", text: $store.children[idx].bvcAdress)
                    TextField("Telefon", text: $store.children[idx].bvcTelefon)
                    TextField("Sjuksköterska", text: $store.children[idx].sjukskoterska)
                    TextField("Läkare", text: $store.children[idx].lakare)
                } header: {
                    Label("Barnavårdscentral", systemImage: "cross.case.fill")
                        .foregroundColor(theme.primary)
                        .font(.headline)
                }
                .listRowBackground(theme.cardBackground)
                
                Section {
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
                            .foregroundColor(theme.primary)
                    }
                } header: {
                    Label("Sjukdomar, allergier, medicinering", systemImage: "heart.text.clipboard")
                        .foregroundColor(theme.primary)
                        .font(.headline)
                }
                .listRowBackground(theme.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .background(theme.background.ignoresSafeArea())
            .tint(theme.primary)
            .onChange(of: store.children[idx]) { _ in store.save() }
        }
    }
}
