import CodexBarCore
import Foundation
import ServiceManagement

extension SettingsStore {
    var refreshFrequency: RefreshFrequency {
        get { self.defaultsState.refreshFrequency }
        set {
            self.updateDefaultsState { $0.refreshFrequency = newValue }
            self.userDefaults.set(newValue.rawValue, forKey: "refreshFrequency")
        }
    }

    var launchAtLogin: Bool {
        get { self.defaultsState.launchAtLogin }
        set {
            self.updateDefaultsState { $0.launchAtLogin = newValue }
            self.userDefaults.set(newValue, forKey: "launchAtLogin")
            LaunchAtLoginManager.setEnabled(newValue)
        }
    }

    var debugMenuEnabled: Bool {
        get { self.defaultsState.debugMenuEnabled }
        set {
            self.updateDefaultsState { $0.debugMenuEnabled = newValue }
            self.userDefaults.set(newValue, forKey: "debugMenuEnabled")
        }
    }

    var debugDisableKeychainAccess: Bool {
        get { self.defaultsState.debugDisableKeychainAccess }
        set {
            self.updateDefaultsState { $0.debugDisableKeychainAccess = newValue }
            self.userDefaults.set(newValue, forKey: "debugDisableKeychainAccess")
            Self.sharedDefaults?.set(newValue, forKey: "debugDisableKeychainAccess")
            KeychainAccessGate.isDisabled = newValue
        }
    }

    var debugFileLoggingEnabled: Bool {
        get { self.defaultsState.debugFileLoggingEnabled }
        set {
            self.updateDefaultsState { $0.debugFileLoggingEnabled = newValue }
            self.userDefaults.set(newValue, forKey: "debugFileLoggingEnabled")
            CodexBarLog.setFileLoggingEnabled(newValue)
        }
    }

    var debugLogLevel: CodexBarLog.Level {
        get {
            let raw = self.defaultsState.debugLogLevelRaw
            return CodexBarLog.parseLevel(raw) ?? .verbose
        }
        set {
            self.updateDefaultsState { $0.debugLogLevelRaw = newValue.rawValue }
            self.userDefaults.set(newValue.rawValue, forKey: "debugLogLevel")
            CodexBarLog.setLogLevel(newValue)
        }
    }

    var debugKeepCLISessionsAlive: Bool {
        get { self.defaultsState.debugKeepCLISessionsAlive }
        set {
            self.updateDefaultsState { $0.debugKeepCLISessionsAlive = newValue }
            self.userDefaults.set(newValue, forKey: "debugKeepCLISessionsAlive")
        }
    }

    var isVerboseLoggingEnabled: Bool {
        self.debugLogLevel.rank <= CodexBarLog.Level.verbose.rank
    }

    private var debugLoadingPatternRaw: String? {
        get { self.defaultsState.debugLoadingPatternRaw }
        set {
            self.updateDefaultsState { $0.debugLoadingPatternRaw = newValue }
            if let raw = newValue {
                self.userDefaults.set(raw, forKey: "debugLoadingPattern")
            } else {
                self.userDefaults.removeObject(forKey: "debugLoadingPattern")
            }
        }
    }

    var statusChecksEnabled: Bool {
        get { self.defaultsState.statusChecksEnabled }
        set {
            self.updateDefaultsState { $0.statusChecksEnabled = newValue }
            self.userDefaults.set(newValue, forKey: "statusChecksEnabled")
        }
    }

    var sessionQuotaNotificationsEnabled: Bool {
        get { self.defaultsState.sessionQuotaNotificationsEnabled }
        set {
            self.updateDefaultsState { $0.sessionQuotaNotificationsEnabled = newValue }
            self.userDefaults.set(newValue, forKey: "sessionQuotaNotificationsEnabled")
        }
    }

    var usageBarsShowUsed: Bool {
        get { self.defaultsState.usageBarsShowUsed }
        set {
            self.updateDefaultsState { $0.usageBarsShowUsed = newValue }
            self.userDefaults.set(newValue, forKey: "usageBarsShowUsed")
        }
    }

    var resetTimesShowAbsolute: Bool {
        get { self.defaultsState.resetTimesShowAbsolute }
        set {
            self.updateDefaultsState { $0.resetTimesShowAbsolute = newValue }
            self.userDefaults.set(newValue, forKey: "resetTimesShowAbsolute")
        }
    }

    var menuBarShowsBrandIconWithPercent: Bool {
        get { self.defaultsState.menuBarShowsBrandIconWithPercent }
        set {
            self.updateDefaultsState { $0.menuBarShowsBrandIconWithPercent = newValue }
            self.userDefaults.set(newValue, forKey: "menuBarShowsBrandIconWithPercent")
        }
    }

    private var menuBarDisplayModeRaw: String? {
        get { self.defaultsState.menuBarDisplayModeRaw }
        set {
            self.updateDefaultsState { $0.menuBarDisplayModeRaw = newValue }
            if let raw = newValue {
                self.userDefaults.set(raw, forKey: "menuBarDisplayMode")
            } else {
                self.userDefaults.removeObject(forKey: "menuBarDisplayMode")
            }
        }
    }

    var menuBarDisplayMode: MenuBarDisplayMode {
        get { MenuBarDisplayMode(rawValue: self.menuBarDisplayModeRaw ?? "") ?? .percent }
        set { self.menuBarDisplayModeRaw = newValue.rawValue }
    }

