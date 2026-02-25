import SwiftUI

struct VaccinationerTab: View {
    let childId: UUID
    @EnvironmentObject var store: DataStore
    @State private var expandedId: UUID? = nil
    
    private var childIndex: Int? { store.binding(for: childId) }
    
    private func vaccinationIndex(for id: UUID, in idx: Int) -> Int? {
        store.children[idx].vaccinationer.firstIndex(where: { $0.id == id })
    }
    
    var body: some View {
        if let idx = childIndex {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Vaccinationer")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(store.children[idx].vaccinationer) { vaccination in
                        let isExpanded = expandedId == vaccination.id
                        
                        VStack(spacing: 0) {
                            // Compact card header
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    expandedId = isExpanded ? nil : vaccination.id
                                }
                            }) {
                                VaccinationCardHeader(vaccination: vaccination)
                            }
                            .buttonStyle(.plain)
                            
                            // Expandable edit section
                            if isExpanded, let vi = vaccinationIndex(for: vaccination.id, in: idx) {
                                Divider()
                                    .padding(.horizontal)
                                VaccinationEditView(
                                    vaccination: $store.children[idx].vaccinationer[vi],
                                    onDelete: {
                                        expandedId = nil
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            if let removeIdx = store.children[idx].vaccinationer.firstIndex(where: { $0.id == vaccination.id }) {
                                                store.children[idx].vaccinationer.remove(at: removeIdx)
                                                store.save()
                                            }
                                        }
                                    },
                                    onSave: { store.save() }
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                        .padding(.horizontal)
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
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Compact Card Header

struct VaccinationCardHeader: View {
    let vaccination: Vaccination
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        f.locale = Locale(identifier: "sv_SE")
        return f
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Date badge
            VStack(spacing: 2) {
                if let datum = vaccination.datum {
                    let components = Calendar.current.dateComponents([.day, .month, .year], from: datum)
                    Text("\(components.day ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(dateFormatter.shortMonthYear(from: datum))
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
            
            // Vaccine list
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
            
            // Lock indicator & chevron
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
}

// MARK: - Edit View (expanded)

struct VaccinationEditView: View {
    @Binding var vaccination: Vaccination
    var onDelete: () -> Void
    var onSave: () -> Void = {}
    
    private var datumBinding: Binding<Date> {
        Binding(
            get: { vaccination.datum ?? Date() },
            set: { vaccination.datum = $0 }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Lock toggle
            HStack {
                Button(action: { vaccination.locked.toggle() }) {
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
            
            // Date & vaccine name
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
            }
            
            // Standard vaccines
            VStack(alignment: .leading, spacing: 4) {
                Text("Standardvaccin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 6) {
                    Toggle("Difteri", isOn: $vaccination.difteri)
                    Toggle("Stelkramp", isOn: $vaccination.stelkramp)
                    Toggle("Kikhosta", isOn: $vaccination.kikhosta)
                    Toggle("Polio", isOn: $vaccination.polio)
                    Toggle("Hemofilus Inf B", isOn: $vaccination.hemofilusInfB)
                    Toggle("Pneumokocker", isOn: $vaccination.pneumokocker)
                    Toggle("Mässling", isOn: $vaccination.massling)
                    Toggle("Röda hund", isOn: $vaccination.rodaHund)
                    Toggle("Påssjuka", isOn: $vaccination.passjuka)
                    Toggle("Tuberkulos", isOn: $vaccination.tuberkulos)
                    Toggle("Hepatit B", isOn: $vaccination.hepatitB)
                    Toggle("Rotavirus", isOn: $vaccination.rotavirus)
                }
                .font(.caption)
                .disabled(vaccination.locked)
            }
            
            // Custom vaccines
            VStack(alignment: .leading, spacing: 4) {
                Text("Egna vaccin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                
                ForEach(vaccination.egnaVaccin) { eget in
                    if let ei = vaccination.egnaVaccin.firstIndex(where: { $0.id == eget.id }) {
                        HStack {
                            TextField("Vaccinnamn", text: $vaccination.egnaVaccin[ei].namn)
                                .textFieldStyle(.roundedBorder)
                                .font(.subheadline)
                                .disabled(vaccination.locked)
                            
                            if !vaccination.locked {
                                Button(action: {
                                    vaccination.egnaVaccin.removeAll { $0.id == eget.id }
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
                    }) {
                        Label("Lägg till eget vaccin", systemImage: "plus.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .padding()
        .opacity(vaccination.locked ? 0.7 : 1.0)
        .onChange(of: vaccination) { _ in onSave() }
    }
}

// MARK: - Helper

extension DateFormatter {
    func shortMonthYear(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        f.locale = Locale(identifier: "sv_SE")
        return f.string(from: date)
    }
}
