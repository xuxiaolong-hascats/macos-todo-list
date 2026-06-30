import Foundation
@testable import MacOSTodoListCore
import XCTest

@MainActor
final class TodoStoreTests: XCTestCase {
    func testAddCompleteDeleteAndReload() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = TodoStore(fileURL: fileURL)
        store.add(title: "  Ship the first version  ")

        XCTAssertEqual(store.todos.count, 1)
        XCTAssertEqual(store.todos[0].title, "Ship the first version")
        XCTAssertFalse(store.todos[0].isCompleted)

        let id = try XCTUnwrap(store.todos.first?.id)
        store.setCompleted(id, isCompleted: true)

        let reloadedStore = TodoStore(fileURL: fileURL)
        XCTAssertEqual(reloadedStore.todos.count, 1)
        XCTAssertEqual(reloadedStore.todos[0].title, "Ship the first version")
        XCTAssertTrue(reloadedStore.todos[0].isCompleted)

        reloadedStore.delete(id)
        XCTAssertTrue(reloadedStore.todos.isEmpty)

        let emptyReloadedStore = TodoStore(fileURL: fileURL)
        XCTAssertTrue(emptyReloadedStore.todos.isEmpty)
    }

    func testBlankTitlesAreIgnored() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = TodoStore(fileURL: fileURL)
        store.add(title: "   ")

        XCTAssertTrue(store.todos.isEmpty)
    }

    func testUpdateTitleTrimsAndPersists() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = TodoStore(fileURL: fileURL)
        store.add(title: "Original")

        let id = try XCTUnwrap(store.todos.first?.id)
        store.updateTitle(id, title: "  Updated title  ")

        XCTAssertEqual(store.todos.first?.title, "Updated title")

        let reloadedStore = TodoStore(fileURL: fileURL)
        XCTAssertEqual(reloadedStore.todos.first?.title, "Updated title")
    }

    func testUpdateTitleIgnoresBlankTitles() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = TodoStore(fileURL: fileURL)
        store.add(title: "Keep me")

        let id = try XCTUnwrap(store.todos.first?.id)
        store.updateTitle(id, title: "   ")

        XCTAssertEqual(store.todos.first?.title, "Keep me")
    }

    func testClearCompletedRemovesOnlyCompletedTodos() throws {
        let fileURL = try temporaryFileURL()
        defer {
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let store = TodoStore(fileURL: fileURL)
        store.add(title: "Open")
        store.add(title: "Done")

        let completedID = try XCTUnwrap(store.todos.first { $0.title == "Done" }?.id)
        store.setCompleted(completedID, isCompleted: true)
        store.clearCompleted()

        XCTAssertEqual(store.todos.map(\.title), ["Open"])

        let reloadedStore = TodoStore(fileURL: fileURL)
        XCTAssertEqual(reloadedStore.todos.map(\.title), ["Open"])
    }

    private func temporaryFileURL() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("MacOSTodoListTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL.appendingPathComponent("todos.json")
    }
}
