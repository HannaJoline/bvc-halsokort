import SwiftUI

struct VaccinationerTab: View {
    let childId: UUID
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var expandedId: UUID? = nil
    @State private var pendingDeleteId: UUID? = nil
    
    private var childIndex: Int? { store.binding(for: childId) }
    
    var body: some View {
        if let idx = childIndex {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Vaccinationer")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    let vaccinationer = store.children[idx].vaccinationer
                    
                    ForEach(vaccinationer) { vaccination in
                        VaccinationCard(
                            childIdx: idx,
                            vaccinationId: vaccination.id,
                            isExpanded: expandedId == vaccination.id && pendingDeleteId == nil,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    expandedId = expandedId == vaccination.id ? nil : vaccination.id
                                }
                            },
                            onDelete: {
                                expandedId = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    pendingDeleteId = vaccination.id
                                }
                            }
                        )
                        .environmentObject(store)
                    }
                    
                    Button(action: {
                        let newVaccination = Vaccination()
                        store.children[idx].vaccinationer.append(newVaccination)
                        store.save()
                        withAnimation {
                            expandedId = newVaccination.id
                        }
                    }) {
                        Label("Lägg till vaccination", systemImage: "plus.circle.fill")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.current.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.current.cardBackground)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .background(themeManager.current.background)
            .alert("Ta bort vaccination?", isPresented: Binding(
                get: { pendingDeleteId != nil },
                set: { if !$0 { pendingDeleteId = nil } }
            )) {
                Button("Ta bort", role: .destructive) {
                    if let deleteId = pendingDeleteId {
                        expandedId = nil
                        store.children[idx].vaccinationer.removeAll { $0.id == deleteId }
                        store.save()
                        pendingDeleteId = nil
                    }
                }
                Button("Avbryt", role: .cancel) {
                    pendingDeleteId = nil
                }
            }
        }
    }
}

// MARK: - Vaccination Card (self-contained)

struct VaccinationCard: View {
    let childIdx: Int
    let vaccinationId: UUID
    let isExpanded: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var themeManager: ThemeManager
    
    private var vaccinationIndex: Int? {
        store.children[childIdx].vaccinationer.firstIndex(where: { $0.id == vaccinationId })
    }
    
    var body: some View {
        if let vi = vaccinationIndex {
            let vaccination = store.children[childIdx].vaccinationer[vi]
            
            VStack(spacing: 0) {
                Button(action: onTap) {
                    VaccinationCardHeader(vaccination: vaccination, theme: themeManager.current)
                }
                .buttonStyle(.plain)
                
                if isExpanded {
                    Divider().padding(.horizontal)
                    
                    VaccinationEditContent(
                        vaccination: $store.children[childIdx].vaccinationer[vi],
                        theme: themeManager.current,
                        onDelete: onDelete,
                        onChanged: { store.save() }
                    )
                }
            }
            .background(themeManager.current.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            .padding(.horizontal)
        }
    }
}

// MARK: - Compact Card Header

struct VaccinationCardHeader: View {
    let vaccination: Vaccination
    var theme: AppTheme = .standard
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 2) {
                if let datum = vaccination.datum {
                    let components = Calendar.current.dateComponents([.day, .month, .year], from: datum)
                    Text("\(components.day ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(theme.primary)
                    Text(Self.shortMonthYear(from: datum))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Inget datum")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                if !vaccination.vaccinVarunamn.isEmpty {
                    Text(vaccination.vaccinVarunamn)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                let vaccines = vaccination.givenVaccines
                if vaccines.isEmpty {
                    Text("Inga vaccin valda")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Text(vaccines.joined(separator: " · "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                if vaccination.locked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    static func shortMonthYear(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        f.locale = Locale(identifier: "sv_SE")
        return f.string(from: date)
    }
}

// MARK: - Edit Content

struct VaccinationEditContent: View {
    @Binding var vaccination: Vaccination
    var theme: AppTheme = .standard
    var onDelete: () -> Void
    var onChanged: () -> Void
    
    private var datumBinding: Binding<Date> {
        Binding(
            get: { vaccination.datum ?? Date() },
            set: { 
                vaccination.datum = $0
                onChanged()
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: {
                    vaccination.locked.toggle()
                    onChanged()
                }) {
                    Label(
                        vaccination.locked ? "Låst" : "Olåst",
                        systemImage: vaccination.locked ? "lock.fill" : "lock.open"
                    )
                    .font(.subheadline)
                    .foregroundColor(vaccination.locked ? .orange : .green)
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Ta bort", systemImage: "trash")
                        .font(.subheadline)
                }
                .buttonStyle(.borderless)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Datum")
                    .font(.caption)
                    .foregroundColor(.secondary)
                DatePicker("", selection: datumBinding, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .disabled(vaccination.locked)
                
                Text("Titel")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Tillfälle", text: $vaccination.vaccinVarunamn)
                    .textFieldStyle(.roundedBorder)
                    .disabled(vaccination.locked)
                    .onChange(of: vaccination.vaccinVarunamn) { _ in onChanged() }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Standardvaccin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                
                let vaccineToggles: [(String, WritableKeyPath<Vaccination, Bool>)] = [
                    ("Difteri", \.difteri),
                    ("Stelkramp", \.stelkramp),
                    ("Kikhosta", \.kikhosta),
                    ("Polio", \.polio),
                    ("Hemofilus Inf B", \.hemofilusInfB),
                    ("Pneumokocker", \.pneumokocker),
                    ("Mässling", \.massling),
                    ("Röda hund", \.rodaHund),
                    ("Påssjuka", \.passjuka),
                    ("Tuberkulos", \.tuberkulos),
                    ("Hepatit B", \.hepatitB),
                    ("Rotavirus", \.rotavirus),
                ]
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 6) {
                    ForEach(vaccineToggles, id: \.0) { name, keyPath in
                        Toggle(name, isOn: Binding(
                            get: { vaccination[keyPath: keyPath] },
                            set: {
                                vaccination[keyPath: keyPath] = $0
                                onChanged()
                            }
                        ))
                    }
                }
                .font(.caption)
                .disabled(vaccination.locked)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Egna vaccin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                
                ForEach(vaccination.egnaVaccin) { eget in
                    if let ei = vaccination.egnaVaccin.firstIndex(where: { $0.id == eget.id }) {
                        HStack {
                            TextField("Vaccinnamn", text: Binding(
                                get: { vaccination.egnaVaccin[ei].namn },
                                set: {
                                    vaccination.egnaVaccin[ei].namn = $0
                                    onChanged()
                                }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .font(.subheadline)
                            .disabled(vaccination.locked)
                            
                            if !vaccination.locked {
                                Button(action: {
                                    vaccination.egnaVaccin.removeAll { $0.id == eget.id }
                                    onChanged()
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
                
                if !vaccination.locked {
                    Button(action: {
                        vaccination.egnaVaccin.append(EgetVaccin())
                        onChanged()
                    }) {
                        Label("Lägg till eget vaccin", systemImage: "plus.circle")
                            .font(.caption)
                            .foregroundColor(theme.primary)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .padding()
        .opacity(vaccination.locked ? 0.7 : 1.0)
    }
}
