# Dependabot Configuration

## Overview

Dependabot automatically creates PRs to keep project dependencies up to date, improving security and ensuring compatibility with latest versions.

## Configured Ecosystems

### Swift Package Manager

| Setting | Value |
|---------|-------|
| Interval | Weekly |
| Day | Sunday |
| Time | 03:00 (America/Sao_Paulo) |
| PR Limit | 3 |
| Major Updates | Ignored |

Updates dependencies in `Package.swift` and `Package.resolved`.

### GitHub Actions

| Setting | Value |
|---------|-------|
| Interval | Weekly |
| Day | Sunday |
| Time | 03:00 (America/Sao_Paulo) |
| Grouping | All actions in single PR |

Updates action versions in `.github/workflows/*.yml`.

## Configuration

```yaml
version: 2

updates:
  - package-ecosystem: "swift"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "sunday"
      time: "03:00"
      timezone: "America/Sao_Paulo"
    ignore:
      - dependency-name: "*"
        update-types:
          - "version-update:semver-major"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "sunday"
      time: "03:00"
      timezone: "America/Sao_Paulo"
    groups:
      actions:
        patterns:
          - "*"
```

## PR Labels

| Ecosystem | Labels |
|-----------|--------|
| Swift | `dependencies`, `swift`, `spm`, `auto-update` |
| GitHub Actions | `dependencies`, `github-actions`, `auto-update` |

## Update Strategy

- **Minor/Patch**: Automatically created PRs
- **Major**: Ignored for Swift (manual review required)
- **Grouping**: GitHub Actions grouped in single PR to reduce noise

## Related

- [Pre-commit Autoupdate](pre-commit-autoupdate.md) - Updates pre-commit hooks
