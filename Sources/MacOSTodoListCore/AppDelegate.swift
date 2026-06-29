import AppKit

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = TodoStore()
    private let settings = AppSettingsStore()
    private var panelController: TodoPanelController?
    private var menuBarController: MenuBarController?

    public override init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        let panelController = TodoPanelController(store: store, settings: settings)
        let menuBarController = MenuBarController(
            showPanel: { panelController.showPanel() },
            hidePanel: { panelController.hidePanel() },
            togglePanel: { panelController.togglePanel() },
            addTodo: { panelController.showPanelAndFocusEntry() },
            resetOpacity: {
                self.settings.setPanelOpacity(1.0)
                panelController.showPanel()
            }
        )

        self.panelController = panelController
        self.menuBarController = menuBarController
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
