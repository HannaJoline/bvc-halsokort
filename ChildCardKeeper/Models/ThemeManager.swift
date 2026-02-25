import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
    case standard = "Standard"
    case rosdroppe = "Rosdroppe"
    case solsken = "Solsken"
    case himmel = "Himmel"
    case angsgrон = "Ängsgrönt"
    
    var displayName: String { rawValue }
    
    var primary: Color {
        switch self {
        case .standard: return .blue
        case .rosdroppe: return Color(red: 0.85, green: 0.45, blue: 0.55)
        case .solsken: return Color(red: 0.85, green: 0.70, blue: 0.35)
        case .himmel: return Color(red: 0.45, green: 0.60, blue: 0.85)
        case .angsgrон: return Color(red: 0.45, green: 0.75, blue: 0.55)
        }
    }
    
    var secondary: Color {
        switch self {
        case .standard: return Color(red: 0.55, green: 0.65, blue: 0.85)
        case .rosdroppe: return Color(red: 0.95, green: 0.75, blue: 0.80)
        case .solsken: return Color(red: 0.95, green: 0.88, blue: 0.65)
        case .himmel: return Color(red: 0.75, green: 0.85, blue: 0.95)
        case .angsgrон: return Color(red: 0.75, green: 0.90, blue: 0.78)
        }
    }
    
    var background: Color {
        switch self {
        case .standard: return Color(.systemGroupedBackground)
        case .rosdroppe: return Color(red: 0.99, green: 0.94, blue: 0.95)
        case .solsken: return Color(red: 0.99, green: 0.97, blue: 0.91)
        case .himmel: return Color(red: 0.93, green: 0.96, blue: 0.99)
        case .angsgrон: return Color(red: 0.93, green: 0.98, blue: 0.94)
        }
    }
    
    var cardBackground: Color {
        switch self {
        case .standard: return Color(.systemBackground)
        case .rosdroppe: return Color(red: 1.0, green: 0.97, blue: 0.98)
        case .solsken: return Color(red: 1.0, green: 0.99, blue: 0.95)
        case .himmel: return Color(red: 0.96, green: 0.98, blue: 1.0)
        case .angsgrон: return Color(red: 0.96, green: 0.99, blue: 0.96)
        }
    }
    
    var emoji: String {
        switch self {
        case .standard: return "💙"
        case .rosdroppe: return "🌸"
        case .solsken: return "🌻"
        case .himmel: return "☁️"
        case .angsgrон: return "🌿"
        }
    }
    
    var previewColors: [Color] {
        [primary, secondary, background]
    }
}

class ThemeManager: ObservableObject {
    @Published var current: AppTheme {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "appTheme")
        }
    }
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "appTheme") ?? "Standard"
        self.current = AppTheme(rawValue: saved) ?? .standard
    }
}
