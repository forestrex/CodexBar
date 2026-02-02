import AppKit
import SwiftUI

@MainActor
final class PreferencesWindowController: NSWindowController {
    private let selection: PreferencesSelection

    init(settings: SettingsStore, store: UsageStore, updater: UpdaterProviding, selection: PreferencesSelection) {
        self.selection = selection
        let rootView = PreferencesView(
            settings: settings,
            store: store,
            updater: updater,
            selection: selection)
        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Preferences"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(
            width: PreferencesTab.general.preferredWidth,
            height: PreferencesTab.general.preferredHeight))
        window.center()
        window.isReleasedWhenClosed = false
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(tab: PreferencesTab) {
        self.selection.tab = tab
        guard let window = self.window else { return }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
