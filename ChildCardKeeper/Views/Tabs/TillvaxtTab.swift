import SwiftUI
import Charts

struct TillvaxtTab: View {
    let childId: UUID
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showChart = false
    @State private var selectedMetric: GrowthMetric = .weight
    @State private var showRefInfo = false
    
    private var childIndex: Int? { store.binding(for: childId) }
    private var theme: AppTheme { themeManager.current }
    
    var body: some View {
        if let idx = childIndex {
            let child = store.children[idx]
            Form {
                Section {
                    Toggle("Visa tillväxtkurva", isOn: $showChart)
                        .tint(theme.primary)
                    if showChart {
                        Picker("Mätvärde", selection: $selectedMetric) {
                            ForEach(GrowthMetric.allCases) { m in
                                Text(m.rawValue).tag(m)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .listRowBackground(theme.cardBackground)
                
                if showChart {
                    Section {
                        HStack {
                            Text("Tillväxtkurva – \(selectedMetric.rawValue)")
                                .font(.headline)
                                .foregroundColor(theme.primary)
                            Spacer()
                            Button(action: { showRefInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(theme.primary)
                            }
                            .alert("Referenskurvor", isPresented: $showRefInfo) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text("Referenskurvorna baseras på WHO Child Growth Standards (0–24 månader).\n\n🟠 Orange linje = 50:e percentilen (medianvärde)\n🔴 Röda streckade linjer = ±2 standardavvikelser (SD)\n\n⚠️ Kön måste anges under Persondata för att referenskurvorna ska visas.\n\nKälla: World Health Organization, 2006\nwho.int/tools/child-growth-standards")
                            }
                        }
                        GrowthChartView(
                            child: child,
                            metric: selectedMetric,
                            themeColor: theme.primary
                        )
                        .frame(height: 300)
                    }
                    .listRowBackground(theme.cardBackground)
                }
                
                Section {
                    ForEach(store.children[idx].matningar.indices, id: \.self) { i in
                        MatningRow(matning: $store.children[idx].matningar[i])
                    }
                    .onDelete { offsets in
                        store.children[idx].matningar.remove(atOffsets: offsets)
                        store.save()
                    }
                    
                    Button(action: {
                        store.children[idx].matningar.append(Matning())
                        store.save()
                    }) {
                        Label("Lägg till mätning", systemImage: "plus.circle")
                            .foregroundColor(theme.primary)
                    }
                } header: {
                    Label("Mätningar", systemImage: "ruler.fill")
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

struct MatningRow: View {
    @Binding var matning: Matning
    
    private var datumBinding: Binding<Date> {
        Binding(
            get: { matning.datum ?? Date() },
            set: { matning.datum = $0 }
        )
    }
    
    private var alderArBinding: Binding<String> {
        Binding(
            get: { matning.alderAr.map { String($0) } ?? "" },
            set: { matning.alderAr = Int($0) }
        )
    }
    
    private var alderManBinding: Binding<String> {
        Binding(
            get: { matning.alderMan.map { String($0) } ?? "" },
            set: { matning.alderMan = Int($0) }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Datum").font(.caption).foregroundColor(.secondary)
                    DatePicker("", selection: datumBinding, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
                VStack(alignment: .leading) {
                    Text("Ålder").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        TextField("0", text: alderArBinding)
                            .keyboardType(.numberPad)
                            .frame(width: 35)
                        Text("år").font(.caption).foregroundColor(.secondary)
                        TextField("0", text: alderManBinding)
                            .keyboardType(.numberPad)
                            .frame(width: 35)
                        Text("mån").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("Vikt, g").font(.caption).foregroundColor(.secondary)
                    TextField("g", text: $matning.vikt)
                        .keyboardType(.numberPad)
                }
                VStack(alignment: .leading) {
                    Text("Längd, cm").font(.caption).foregroundColor(.secondary)
                    TextField("cm", text: $matning.langd)
                        .keyboardType(.decimalPad)
                }
                VStack(alignment: .leading) {
                    Text("Huvud, cm").font(.caption).foregroundColor(.secondary)
                    TextField("cm", text: $matning.huvudomfang)
                        .keyboardType(.decimalPad)
                }
            }
            VStack(alignment: .leading) {
                Text("Anteckning").font(.caption).foregroundColor(.secondary)
                TextField("Anteckning", text: $matning.anteckning)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Growth Chart

struct GrowthChartView: View {
    let child: Child
    let metric: GrowthMetric
    var themeColor: Color = .blue
    
    private struct ChartPoint: Identifiable {
        let id = UUID()
        let ageMonths: Double
        let value: Double
        let series: String
    }
    
    private func parseDouble(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ",", with: "."))
    }
    
    private func ageInMonths(_ m: Matning) -> Double {
        let years = Double(m.alderAr ?? 0)
        let months = Double(m.alderMan ?? 0)
        return years * 12 + months
    }
    
    private func valueFor(_ m: Matning) -> Double? {
        switch metric {
        case .weight: return parseDouble(m.vikt)
        case .length: return parseDouble(m.langd)
        case .head:   return parseDouble(m.huvudomfang)
        }
    }
    
    private func birthValue() -> Double? {
        switch metric {
        case .weight: return parseDouble(child.fodelseVikt)
        case .length: return parseDouble(child.fodelseLangd)
        case .head:   return parseDouble(child.fodelseHuvudomfang)
        }
    }
    
    private var childPoints: [ChartPoint] {
        var points: [ChartPoint] = []
        
        let hasManualZero = child.matningar.contains { m in
            ageInMonths(m) == 0 && valueFor(m) != nil
        }
        if !hasManualZero, let bv = birthValue() {
            points.append(ChartPoint(ageMonths: 0, value: bv, series: "Barn"))
        }
        
        for m in child.matningar {
            if let v = valueFor(m) {
                points.append(ChartPoint(ageMonths: ageInMonths(m), value: v, series: "Barn"))
            }
        }
        return points.sorted { $0.ageMonths < $1.ageMonths }
    }
    
    private var whoRefPoints: [(series: String, points: [ChartPoint])] {
        guard !child.kon.isEmpty else { return [] }
        let ref = WHOGrowthData.data(for: child.kon, metric: metric)
        let median = ref.map { ChartPoint(ageMonths: $0.ageMonths, value: $0.median, series: "50:e percentilen") }
        let minus2 = ref.map { ChartPoint(ageMonths: $0.ageMonths, value: $0.minus2SD, series: "-2 SD") }
        let plus2  = ref.map { ChartPoint(ageMonths: $0.ageMonths, value: $0.plus2SD, series: "+2 SD") }
        return [
            ("-2 SD", minus2),
            ("50:e percentilen", median),
            ("+2 SD", plus2)
        ]
    }
    
    var body: some View {
        let cp = childPoints
        let who = whoRefPoints
        
        if cp.isEmpty && who.isEmpty {
            VStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("Lägg till mätningar för att se kurvan")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart {
                ForEach(who, id: \.series) { ref in
                    ForEach(ref.points) { p in
                        LineMark(
                            x: .value("Ålder (mån)", p.ageMonths),
                            y: .value(metric.rawValue, p.value),
                            series: .value("Ref", p.series)
                        )
                        .foregroundStyle(ref.series == "50:e percentilen" ? Color.orange.opacity(0.8) : Color.red.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: ref.series == "50:e percentilen" ? 2 : 1.5, dash: ref.series == "50:e percentilen" ? [] : [6, 4]))
                    }
                }
                
                ForEach(cp) { p in
                    LineMark(
                        x: .value("Ålder (mån)", p.ageMonths),
                        y: .value(metric.rawValue, p.value),
                        series: .value("Ref", "Barn")
                    )
                    .foregroundStyle(themeColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Ålder (mån)", p.ageMonths),
                        y: .value(metric.rawValue, p.value)
                    )
                    .foregroundStyle(themeColor)
                    .symbolSize(30)
                }
            }
            .chartXAxisLabel("Ålder (månader)")
            .chartForegroundStyleScale([
                "Barn": themeColor,
                "50:e percentilen": Color.orange.opacity(0.8),
                "-2 SD": Color.red.opacity(0.5),
                "+2 SD": Color.red.opacity(0.5)
            ])
        }
    }
}
