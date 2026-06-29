import SwiftUI

struct TodoListView: View {
    @ObservedObject var store: TodoStore
    @ObservedObject var settings: AppSettingsStore
    @State private var draftTitle = ""
    @State private var showsSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            entryRow
            if showsSettings {
                settingsSection
            }
            Divider()
            todoList
        }
        .padding(18)
        .frame(width: 360, height: 420)
        .background(.regularMaterial)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Todo List")
                    .font(.headline)
                Text(summaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showsSettings.toggle()
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help("Settings")
        }
    }

    private var entryRow: some View {
        HStack(spacing: 8) {
            TextField("New todo", text: $draftTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit(addTodo)

            Button(action: addTodo) {
                Image(systemName: "plus")
            }
            .keyboardShortcut(.return, modifiers: .command)
            .help("Add todo")
        }
    }

    private var todoList: some View {
        Group {
            if store.todos.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.todos) { todo in
                            TodoRow(
                                todo: todo,
                                store: store
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Panel opacity")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(settings.panelOpacity, format: .number.precision(.fractionLength(2)))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { settings.panelOpacity },
                    set: { settings.setPanelOpacity($0) }
                ),
                in: 0...1,
                step: 0.05
            )
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text("No todos")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var summaryText: String {
        let openCount = store.todos.filter { !$0.isCompleted }.count
        return openCount == 1 ? "1 open task" : "\(openCount) open tasks"
    }

    private func addTodo() {
        store.add(title: draftTitle)
        draftTitle = ""
    }
}

private struct TodoRow: View {
    let todo: TodoItem
    @ObservedObject var store: TodoStore

    var body: some View {
        HStack(spacing: 8) {
            Toggle(
                isOn: Binding(
                    get: { todo.isCompleted },
                    set: { store.setCompleted(todo.id, isCompleted: $0) }
                )
            ) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                    .lineLimit(2)
            }
            .toggleStyle(.checkbox)

            Spacer(minLength: 8)

            Button(action: { store.delete(todo.id) }) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .help("Delete todo")
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
