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

    private func temporaryFileURL() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("MacOSTodoListSettingsTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL.appendingPathComponent("settings.json")
    }
}
