import SwiftUI

struct TodoListView: View {
    @ObservedObject var store: TodoStore
    @ObservedObject var settings: AppSettingsStore
    @State private var draftTitle = ""
    @State private var showsSettings = false

    var body: some View {
        let accentColor = settings.themeColor.color

        ZStack {
            panelBackground(accentColor: accentColor)

            VStack(spacing: 12) {
                toolbar(accentColor: accentColor)
                entryBar(accentColor: accentColor)

                if showsSettings {
                    settingsInspector(accentColor: accentColor)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                content(accentColor: accentColor)
                footer
            }
            .padding(16)
        }
        .frame(width: 360, height: 420)
        .tint(accentColor)
        .animation(.snappy(duration: 0.18), value: showsSettings)
    }

    private func panelBackground(accentColor: Color) -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(.regularMaterial)

            LinearGradient(
                colors: [
                    accentColor.opacity(0.22),
                    Color(nsColor: .windowBackgroundColor).opacity(0.08),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(accentColor.opacity(0.18))
                .frame(width: 140, height: 140)
                .blur(radius: 42)
                .offset(x: -58, y: -68)
        }
    }

    private func toolbar(accentColor: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.16))
                    .frame(width: 28, height: 28)

                Image(systemName: "checklist")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Todo")
                    .font(.system(size: 15, weight: .semibold))

                Text(summaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(openCountText)
                .font(.caption.weight(.medium))
                .foregroundStyle(accentColor)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(accentColor.opacity(0.12))
                .clipShape(Capsule())

            Button {
                showsSettings.toggle()
            } label: {
                Image(systemName: showsSettings ? "gearshape.fill" : "gearshape")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(showsSettings ? accentColor : .secondary)
            .frame(width: 28, height: 28)
            .background(Color(nsColor: .controlBackgroundColor).opacity(showsSettings ? 0.86 : 0.55))
            .clipShape(Circle())
            .help("Settings")
        }
    }

    private func entryBar(accentColor: Color) -> some View {
        HStack(spacing: 9) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(accentColor)

            TextField("Add a task", text: $draftTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .onSubmit(addTodo)

            Button(action: addTodo) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(canAddTodo ? accentColor : .secondary.opacity(0.5))
            .disabled(!canAddTodo)
            .keyboardShortcut(.return, modifiers: .command)
            .help("Add todo")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.thinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
    }

    private func settingsInspector(accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Appearance", systemImage: "paintpalette")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Reset") {
                    settings.resetAppearance()
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Opacity")
                    Spacer()
                    Text(settings.panelOpacity, format: .number.precision(.fractionLength(2)))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                .font(.caption)

                Slider(
                    value: Binding(
                        get: { settings.panelOpacity },
                        set: { settings.setPanelOpacity($0) }
                    ),
                    in: 0...1,
                    step: 0.05
                )
            }

            HStack(spacing: 9) {
                ForEach(ThemeColor.allCases) { themeColor in
                    ThemeColorButton(
                        themeColor: themeColor,
                        isSelected: settings.themeColor == themeColor,
                        action: { settings.setThemeColor(themeColor) }
                    )
                }
            }
        }
        .padding(12)
        .background(.thinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func content(accentColor: Color) -> some View {
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
                    .padding(.vertical, 3)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyState(accentColor: Color) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.14))
                    .frame(width: 54, height: 54)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 29))
                    .foregroundStyle(accentColor)
            }

            Text("Clear")
                .font(.system(size: 14, weight: .medium))
            Text("No open tasks")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        HStack {
            Text(completedCountText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Clear completed") {
                store.clearCompleted()
            }
            .font(.caption.weight(.medium))
            .buttonStyle(.plain)
            .foregroundStyle(Color.secondary.opacity(completedCount > 0 ? 1.0 : 0.45))
            .disabled(completedCount == 0)
        }
    }

    private var canAddTodo: Bool {
        !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var openCount: Int {
        store.todos.filter { !$0.isCompleted }.count
    }

    private var completedCount: Int {
        store.todos.filter(\.isCompleted).count
    }

    private var summaryText: String {
        if store.todos.isEmpty {
            return "Ready for the next thing"
        }

        return openCount == 1 ? "1 open task" : "\(openCount) open tasks"
    }

    private var openCountText: String {
        "\(openCount) open"
    }

    private var completedCountText: String {
        completedCount == 1 ? "1 completed" : "\(completedCount) completed"
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
                    .frame(width: 22, height: 22)

                if isSelected {
                    Circle()
                        .stroke(Color.white.opacity(0.95), lineWidth: 2)
                        .frame(width: 14, height: 14)
                }
            }
            .padding(4)
            .overlay(
                Circle()
                    .stroke(isSelected ? themeColor.color.opacity(0.9) : Color.white.opacity(0.16), lineWidth: 2)
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
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            Button {
                store.setCompleted(todo.id, isCompleted: !todo.isCompleted)
            } label: {
                ZStack {
                    Circle()
                        .fill(todo.isCompleted ? accentColor : Color.clear)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(todo.isCompleted ? accentColor : Color.secondary.opacity(0.35), lineWidth: 1.5)
                        )

                    if todo.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .help(todo.isCompleted ? "Mark incomplete" : "Mark complete")

            Text(todo.title)
                .font(.system(size: 14))
                .strikethrough(todo.isCompleted)
                .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                .lineLimit(2)

            Spacer(minLength: 8)

            Button(action: { store.delete(todo.id) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary.opacity(isHovering ? 0.8 : 0.0))
            .help("Delete todo")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(todoBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .opacity(todo.isCompleted ? 0.68 : 1.0)
        .onHover { isHovering = $0 }
    }

    private var todoBackground: some ShapeStyle {
        if todo.isCompleted {
            return AnyShapeStyle(Color(nsColor: .controlBackgroundColor).opacity(0.42))
        }

        return AnyShapeStyle(.thinMaterial)
    }
}
