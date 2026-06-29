import Foundation
@testable import MacOSTodoListCore
import XCTest

@MainActor
final class AppSettingsStoreTests: XCTestCase {
    func testPanelOpacityIsPersistedAndReloaded() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = AppSettingsStore(fileURL: fileURL)
        store.setPanelOpacity(0.35)

        let reloadedStore = AppSettingsStore(fileURL: fileURL)
        XCTAssertEqual(reloadedStore.panelOpacity, 0.35, accuracy: 0.001)
    }

    func testThemeColorIsPersistedAndReloaded() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = AppSettingsStore(fileURL: fileURL)
        store.setThemeColor(.green)

        let reloadedStore = AppSettingsStore(fileURL: fileURL)
        XCTAssertEqual(reloadedStore.themeColor, .green)
    }

    func testOlderSettingsFilesUseDefaultThemeColor() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        try #"{"panelOpacity":0.45}"#.data(using: .utf8)?.write(to: fileURL, options: [.atomic])

        let store = AppSettingsStore(fileURL: fileURL)
        XCTAssertEqual(store.panelOpacity, 0.45, accuracy: 0.001)
        XCTAssertEqual(store.themeColor, .blue)
    }

    func testPanelOpacityIsClampedToSupportedRange() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = AppSettingsStore(fileURL: fileURL)

        store.setPanelOpacity(-1.0)
        XCTAssertEqual(store.panelOpacity, 0.0, accuracy: 0.001)

        store.setPanelOpacity(2.0)
        XCTAssertEqual(store.panelOpacity, 1.0, accuracy: 0.001)
    }

    func testResetAppearanceRestoresDefaults() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = AppSettingsStore(fileURL: fileURL)
        store.setPanelOpacity(0.2)
        store.setThemeColor(.purple)

        store.resetAppearance()

        XCTAssertEqual(store.panelOpacity, AppSettings.defaultValue.panelOpacity, accuracy: 0.001)
        XCTAssertEqual(store.themeColor, AppSettings.defaultValue.themeColor)
    }

    private func temporaryFileURL() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("MacOSTodoListSettingsTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL.appendingPathComponent("settings.json")
    }
}