    var showAllTokenAccountsInMenu: Bool {
        get { self.defaultsState.showAllTokenAccountsInMenu }
        set {
            self.updateDefaultsState { $0.showAllTokenAccountsInMenu = newValue }
            self.userDefaults.set(newValue, forKey: "showAllTokenAccountsInMenu")
        }
    }

    var menuBarMetricPreferencesRaw: [String: String] {
        get { self.defaultsState.menuBarMetricPreferencesRaw }
        set {
            self.updateDefaultsState { $0.menuBarMetricPreferencesRaw = newValue }
            self.userDefaults.set(newValue, forKey: "menuBarMetricPreferences")
        }
    }

    var costUsageEnabled: Bool {
        get { self.defaultsState.costUsageEnabled }
        set {
            self.updateDefaultsState { $0.costUsageEnabled = newValue }
            self.userDefaults.set(newValue, forKey: "tokenCostUsageEnabled")
        }
    }

    var hidePersonalInfo: Bool {
        get { self.defaultsState.hidePersonalInfo }
        set {
            self.updateDefaultsState { $0.hidePersonalInfo = newValue }
            self.userDefaults.set(newValue, forKey: "hidePersonalInfo")
        }
    }

    var randomBlinkEnabled: Bool {
        get { self.defaultsState.randomBlinkEnabled }
        set {
            self.updateDefaultsState { $0.randomBlinkEnabled = newValue }
            self.userDefaults.set(newValue, forKey: "randomBlinkEnabled")
        }
    }

    var menuBarShowsHighestUsage: Bool {
        get { self.defaultsState.menuBarShowsHighestUsage }
        set {
            self.updateDefaultsState { $0.menuBarShowsHighestUsage = newValue }
            self.userDefaults.set(newValue, forKey: "menuBarShowsHighestUsage")
        }
    }

    var claudeWebExtrasEnabled: Bool {
        get { self.claudeWebExtrasEnabledRaw }
        set { self.claudeWebExtrasEnabledRaw = newValue }
    }

    private var claudeWebExtrasEnabledRaw: Bool {
        get { self.defaultsState.claudeWebExtrasEnabledRaw }
        set {
            self.updateDefaultsState { $0.claudeWebExtrasEnabledRaw = newValue }
            self.userDefaults.set(newValue, forKey: "claudeWebExtrasEnabled")
            CodexBarLog.logger(LogCategories.settings).info(
                "Claude web extras updated",
                metadata: ["enabled": newValue ? "1" : "0"])
        }
    }

    var showOptionalCreditsAndExtraUsage: Bool {
        get { self.defaultsState.showOptionalCreditsAndExtraUsage }
        set {
            self.updateDefaultsState { $0.showOptionalCreditsAndExtraUsage = newValue }
            self.userDefaults.set(newValue, forKey: "showOptionalCreditsAndExtraUsage")
        }
    }

    var openAIWebAccessEnabled: Bool {
        get { self.defaultsState.openAIWebAccessEnabled }
        set {
            self.updateDefaultsState { $0.openAIWebAccessEnabled = newValue }
            self.userDefaults.set(newValue, forKey: "openAIWebAccessEnabled")
            CodexBarLog.logger(LogCategories.settings).info(
                "OpenAI web access updated",
                metadata: ["enabled": newValue ? "1" : "0"])
        }
    }

    var jetbrainsIDEBasePath: String {
        get { self.defaultsState.jetbrainsIDEBasePath }
        set {
            self.updateDefaultsState { $0.jetbrainsIDEBasePath = newValue }
            self.userDefaults.set(newValue, forKey: "jetbrainsIDEBasePath")
        }
    }

    var mergeIcons: Bool {
        get { self.defaultsState.mergeIcons }
        set {
            self.updateDefaultsState { $0.mergeIcons = newValue }
            self.userDefaults.set(newValue, forKey: "mergeIcons")
        }
    }

    var switcherShowsIcons: Bool {
        get { self.defaultsState.switcherShowsIcons }
        set {
            self.updateDefaultsState { $0.switcherShowsIcons = newValue }
            self.userDefaults.set(newValue, forKey: "switcherShowsIcons")
        }
    }

    private var selectedMenuProviderRaw: String? {
        get { self.defaultsState.selectedMenuProviderRaw }
        set {
            self.updateDefaultsState { $0.selectedMenuProviderRaw = newValue }
            if let raw = newValue {
                self.userDefaults.set(raw, forKey: "selectedMenuProvider")
            } else {
                self.userDefaults.removeObject(forKey: "selectedMenuProvider")
            }
        }
    }

    var selectedMenuProvider: UsageProvider? {
        get { self.selectedMenuProviderRaw.flatMap(UsageProvider.init(rawValue:)) }
        set {
            self.selectedMenuProviderRaw = newValue?.rawValue
        }
    }

    var providerDetectionCompleted: Bool {
        get { self.defaultsState.providerDetectionCompleted }
        set {
            self.updateDefaultsState { $0.providerDetectionCompleted = newValue }
            self.userDefaults.set(newValue, forKey: "providerDetectionCompleted")
        }
    }

    var debugLoadingPattern: LoadingPattern? {
        get { self.debugLoadingPatternRaw.flatMap(LoadingPattern.init(rawValue:)) }
        set { self.debugLoadingPatternRaw = newValue?.rawValue }
    }
}
