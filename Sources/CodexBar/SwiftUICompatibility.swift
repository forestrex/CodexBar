import Combine
import SwiftUI

@available(macOS, introduced: 10.15, obsoleted: 11.0)
struct Label<Title: View, Icon: View>: View {
    private let title: Title
    private let icon: Icon

    init(title: () -> Title, icon: () -> Icon) {
        self.title = title()
        self.icon = icon()
    }

    init(_ titleKey: String, systemImage: String) where Title == Text, Icon == Image {
        self.title = Text(titleKey)
        self.icon = Image(systemName: systemImage)
    }

    var body: some View {
        HStack(spacing: 6) {
            self.icon
            self.title
        }
    }
}

@propertyWrapper
struct CodexAppStorage<Value>: DynamicProperty {
    @State private var value: Value
    private let key: String
    private let store: UserDefaults

    init(_ key: String, defaultValue: Value, store: UserDefaults = .standard) {
        self.key = key
        self.store = store
        let storedValue = store.object(forKey: key) as? Value
        self._value = State(initialValue: storedValue ?? defaultValue)
    }

    var wrappedValue: Value {
        get { self.value }
        nonmutating set {
            self.value = newValue
            self.store.set(newValue, forKey: self.key)
        }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { self.value },
            set: { newValue in
                self.value = newValue
                self.store.set(newValue, forKey: self.key)
            })
    }
}

@available(macOS, introduced: 10.15, obsoleted: 12.0)
extension View {
    @ViewBuilder
    func foregroundStyle<S>(_ style: S) -> some View where S: ShapeStyle {
        if let color = style as? Color {
            self.foregroundColor(color)
        } else {
            self.foregroundColor(.primary)
        }
    }
}

extension View {
    @ViewBuilder
    func codexScrollContentBackgroundHidden() -> some View {
        if #available(macOS 13.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self
        }
    }

    @ViewBuilder
    func codexSidebarListStyle() -> some View {
        if #available(macOS 11.0, *) {
            self.listStyle(.sidebar)
        } else {
            self.listStyle(DefaultListStyle())
        }
    }

    @ViewBuilder
    func codexCheckboxStyle() -> some View {
        if #available(macOS 12.0, *) {
            self.toggleStyle(.checkbox)
        } else {
            self.toggleStyle(DefaultToggleStyle())
        }
    }

    @ViewBuilder
    func codexTextSelection(_ enabled: Bool) -> some View {
        if #available(macOS 12.0, *) {
            self.textSelection(enabled ? .enabled : .disabled)
        } else {
            self
        }
    }

    func codexOnChange<Value: Equatable>(
        of value: Value,
        initial: Bool = false,
        perform action: @escaping (Value) -> Void) -> some View
    {
        if #available(macOS 11.0, *) {
            return self.onAppear {
                if initial { action(value) }
            }
            .onChange(of: value) { newValue in
                action(newValue)
            }
        }
        return self.modifier(CodexValueChangeObserver(value: value, initial: initial, action: action))
    }
}

private struct CodexValueChangeObserver<Value: Equatable>: ViewModifier {
    let value: Value
    let initial: Bool
    let action: (Value) -> Void
    @State private var lastValue: Value?

    func body(content: Content) -> some View {
        content
            .onAppear {
                if self.initial {
                    self.action(self.value)
                }
                self.lastValue = self.value
            }
            .onReceive(Just(self.value)) { newValue in
                guard self.lastValue != newValue else { return }
                self.lastValue = newValue
                self.action(newValue)
            }
    }
}
