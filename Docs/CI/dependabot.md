# Dependabot Configuration

**Source**: `.github/dependabot.yml`

## Overview

Dependabot automatically creates pull requests to keep dependencies up to date. This configuration manages Swift Package Manager dependencies and GitHub Actions versions.

## Configuration

### Swift Dependencies

```yaml
package-ecosystem: "swift"
directory: "/"
schedule:
  interval: "weekly"
  day: "sunday"
  time: "03:00"
  timezone: "America/Sao_Paulo"
```

| Setting | Value | Description |
|---------|-------|-------------|
| Interval | Weekly (Sunday 03:00) | When to check for updates |
| PR Limit | 3 | Maximum open PRs at once |
| Major Updates | Ignored | Only minor/patch updates |

**Labels applied**:
- `dependencies`
- `swift`
- `spm`
- `auto-update`

### GitHub Actions

```yaml
package-ecosystem: "github-actions"
directory: "/"
schedule:
  interval: "weekly"
  day: "sunday"
  time: "03:00"
  timezone: "America/Sao_Paulo"
```

| Setting | Value | Description |
|---------|-------|-------------|
| Interval | Weekly (Sunday 03:00) | When to check for updates |
| Grouping | All actions together | Single PR for all action updates |

**Labels applied**:
- `dependencies`
- `github-actions`
- `auto-update`

## Update Strategy

### Swift Packages

- **Minor updates**: Automatically created
- **Patch updates**: Automatically created
- **Major updates**: Ignored (manual review required)

This conservative approach prevents breaking changes from being automatically introduced.

### GitHub Actions

- All updates grouped into a single PR
- Reduces noise from multiple action update PRs
- Easier to review and merge

## Assignees and Reviewers

All Dependabot PRs are automatically:
- Assigned to: `ericodx`
- Review requested from: `ericodx`

## Workflow Integration

Dependabot PRs are excluded from the main `pull-request-analysis` workflow to avoid unnecessary CI runs. Dependabot has its own security checks.

```yaml
# In pull-request-analysis.yml
if: github.actor != 'dependabot[bot]'
```

## Schedule

| Day | Time | Timezone | Ecosystems |
|-----|------|----------|------------|
| Sunday | 03:00 | America/Sao_Paulo | Swift, GitHub Actions |

Updates are scheduled during low-activity periods to minimize disruption.

## Related Documentation

- [Pull Request Analysis](pull-request-analysis.md) - PR quality checks
- [Main Analysis](main-analysis.md) - Production branch analysis
