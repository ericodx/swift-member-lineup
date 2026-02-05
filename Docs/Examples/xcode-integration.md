# Xcode Integration

Guide for integrating Swift Member LineUp into your Xcode workflow.

---

## Build Tool Plugin (Recommended)

The Build Tool Plugin provides native Xcode integration with zero configuration. Warnings appear inline in the editor during builds.

### Swift Package Manager Projects

Add the plugin to your `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/ericodx/swift-member-lineup", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "MyApp",
            plugins: [
                .plugin(name: "SwiftMemberLineUpPlugin", package: "swift-member-lineup")
            ]
        ),
    ]
)
```

### Xcode Projects (.xcodeproj)

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter: `https://github.com/ericodx/swift-member-lineup`
3. Select your target → **Build Phases** tab
4. Expand **Run Build Tool Plug-ins**
5. Click **+** and add **SwiftMemberLineUpPlugin**

### How It Works

The plugin runs `swift-member-lineup check --xcode` during each build:

- Analyzes all Swift files in the target
- Reports warnings inline in the Xcode editor
- Does not fail the build (warnings only)
- Uses `.swift-member-lineup.yaml` if present in the project root

### Limitations

Due to SPM sandbox restrictions, the plugin can only run `check`. It cannot modify source files, so `fix` is not available via the plugin.

For auto-fix functionality, use the CLI directly or a Build Phase script.

---

## Build Phase (Alternative)

For more control over execution, or to use `fix` mode, add a Run Script Build Phase.

### Setup Steps

1. Select your project in Xcode
2. Select your target
3. Go to **Build Phases**
4. Click **+** → **New Run Script Phase**
5. Name it "Swift Member LineUp Check"
6. Add the script below

### Check Script (Warning on Issues)

```bash
export PATH="/opt/homebrew/bin:$PATH"

if command -v swift-member-lineup >/dev/null; then
    swift-member-lineup check --xcode --path "${SRCROOT}/Sources"
else
    echo "warning: swift-member-lineup not installed"
fi
```

The `--xcode` flag outputs warnings in Xcode-compatible format and does not fail the build.

### Strict Script (Fail Build on Issues)

```bash
export PATH="/opt/homebrew/bin:$PATH"

if command -v swift-member-lineup >/dev/null; then
    swift-member-lineup check --path "${SRCROOT}/Sources"
else
    echo "warning: swift-member-lineup not installed"
fi
```

### Auto-Fix Script

```bash
export PATH="/opt/homebrew/bin:$PATH"

if command -v swift-member-lineup >/dev/null; then
    swift-member-lineup fix --path "${SRCROOT}/Sources"
else
    echo "warning: swift-member-lineup not installed"
fi
```

### Build Phase Position

Place the script phase:
- **Before "Compile Sources"** for auto-fix
- **After "Compile Sources"** for check-only (faster builds)

```
┌─────────────────────────────┐
│ Target Dependencies         │
├─────────────────────────────┤
│ Swift Member LineUp Fix     │  ← Auto-fix here
├─────────────────────────────┤
│ Compile Sources             │
├─────────────────────────────┤
│ Swift Member LineUp Check   │  ← Or check here
├─────────────────────────────┤
│ Link Binary With Libraries  │
└─────────────────────────────┘
```

## Xcode Behaviors

Run Swift Member LineUp via Xcode behaviors for on-demand execution.

### Setup

1. Go to **Xcode** → **Behaviors** → **Edit Behaviors**
2. Click **+** to add custom behavior
3. Name it "Swift Member LineUp Fix"
4. Check **Run** and select your script
5. Assign a keyboard shortcut (e.g., ⌘⇧M)

### Script for Behavior

Save as `~/Scripts/swift-member-lineup-fix.sh`:

```bash
#!/bin/bash
export PATH="/opt/homebrew/bin:$PATH"

# Get current Xcode project directory
PROJECT_DIR=$(osascript -e 'tell application "Xcode" to return path of document 1')
PROJECT_DIR=$(dirname "$PROJECT_DIR")

cd "$PROJECT_DIR"

# Run fix
swift-member-lineup fix --path Sources

# Notify
osascript -e 'display notification "Swift Member LineUp fix complete" with title "Xcode"'
```

Make executable:
```bash
chmod +x ~/Scripts/swift-member-lineup-fix.sh
```

## Troubleshooting

### "swift-member-lineup: command not found"

Xcode Build Phases use `/bin/sh` and do not load your shell profile, so Homebrew commands are not in the PATH.

**Solution:** Add Homebrew to PATH at the start of your script:
```bash
export PATH="/opt/homebrew/bin:$PATH"
```

### Build Phase Not Running

1. Uncheck "Based on dependency analysis"
2. Remove input/output files if specified
3. Verify script has correct permissions

### Slow Builds

- Move check phase after "Compile Sources"
- Check only changed files using `git diff`
