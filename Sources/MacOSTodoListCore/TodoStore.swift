import Combine
import Foundation

@MainActor
final class TodoStore: ObservableObject {
    @Published private(set) var todos: [TodoItem] = []

    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        load()
    }

    func add(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return
        }

        todos.insert(TodoItem(title: trimmedTitle), at: 0)
        save()
    }

    func setCompleted(_ id: TodoItem.ID, isCompleted: Bool) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else {
            return
        }

        todos[index].isCompleted = isCompleted
        save()
    }

    func delete(_ id: TodoItem.ID) {
        todos.removeAll { $0.id == id }
        save()
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            todos = try decoder.decode([TodoItem].self, from: data)
        } catch CocoaError.fileReadNoSuchFile {
            todos = []
        } catch {
            fputs("Failed to load todos: \(error)\n", stderr)
            todos = []
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try encoder.encode(todos)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            fputs("Failed to save todos: \(error)\n", stderr)
        }
    }

    private static func defaultFileURL() -> URL {
        let supportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        return supportURL
            .appendingPathComponent("MacOSTodoList", isDirectory: true)
            .appendingPathComponent("todos.json")
    }
}
