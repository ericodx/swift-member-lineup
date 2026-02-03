# CI Integration

Guide for integrating Swift Member LineUp into continuous integration pipelines.

## Overview

Swift Member LineUp's `check` command returns exit code `1` when files need reordering, making it ideal for CI enforcement.

```bash
# Exit 0 = All files correctly ordered
# Exit 1 = Files need reordering
swift-member-lineup check

# Exit 0 = Files were reordered successfully
# Exit 1 = No files needed reordering
swift-member-lineup fix
```

## GitHub Actions

### Basic Workflow

```yaml
# .github/workflows/swift-member-lineup.yml
name: Swift Member LineUp

on:
  pull_request:
    paths:
      - '**.swift'

jobs:
  check:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Swift Member LineUp
        run: |
          git clone https://github.com/ericodx/swift-member-lineup.git /tmp/swift-member-lineup
          cd /tmp/swift-member-lineup
          swift build -c release
          cp /tmp/swift-member-lineup/.build/release/swift-member-lineup /usr/local/bin/

      - name: Check Swift Member LineUp
        run: |
          swift-member-lineup check
```

### With Caching

```yaml
name: Swift Member LineUp

on:
  pull_request:
    paths:
      - '**.swift'

jobs:
  check:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache Swift Member LineUp
        id: cache-swift-member-lineup
        uses: actions/cache@v4
        with:
          path: /usr/local/bin/swift-member-lineup
          key: swift-member-lineup-v1.0.0

      - name: Build Swift Member LineUp
        if: steps.cache-swift-member-lineup.outputs.cache-hit != 'true'
        run: |
          git clone https://github.com/ericodx/swift-member-lineup.git /tmp/swift-member-lineup
          cd /tmp/swift-member-lineup
          swift build -c release
          cp /tmp/swift-member-lineup/.build/release/swift-member-lineup /usr/local/bin/

      - name: Check Swift Member LineUp
        run: |
          swift-member-lineup check
```

### Auto-Fix and Commit

```yaml
name: Swift Member LineUp Auto-Fix

on:
  pull_request:
    paths:
      - '**.swift'

jobs:
  fix:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Setup Swift Member LineUp
        run: |
          git clone https://github.com/ericodx/swift-member-lineup.git /tmp/swift-member-lineup
          cd /tmp/swift-member-lineup
          swift build -c release
          cp /tmp/swift-member-lineup/.build/release/swift-member-lineup /usr/local/bin/

      - name: Fix Swift Member LineUp
        run: |
          swift-member-lineup fix

      - name: Commit Changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add -A
          git commit -m "fix: apply swift structure" || exit 0
          git push
```

## Best Practices

### Configuration

Always include your `.swift-member-lineup.yaml` in your repository:

```yaml
# .github/workflows/swift-member-lineup.yml
- name: Check Swift Member LineUp
  run: |
    swift-member-lineup check --config .swift-member-lineup.yaml
```

### Performance

- Use caching to avoid rebuilding Swift Member LineUp
- Run only on Swift file changes
- Consider using `--quiet` flag for cleaner logs

### Integration with Other Tools

Swift Member LineUp works well alongside other code quality tools:

```yaml
- name: Run SwiftLint
  run: swiftlint

- name: Check Swift Member LineUp
  run: swift-member-lineup check

- name: Run Tests
  run: swift test
```
