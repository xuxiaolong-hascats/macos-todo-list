import SwiftUI

struct TodoListView: View {
    @ObservedObject var store: TodoStore
    @State private var draftTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            entryRow
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
