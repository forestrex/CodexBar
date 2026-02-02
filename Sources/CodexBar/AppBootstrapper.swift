import AppKit
import CodexBarCore
import Foundation

@MainActor
struct AppBootstrapper {
    static func makeEnvironment()
        -> (settings: SettingsStore, store: UsageStore, selection: PreferencesSelection, account: AccountInfo)
    {
        let env = ProcessInfo.processInfo.environment
        let storedLevel = CodexBarLog.parseLevel(UserDefaults.standard.string(forKey: "debugLogLevel")) ?? .verbose
        let level = CodexBarLog.parseLevel(env["CODEXBAR_LOG_LEVEL"]) ?? storedLevel
        CodexBarLog.bootstrapIfNeeded(.init(
            destination: .oslog(subsystem: "com.steipete.codexbar"),
            level: level,
            json: false))

        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        let gitCommit = Bundle.main.object(forInfoDictionaryKey: "CodexGitCommit") as? String ?? "unknown"
        let buildTimestamp = Bundle.main.object(forInfoDictionaryKey: "CodexBuildTimestamp") as? String ?? "unknown"
        CodexBarLog.logger(LogCategories.app).info(
            "CodexBar starting",
            metadata: [
                "version": version,
                "build": build,
                "git": gitCommit,
                "built": buildTimestamp,
            ])

        KeychainAccessGate.isDisabled = UserDefaults.standard.bool(forKey: "debugDisableKeychainAccess")
        KeychainPromptCoordinator.install()

        let preferencesSelection = PreferencesSelection()
        let settings = SettingsStore()
        let fetcher = UsageFetcher()
        let browserDetection = BrowserDetection(cacheTTL: BrowserDetection.defaultCacheTTL)
        let account = fetcher.loadAccountInfo()
        let store = UsageStore(fetcher: fetcher, browserDetection: browserDetection, settings: settings)
        CodexBarLog.setLogLevel(settings.debugLogLevel)

        return (settings: settings, store: store, selection: preferencesSelection, account: account)
    }
}
