import SwiftUI

struct ChildListView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingThemePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.current.background.ignoresSafeArea()
                
                List {
                    ForEach(store.children) { child in
                        NavigationLink(destination: HealthCardView(childId: child.id).environmentObject(store).environmentObject(themeManager)) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(themeManager.current.primary.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Text(child.displayName.prefix(1).uppercased())
                                            .font(.headline)
                                            .foregroundColor(themeManager.current.primary)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(child.displayName)
                                        .font(.headline)
                                    if !child.personnummer.isEmpty {
                                        Text(child.personnummer)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(themeManager.current.cardBackground)
                    }
                    .onDelete(perform: store.deleteChild)
                }
                .scrollContentBackground(.hidden)
                .overlay {
                    if store.children.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.current.primary.opacity(0.6))
                            Text("Inga barn")
                                .font(.title2)
                            Text("Tryck + för att lägga till ett barn")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("BVC Hälsokort")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingThemePicker = true }) {
                        Image(systemName: "paintpalette.fill")
                            .foregroundColor(themeManager.current.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { let _ = store.addChild() }) {
                        Image(systemName: "plus")
                            .foregroundColor(themeManager.current.primary)
                    }
                }
            }
            .sheet(isPresented: $showingThemePicker) {
                ThemePickerView()
                    .environmentObject(themeManager)
            }
        }
        .tint(themeManager.current.primary)
    }
}

// MARK: - Theme Picker

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Välj färgtema")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: themeManager.current == theme,
                            onSelect: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    themeManager.current = theme
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            .background(themeManager.current.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Klar") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.current.primary)
                }
            }
        }
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Color preview circles
                HStack(spacing: -8) {
                    Circle()
                        .fill(theme.primary)
                        .frame(width: 36, height: 36)
                    Circle()
                        .fill(theme.secondary)
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    Circle()
                        .fill(theme.background)
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(theme.emoji)
                        Text(theme.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(theme.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.cardBackground)
                    .shadow(color: isSelected ? theme.primary.opacity(0.3) : .black.opacity(0.06), radius: isSelected ? 6 : 3, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? theme.primary : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
