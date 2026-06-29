import Foundation

struct AppSettings: Codable, Equatable {
    var panelOpacity: Double
    var themeColor: ThemeColor

    static let defaultValue = AppSettings(panelOpacity: 1.0, themeColor: .blue)

    init(panelOpacity: Double, themeColor: ThemeColor) {
        self.panelOpacity = panelOpacity
        self.themeColor = themeColor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.panelOpacity = try container.decodeIfPresent(Double.self, forKey: .panelOpacity)
            ?? Self.defaultValue.panelOpacity
        self.themeColor = try container.decodeIfPresent(ThemeColor.self, forKey: .themeColor)
            ?? Self.defaultValue.themeColor
    }
}

enum ThemeColor: String, CaseIterable, Codable, Equatable, Identifiable {
    case blue
    case graphite
    case green
    case orange
    case pink
    case purple

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .blue:
            "Blue"
        case .graphite:
            "Graphite"
        case .green:
            "Green"
        case .orange:
            "Orange"
        case .pink:
            "Pink"
        case .purple:
            "Purple"
        }
    }
}
