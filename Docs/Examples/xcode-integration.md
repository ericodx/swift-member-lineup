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
# Swift Member LineUp Check
# Shows warnings in Xcode Issue Navigator without failing the build

LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"

if [ -x "$LINEUP_CMD" ]; then
    "$LINEUP_CMD" check --xcode --path "${SRCROOT}/Sources"
else
    echo "warning: Swift Member LineUp not installed at $LINEUP_CMD"
fi
```

The `--xcode` flag outputs warnings in Xcode-compatible format and does not fail the build.

### Strict Script (Fail Build on Issues)

```bash
# Swift Member LineUp Check (Strict)
# Fails the build if files need reordering

LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"

if [ -x "$LINEUP_CMD" ]; then
    "$LINEUP_CMD" check --path "${SRCROOT}/Sources"
else
    echo "warning: Swift Member LineUp not installed at $LINEUP_CMD"
fi
```

### Auto-Fix Script

```bash
# Swift Member LineUp Auto-Fix
# Automatically fixes files before building

LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"

if [ -x "$LINEUP_CMD" ]; then
    "$LINEUP_CMD" fix --path "${SRCROOT}/Sources"
else
    echo "warning: Swift Member LineUp not installed at $LINEUP_CMD"
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

LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"

# Get current Xcode project directory
PROJECT_DIR=$(osascript -e 'tell application "Xcode" to return path of document 1')
PROJECT_DIR=$(dirname "$PROJECT_DIR")

cd "$PROJECT_DIR"

# Run fix
"$LINEUP_CMD" fix --path Sources

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

**Solution:** Use the absolute path `/opt/homebrew/bin/swift-member-lineup`

To verify installation path:
```bash
which swift-member-lineup
```

### Build Phase Not Running

1. Uncheck "Based on dependency analysis"
2. Remove input/output files if specified
3. Verify script has correct permissions

### Slow Builds

- Move check phase after "Compile Sources"
- Check only changed files using `git diff`
