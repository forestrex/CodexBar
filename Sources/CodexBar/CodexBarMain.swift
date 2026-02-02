import AppKit

@main
struct CodexBarMain {
    static func main() {
        if #available(macOS 11.0, *) {
            CodexBarApp.main()
        } else {
            LegacyCodexBarApp.main()
        }
    }
}

private enum LegacyCodexBarApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        let environment = MainActor.assumeIsolated { AppBootstrapper.makeEnvironment() }
        delegate.configure(
            store: environment.store,
            settings: environment.settings,
            account: environment.account,
            selection: environment.selection)
        app.run()
    }
}
