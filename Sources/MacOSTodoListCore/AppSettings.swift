import Foundation

struct AppSettings: Codable, Equatable {
    var panelOpacity: Double

    static let defaultValue = AppSettings(panelOpacity: 1.0)
}
