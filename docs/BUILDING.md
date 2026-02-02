# Building CodexBar (macOS + Linux)

## macOS (app + CLI)

### Prerequisites
- Xcode 15+ (for Swift 6 toolchain) or `swift` from Xcode Command Line Tools.
- Node.js + pnpm (for `pnpm check` formatting/linting).

### Build + test
```sh
swift build
swift test
pnpm check
```

### Run the app (development loop)
```sh
./Scripts/compile_and_run.sh
```

### Package the app bundle
```sh
./Scripts/package_app.sh
```

## Linux (CLI + tests)

### Prerequisites
- Ubuntu 24.04 (x86_64 recommended for web dashboard support).
- Swift 6 toolchain (SwiftPM).
- Node.js + pnpm (optional; only required for `pnpm check`).

### Build + test
```sh
swift build
swift test
```

### Formatting + lint (optional on Linux)
```sh
pnpm check
```

### Web dashboard notes (Linux)
The Codex web dashboard fetch requires a manual cookie header in
`~/.codexbar/config.json` (set `providers.codex.cookieHeader`) and is only
enabled on Linux x86_64.
