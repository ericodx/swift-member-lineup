# Xcode Integration

Guide for integrating Swift Member LineUp into your Xcode workflow.

## Installation

First, build and install Swift Member LineUp:

```bash
# Clone the repository
git clone https://github.com/ericodx/swift-member-lineup.git
cd swift-member-lineup

# Build release version
swift build -c release

# Copy to local bin (or /usr/local/bin for global access)
cp .build/release/SwiftMemberLineUp ~/bin/swift-member-lineup
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
# Warns if files need reordering but doesn't fail the build

if which swift-member-lineup >/dev/null; then
    swift-member-lineup check "${SRCROOT}/Sources/**/*.swift" 2>&1 || echo "warning: Swift Member LineUp found files that need reordering"
else
    echo "warning: Swift Member LineUp not installed"
fi
```

### Strict Script (Fail Build on Issues)

```bash
# Swift Member LineUp Check (Strict)
# Fails the build if files need reordering

if which swift-member-lineup >/dev/null; then
    swift-member-lineup check "${SRCROOT}/Sources/**/*.swift"
    if [ $? -ne 0 ]; then
        echo "error: Files need reordering. Run 'swift-member-lineup fix' to fix."
        exit 1
    fi
else
    echo "warning: Swift Member LineUp not installed"
fi
```

### Auto-Fix Script

```bash
# Swift Member LineUp Auto-Fix
# Automatically fixes files before building

if which swift-member-lineup >/dev/null; then
    swift-member-lineup fix "${SRCROOT}/Sources/**/*.swift"
else
    echo "warning: Swift Member LineUp not installed"
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

# Get current Xcode project directory
PROJECT_DIR=$(osascript -e 'tell application "Xcode" to return path of document 1')
PROJECT_DIR=$(dirname "$PROJECT_DIR")

cd "$PROJECT_DIR"

# Run fix
swift-member-lineup fix Sources/**/*.swift

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

### "swift-member-lineup: command not found"

Add the installation path to your script:

```bash
export PATH="$PATH:$HOME/bin"
swift-member-lineup check ...
```

Or use absolute path:

```bash
~/bin/swift-member-lineup check ...
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
