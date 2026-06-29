import SwiftUI

struct TodoListView: View {
    @ObservedObject var store: TodoStore
    @ObservedObject var settings: AppSettingsStore
    @State private var draftTitle = ""
    @State private var showsSettings = false

    var body: some View {
        let accentColor = settings.themeColor.color

        VStack(alignment: .leading, spacing: 14) {
            header(accentColor: accentColor)
            entryRow(accentColor: accentColor)
            if showsSettings {
                settingsSection(accentColor: accentColor)
            }
            Divider()
            todoList(accentColor: accentColor)
        }
        .padding(18)
        .frame(width: 360, height: 420)
        .background(.regularMaterial)
        .tint(accentColor)
    }

    private func header(accentColor: Color) -> some View {
        HStack {
            Circle()
                .fill(accentColor)
                .frame(width: 10, height: 10)
                .shadow(color: accentColor.opacity(0.35), radius: 4, y: 1)

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

    private func entryRow(accentColor: Color) -> some View {
        HStack(spacing: 8) {
            TextField("New todo", text: $draftTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit(addTodo)

            Button(action: addTodo) {
                Image(systemName: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .tint(accentColor)
            .keyboardShortcut(.return, modifiers: .command)
            .help("Add todo")
        }
    }

    private func todoList(accentColor: Color) -> some View {
        Group {
            if store.todos.isEmpty {
                emptyState(accentColor: accentColor)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.todos) { todo in
                            TodoRow(
                                todo: todo,
                                store: store,
                                accentColor: accentColor
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func settingsSection(accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
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
                .tint(accentColor)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Theme color")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(ThemeColor.allCases) { themeColor in
                        ThemeColorButton(
                            themeColor: themeColor,
                            isSelected: settings.themeColor == themeColor,
                            action: { settings.setThemeColor(themeColor) }
                        )
                    }
                }
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func emptyState(accentColor: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 28))
                .foregroundStyle(accentColor)
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

private struct ThemeColorButton: View {
    let themeColor: ThemeColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(themeColor.color)
                    .frame(width: 20, height: 20)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(3)
            .overlay(
                Circle()
                    .stroke(isSelected ? themeColor.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .help(themeColor.displayName)
    }
}

private struct TodoRow: View {
    let todo: TodoItem
    @ObservedObject var store: TodoStore
    let accentColor: Color

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
            .tint(accentColor)

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
