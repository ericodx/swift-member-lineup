# Xcode Integration

Guide for integrating Swift Member LineUp into your Xcode workflow.

## Build Phase (Recommended)

Add Swift Member LineUp as a build phase to automatically check files on each build.

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
