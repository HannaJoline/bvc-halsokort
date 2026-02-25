import SwiftUI

struct UtvecklingTab: View {
    let childId: UUID
    @EnvironmentObject var store: DataStore
    
    private var childIndex: Int? { store.binding(for: childId) }
    
    var body: some View {
        if let idx = childIndex {
            Form {
                Section("Födelseuppgifter") {
                    TextField("Vikt, g", text: $store.children[idx].fodelseVikt)
                        .keyboardType(.numberPad)
                    TextField("Längd, cm", text: $store.children[idx].fodelseLangd)
                        .keyboardType(.decimalPad)
                    TextField("Huvudomfång, cm", text: $store.children[idx].fodelseHuvudomfang)
                        .keyboardType(.decimalPad)
                }
                
                Section("Bröstmjölk") {
                    TextField("Helammats till ålder, mån", text: $store.children[idx].helammadTill)
                    TextField("Delvis amning till ålder, mån", text: $store.children[idx].delvisAmningTill)
                }
                
                Section("Hörselkontroll (OAE/BOEL etc.)") {
                    TestRow(label: "Test 1",
                            datum: $store.children[idx].horsel1Datum,
                            ua: $store.children[idx].horsel1Ua,
                            anm: $store.children[idx].horsel1Anm)
                    TestRow(label: "Test 2",
                            datum: $store.children[idx].horsel2Datum,
                            ua: $store.children[idx].horsel2Ua,
                            anm: $store.children[idx].horsel2Anm)
                }
                
                Section("Synkontroll") {
                    TestRow(label: "Test 1",
                            datum: $store.children[idx].syn1Datum,
                            ua: $store.children[idx].syn1Ua,
                            anm: $store.children[idx].syn1Anm)
                    TestRow(label: "Test 2",
                            datum: $store.children[idx].syn2Datum,
                            ua: $store.children[idx].syn2Ua,
                            anm: $store.children[idx].syn2Anm)
                }
                
                Section("Utveckling – Kommunikation (Ålder, mån/år)") {
                    TextField("Fixerar blicken", text: $store.children[idx].fixerarBlicken)
                    TextField("Svarsleende", text: $store.children[idx].svarsleende)
                    TextField("Jollrar nyanserat", text: $store.children[idx].jollrarNyanserat)
                    TextField("Förstår enstaka ord", text: $store.children[idx].forstarEnstakaOrd)
                    TextField("Talar 8-10 ord", text: $store.children[idx].talar8_10Ord)
                    TextField("Berättar begripligt", text: $store.children[idx].berattarBegripligt)
                }
                
                Section("Utveckling – Motorik (Ålder, mån/år)") {
                    TextField("Rör armar och ben liksidigt", text: $store.children[idx].rorArmarBenLiksidigt)
                    TextField("Håller upp huvudet i bukläge", text: $store.children[idx].hallerUppHuvudet)
                    TextField("Flyttar föremål mellan händerna", text: $store.children[idx].flyttarForemal)
                    TextField("Reser sig, går utmed möbler", text: $store.children[idx].reserSigGar)
                    TextField("Går säkert utan stöd", text: $store.children[idx].garSakert)
                    TextField("Hoppar på ett ben", text: $store.children[idx].hopparPaEttBen)
                }
            }
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
