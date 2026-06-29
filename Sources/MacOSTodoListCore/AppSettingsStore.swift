import Combine
import Foundation

@MainActor
final class AppSettingsStore: ObservableObject {
    @Published private(set) var panelOpacity: Double

    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let settings = Self.loadSettings(from: self.fileURL, decoder: decoder)
        self.panelOpacity = Self.clampedOpacity(settings.panelOpacity)
    }

    func setPanelOpacity(_ opacity: Double) {
        panelOpacity = Self.clampedOpacity(opacity)
        save()
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let settings = AppSettings(panelOpacity: panelOpacity)
            let data = try encoder.encode(settings)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            fputs("Failed to save settings: \(error)\n", stderr)
        }
    }

    private static func loadSettings(from fileURL: URL, decoder: JSONDecoder) -> AppSettings {
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(AppSettings.self, from: data)
        } catch CocoaError.fileReadNoSuchFile {
            return .defaultValue
        } catch {
            fputs("Failed to load settings: \(error)\n", stderr)
            return .defaultValue
        }
    }

    private static func clampedOpacity(_ opacity: Double) -> Double {
        min(max(opacity, 0.0), 1.0)
    }

    private static func defaultFileURL() -> URL {
        let supportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        return supportURL
            .appendingPathComponent("MacOSTodoList", isDirectory: true)
            .appendingPathComponent("settings.json")
    }
}
