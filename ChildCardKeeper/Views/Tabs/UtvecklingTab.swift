import SwiftUI

struct UtvecklingTab: View {
    let childId: UUID
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var themeManager: ThemeManager
    
    private var childIndex: Int? { store.binding(for: childId) }
    private var theme: AppTheme { themeManager.current }
    
    var body: some View {
        if let idx = childIndex {
            Form {
                Section {
                    TextField("Vikt, g", text: $store.children[idx].fodelseVikt)
                        .keyboardType(.numberPad)
                    TextField("Längd, cm", text: $store.children[idx].fodelseLangd)
                        .keyboardType(.decimalPad)
                    TextField("Huvudomfång, cm", text: $store.children[idx].fodelseHuvudomfang)
                        .keyboardType(.decimalPad)
                } header: {
                    Label("Födelseuppgifter", systemImage: "heart.fill")
                        .foregroundColor(theme.primary)
                        .font(.headline)
                }
                .listRowBackground(theme.cardBackground)
                
                Section {
                    TextField("Helammats till ålder, mån", text: $store.children[idx].helammadTill)
                    TextField("Delvis amning till ålder, mån", text: $store.children[idx].delvisAmningTill)
                } header: {
                    Label("Bröstmjölk", systemImage: "drop.fill")
                        .foregroundColor(theme.primary)
                        .font(.headline)
                }
                .listRowBackground(theme.cardBackground)
                
                Section {
                    TestRow(label: "Test 1",
                            datum: $store.children[idx].horsel1Datum,
                            ua: $store.children[idx].horsel1Ua,
                            anm: $store.children[idx].horsel1Anm)
                    TestRow(label: "Test 2",
                            datum: $store.children[idx].horsel2Datum,
                            ua: $store.children[idx].horsel2Ua,
                            anm: $store.children[idx].horsel2Anm)
                } header: {
                    Label("Hörselkontroll", systemImage: "ear.fill")
                        .foregroundColor(theme.primary)
                        .font(.headline)
                }
                .listRowBackground(theme.cardBackground)
                
                Section {
                    TestRow(label: "Test 1",
                            datum: $store.children[idx].syn1Datum,
                            ua: $store.children[idx].syn1Ua,
                            anm: $store.children[idx].syn1Anm)
                    TestRow(label: "Test 2",
                            datum: $store.children[idx].syn2Datum,
                            ua: $store.children[idx].syn2Ua,
                            anm: $store.children[idx].syn2Anm)
                } header: {
                    Label("Synkontroll", systemImage: "eye.fill")
                        .foregroundColor(theme.primary)
                        .font(.headline)
                }
                .listRowBackground(theme.cardBackground)
                
                Section {
                    TextField("Fixerar blicken", text: $store.children[idx].fixerarBlicken)
                    TextField("Svarsleende", text: $store.children[idx].svarsleende)
                    TextField("Jollrar nyanserat", text: $store.children[idx].jollrarNyanserat)
                    TextField("Förstår enstaka ord", text: $store.children[idx].forstarEnstakaOrd)
                    TextField("Talar 8-10 ord", text: $store.children[idx].talar8_10Ord)
                    TextField("Berättar begripligt", text: $store.children[idx].berattarBegripligt)
                } header: {
                    Label("Kommunikation", systemImage: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(theme.primary)
                        .font(.headline)
                }
                .listRowBackground(theme.cardBackground)
                
                Section {
                    TextField("Rör armar och ben liksidigt", text: $store.children[idx].rorArmarBenLiksidigt)
                    TextField("Håller upp huvudet i bukläge", text: $store.children[idx].hallerUppHuvudet)
                    TextField("Flyttar föremål mellan händerna", text: $store.children[idx].flyttarForemal)
                    TextField("Reser sig, går utmed möbler", text: $store.children[idx].reserSigGar)
                    TextField("Går säkert utan stöd", text: $store.children[idx].garSakert)
                    TextField("Hoppar på ett ben", text: $store.children[idx].hopparPaEttBen)
                } header: {
                    Label("Motorik", systemImage: "figure.walk")
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

struct TestRow: View {
    let label: String
    @Binding var datum: Date?
    @Binding var ua: Bool
    @Binding var anm: Bool
    
    private var datumBinding: Binding<Date> {
        Binding(
            get: { datum ?? Date() },
            set: { datum = $0 }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundColor(.secondary)
            HStack {
                DatePicker("Datum", selection: datumBinding, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                Toggle("Ua", isOn: $ua)
                    .fixedSize()
                Toggle("Anm", isOn: $anm)
                    .fixedSize()
            }
        }
        .padding(.vertical, 2)
    }
}
