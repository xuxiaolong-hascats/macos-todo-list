import AppKit
import Combine
import SwiftUI

@MainActor
final class TodoPanelController {
    private let panel: NSPanel
    private let rootView: TodoListView
    private var settingsCancellable: AnyCancellable?

    init(store: TodoStore, settings: AppSettingsStore) {
        self.rootView = TodoListView(store: store, settings: settings)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 420),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.title = "Todo List"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.contentView = NSHostingView(rootView: rootView)
        panel.alphaValue = settings.panelOpacity
        panel.center()

        self.panel = panel
        self.settingsCancellable = settings.$panelOpacity
            .sink { [weak panel] opacity in
                panel?.alphaValue = opacity
            }
    }

    func showPanel() {
        panel.orderFrontRegardless()
    }

    func hidePanel() {
        panel.orderOut(nil)
    }

    func togglePanel() {
        panel.isVisible ? hidePanel() : showPanel()
    }

    func showPanelAndFocusEntry() {
        showPanel()
        NSApplication.shared.activate()
    }
}
