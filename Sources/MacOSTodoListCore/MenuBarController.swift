import AppKit

@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem
    private let showPanel: () -> Void
    private let hidePanel: () -> Void
    private let togglePanel: () -> Void
    private let addTodo: () -> Void
    private let resetAppearance: () -> Void

    init(
        showPanel: @escaping () -> Void,
        hidePanel: @escaping () -> Void,
        togglePanel: @escaping () -> Void,
        addTodo: @escaping () -> Void,
        resetAppearance: @escaping () -> Void
    ) {
        self.showPanel = showPanel
        self.hidePanel = hidePanel
        self.togglePanel = togglePanel
        self.addTodo = addTodo
        self.resetAppearance = resetAppearance
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        configureStatusItem()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "Todo List")
            button.action = #selector(togglePanelAction)
            button.target = self
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Todo Panel", action: #selector(showPanelAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Hide Todo Panel", action: #selector(hidePanelAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Add Todo", action: #selector(addTodoAction), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "Reset Appearance", action: #selector(resetAppearanceAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitAction), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem.menu = menu
    }

    @objc private func showPanelAction() {
        showPanel()
    }

    @objc private func hidePanelAction() {
        hidePanel()
    }

    @objc private func togglePanelAction() {
        togglePanel()
    }

    @objc private func addTodoAction() {
        addTodo()
    }

    @objc private func resetAppearanceAction() {
        resetAppearance()
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
}
