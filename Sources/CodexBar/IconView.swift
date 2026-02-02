import CodexBarCore
import SwiftUI

@MainActor
struct IconView: View {
    let snapshot: UsageSnapshot?
    let creditsRemaining: Double?
    let isStale: Bool
    let showLoadingAnimation: Bool
    let style: IconStyle
    @State private var phase: CGFloat
    @ObservedObject private var displayLink: DisplayLinkDriver
    @State private var pattern: LoadingPattern
    @State private var debugCycle: Bool
    @State private var cycleIndex: Int
    @State private var cycleCounter: Int
    private let loadingFPS: Double = 12
    // Advance to next pattern every N ticks when debug cycling.
    private let cycleIntervalTicks = 20
    private let patterns = LoadingPattern.allCases

    private var isLoading: Bool { self.showLoadingAnimation && self.snapshot == nil }

    init(
        snapshot: UsageSnapshot?,
        creditsRemaining: Double?,
        isStale: Bool,
        showLoadingAnimation: Bool,
        style: IconStyle)
    {
        self.snapshot = snapshot
        self.creditsRemaining = creditsRemaining
        self.isStale = isStale
        self.showLoadingAnimation = showLoadingAnimation
        self.style = style
        self._phase = State(initialValue: 0)
        self._displayLink = ObservedObject(wrappedValue: DisplayLinkDriver())
        self._pattern = State(initialValue: .knightRider)
        self._debugCycle = State(initialValue: false)
        self._cycleIndex = State(initialValue: 0)
        self._cycleCounter = State(initialValue: 0)
    }

    var body: some View {
        Group {
            if let snapshot {
                Image(nsImage: IconRenderer.makeIcon(
                    primaryRemaining: snapshot.primary?.remainingPercent,
                    weeklyRemaining: snapshot.secondary?.remainingPercent,
                    creditsRemaining: self.creditsRemaining,
                    stale: self.isStale,
                    style: self.style))
                    .renderingMode(.original)
                    .interpolation(.none)
                    .frame(width: 20, height: 18, alignment: .center)
                    .padding(.horizontal, 2)
            } else if self.showLoadingAnimation {
                // Loading: animate bars with the current pattern until data arrives.
                Image(nsImage: self.loadingImage)
                    .renderingMode(.original)
                    .interpolation(.none)
                    .frame(width: 20, height: 18, alignment: .center)
                    .padding(.horizontal, 2)
                    .codexOnChange(of: self.displayLink.tick) { _ in
                        self.phase += 0.09 // half-speed animation
                        if self.debugCycle {
                            self.cycleCounter += 1
                            if self.cycleCounter >= self.cycleIntervalTicks {
                                self.cycleCounter = 0
                                self.cycleIndex = (self.cycleIndex + 1) % self.patterns.count
                                self.pattern = self.patterns[self.cycleIndex]
                            }
                        }
                    }
            } else {
                // No animation when usage/account is unavailable; show empty tracks.
                Image(nsImage: IconRenderer.makeIcon(
                    primaryRemaining: nil,
                    weeklyRemaining: nil,
                    creditsRemaining: self.creditsRemaining,
                    stale: self.isStale,
                    style: self.style))
                    .renderingMode(.original)
                    .interpolation(.none)
                    .frame(width: 20, height: 18, alignment: .center)
                    .padding(.horizontal, 2)
            }
        }
        .codexOnChange(of: self.isLoading, initial: true) { isLoading in
            if isLoading {
                self.displayLink.start(fps: self.loadingFPS)
                if !self.debugCycle {
                    self.pattern = self.patterns.randomElement() ?? .knightRider
                }
            } else {
                self.displayLink.stop()
                self.debugCycle = false
                self.phase = 0
            }
        }
        .onDisappear { self.displayLink.stop() }
        .onReceive(NotificationCenter.default.publisher(for: .codexbarDebugReplayAllAnimations)) { notification in
            if let raw = notification.userInfo?["pattern"] as? String,
               let selected = LoadingPattern(rawValue: raw)
            {
                self.debugCycle = false
                self.pattern = selected
                self.cycleIndex = self.patterns.firstIndex(of: selected) ?? 0
            } else {
                self.debugCycle = true
                self.cycleIndex = 0
                self.pattern = self.patterns.first ?? .knightRider
            }
            self.cycleCounter = 0
            self.phase = 0
        }
    }

    private var loadingPrimary: Double {
        self.pattern.value(phase: Double(self.phase))
    }

    private var loadingSecondary: Double {
        self.pattern.value(phase: Double(self.phase + self.pattern.secondaryOffset))
    }

    private var loadingImage: NSImage {
        if self.pattern == .unbraid {
            let progress = self.loadingPrimary / 100
            return IconRenderer.makeMorphIcon(progress: progress, style: self.style)
        } else {
            return IconRenderer.makeIcon(
                primaryRemaining: self.loadingPrimary,
                weeklyRemaining: self.loadingSecondary,
                creditsRemaining: nil,
                stale: false,
                style: self.style)
        }
    }
}
