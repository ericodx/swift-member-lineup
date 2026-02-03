# Installation

This document describes various ways to install Swift Member LineUp.

---

## Homebrew (Recommended)

The easiest way to install Swift Member LineUp is via Homebrew:

```bash
brew tap ericodx/homebrew-tap
brew install swift-member-lineup
```

### Update

```bash
brew upgrade swift-member-lineup
```

### Uninstall

```bash
brew uninstall swift-member-lineup
```

---

## Manual Installation

### Build from Source

```bash
git clone https://github.com/ericodx/swift-member-lineup.git
cd swift-member-lineup
swift build -c release

# Install to user local bin
mkdir -p ~/.local/bin
cp .build/release/SwiftMemberLineUp ~/.local/bin/swift-member-lineup

# Add to PATH (add this to your ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"
```

### Verify Installation

```bash
swift-member-lineup --version
swift-member-lineup --help
```

---

## Direct Download

You can download pre-compiled binaries from [GitHub Releases](https://github.com/ericodx/swift-member-lineup/releases).

1. Download the latest `swift-member-lineup-v*.macos.tar.gz`
2. Extract the binary:
   ```bash
   tar -xzf swift-member-lineup-v*.macos.tar.gz
   ```
3. Move to your PATH:
   ```bash
   mv swift-member-lineup ~/.local/bin/
   ```

---

## Requirements

- **macOS** 15.0 (Sequoia) or later
- **Swift** 6.0+ (for building from source)
- **Xcode** 15.0+ (for building from source)

---

##  Verification

After installation, verify that Swift Member LineUp is working:

```bash
# Check version
swift-member-lineup --version

# Check help
swift-member-lineup --help

# Test on a sample file
echo 'struct Test { func b() {} func a() {} }' > test.swift
swift-member-lineup check test.swift
```

---

## 🐛 Troubleshooting

### Command not found

```bash
# Check if binary is in PATH
which swift-member-lineup

# If not found, add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Permission denied

```bash
# Make binary executable
chmod +x ~/.local/bin/swift-member-lineup
```

### Build from source fails

```bash
# Clean build cache
rm -rf .build
swift build -c release

# Ensure Xcode command line tools are installed
xcode-select --install
```

---

## Updates

### Homebrew

```bash
brew upgrade swift-member-lineup
```

### Manual

```bash
cd swift-member-lineup
git pull origin main
swift build -c release
cp .build/release/SwiftMemberLineUp ~/.local/bin/swift-member-lineup
```

---

## Next Steps

- [Usage Guide](../README.md#usage)
- [Configuration](./CONFIGURATION.md)
- [Examples](./EXAMPLES.md)
