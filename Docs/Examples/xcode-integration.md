# Xcode Integration

Guide for integrating Swift Member LineUp into your Xcode workflow.

## Installation

### Via Homebrew (Recommended)

```bash
brew install ericodx/tap/swift-member-lineup
```

The binary will be installed at:
- **Apple Silicon (M1/M2):** `/opt/homebrew/bin/swift-member-lineup`
- **Intel Mac:** `/usr/local/bin/swift-member-lineup`

### Build from Source

```bash
# Clone the repository
git clone https://github.com/ericodx/swift-member-lineup.git
cd swift-member-lineup

# Build release version
swift build -c release

# Copy to local bin (or /usr/local/bin for global access)
cp .build/release/swift-member-lineup ~/bin/
```

## Option 1: Build Phase (Recommended)

Add Swift Member LineUp as a build phase to automatically check files on each build.

### Setup Steps

1. Select your project in Xcode
2. Select your target
3. Go to **Build Phases**
4. Click **+** → **New Run Script Phase**
5. Name it "Swift Member LineUp Check"
6. Add the script below

### Check-Only Script (Warning on Issues)

```bash
# Swift Member LineUp Check
# Shows warnings in Xcode Issue Navigator without failing the build

# Path to swift-member-lineup (Homebrew on Apple Silicon)
LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"
# For Intel Mac, use: LINEUP_CMD="/usr/local/bin/swift-member-lineup"

if [ -x "$LINEUP_CMD" ]; then
    "$LINEUP_CMD" check --xcode --path "${SRCROOT}/Sources"
else
    echo "warning: Swift Member LineUp not installed at $LINEUP_CMD"
fi
```

The `--xcode` flag outputs warnings in Xcode-compatible format and implies `--warn-only`.

### Strict Script (Fail Build on Issues)

```bash
# Swift Member LineUp Check (Strict)
# Fails the build if files need reordering

# Path to swift-member-lineup (Homebrew on Apple Silicon)
LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"
# For Intel Mac, use: LINEUP_CMD="/usr/local/bin/swift-member-lineup"

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

# Path to swift-member-lineup (Homebrew on Apple Silicon)
LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"
# For Intel Mac, use: LINEUP_CMD="/usr/local/bin/swift-member-lineup"

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
│ SwiftMemberLineUp Fix          │  ← Auto-fix here
├─────────────────────────────┤
│ Compile Sources             │
├─────────────────────────────┤
│ SwiftMemberLineUp Check        │  ← Or check here
├─────────────────────────────┤
│ Link Binary With Libraries  │
└─────────────────────────────┘
```

## Option 2: Pre-commit Hook

Run Swift Member LineUp before each commit.

### Setup

```bash
# Create hooks directory if needed
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Get staged Swift files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$')

if [ -n "$STAGED_FILES" ]; then
    echo "Running Swift Member LineUp check..."

    # Check staged files
    swift-member-lineup check $STAGED_FILES

    if [ $? -ne 0 ]; then
        echo ""
        echo "XSwift Member LineUp check failed."
        echo "Run 'swift-member-lineup fix <files>' to fix ordering."
        echo "Or use 'git commit --no-verify' to skip this check."
        exit 1
    fi

    echo "✓ Swift Member LineUp check passed."
fi

exit 0
EOF

# Make executable
chmod +x .git/hooks/pre-commit
```

### Auto-Fix Pre-commit

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$')

if [ -n "$STAGED_FILES" ]; then
    echo "Running Swift Member LineUp fix..."

    # Fix staged files
    swift-member-lineup fix $STAGED_FILES

    # Re-stage fixed files
    git add $STAGED_FILES

    echo "✓ Swift Member LineUp fix complete."
fi

exit 0
EOF

chmod +x .git/hooks/pre-commit
```

## Option 3: Xcode Behaviors

Run Swift Member LineUp via Xcode behaviors for on-demand execution.

### Setup

1. Go to **Xcode** → **Behaviors** → **Edit Behaviors**
2. Click **+** to add custom behavior
3. Name it "Swift Member LineUp Fix"
4. Check **Run** and select your script
5. Assign a keyboard shortcut (e.g., ⌘⇧S)

### Script for Behavior

Save as `~/Scripts/swift-member-lineup-fix.sh`:

```bash
#!/bin/bash

# Path to swift-member-lineup (Homebrew on Apple Silicon)
LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"
# For Intel Mac, use: LINEUP_CMD="/usr/local/bin/swift-member-lineup"

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

## Option 4: External Build Tool

For Swift Package Manager projects, add as a plugin or build tool.

### Package.swift Plugin

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyPackage",
    targets: [
        .executableTarget(
            name: "MyApp",
            plugins: [
                .plugin(name: "SwiftMemberLineUpPlugin")
            ]
        )
    ]
)
```

## Troubleshooting

### "swift-member-lineup: command not found" in Xcode Build Phase

Xcode Build Phases use `/bin/sh` and do not load your shell profile (~/.zshrc or ~/.bashrc), so commands installed via Homebrew are not in the PATH.

**Solution:** Use the absolute path to the binary:

```bash
# Apple Silicon (M1/M2)
LINEUP_CMD="/opt/homebrew/bin/swift-member-lineup"

# Intel Mac
LINEUP_CMD="/usr/local/bin/swift-member-lineup"
```

To find your installation path, run in Terminal:
```bash
which swift-member-lineup
```

### Glob patterns not working in Build Phase

Xcode Build Phases use `/bin/sh` which does not support `**` glob patterns (globstar). Use the `--path` option instead:

```bash
# Instead of: swift-member-lineup check "${SRCROOT}/Sources/**/*.swift"
# Use:
swift-member-lineup check --path "${SRCROOT}/Sources"
```

### Build Phase Not Running

1. Check "Based on dependency analysis" is unchecked
2. Check input/output files are not specified
3. Verify script has correct permissions

### Slow Builds

- Move check phase after "Compile Sources"
- Check only changed files using `git diff`
- Use `--dry-run` for preview without modification

### Files Not Being Fixed

1. Verify `.swift-member-lineup.yaml` exists in project root
2. Check file paths match glob pattern
3. Run manually to see error messages:
   ```bash
   cd /path/to/project
   swift-member-lineup check Sources/MyFile.swift
   ```
