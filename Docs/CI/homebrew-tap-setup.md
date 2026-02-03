# Homebrew Tap Setup

Guide to configure automatic Homebrew formula updates on each release.

---

## homebrew-tap Repository

**URL:** https://github.com/new

### Create repository

1. Name: `homebrew-tap`
2. Visibility: **Public**
3. Click **Create repository**

### Create formula

Create the file `Formula/swift-member-lineup.rb`:

```ruby
class SwiftMemberLineUp < Formula
  desc "CLI tool for organizing Swift type members"
  homepage "https://github.com/ericodx/swift-member-lineup"
  url "https://github.com/ericodx/swift-member-lineup/releases/download/v1.0.0/swift-member-lineup-v1.0.0-macos.tar.gz"
  sha256 "placeholder"

  def install
    bin.install "SwiftMemberLineUp"
  end
end
```

---

## Personal Access Token

**URL:** https://github.com/settings/tokens?type=beta

### Create token

1. Click **Generate new token**
2. Fill in the fields:

| Field | Value |
|-------|-------|
| Token name | `swift-member-lineup-tap-token` |
| Description | `Token to update Homebrew tap formula via release workflow` |
| Expiration | 90 days |
| Resource owner | `ericodx` |
| Repository access | Only select repositories |
| Select repositories | `ericodx/homebrew-tap` |

3. Under **Permissions → Repository permissions**, configure:

| Permission | Level |
|------------|-------|
| Contents | Read and write |
| Pull requests | Read and write |

4. Click **Generate token**
5. **Copy the token** (it won't be shown again)

---

## swift-member-lineup Repository

**URL:** https://github.com/ericodx/swift-member-lineup/settings/secrets/actions

### Create secret

1. Click **New repository secret**
2. Fill in the fields:

| Field | Value |
|-------|-------|
| Name | `TAP_GITHUB_TOKEN` |
| Secret | (paste the token copied above) |

3. Click **Add secret**

---

## Verification

After completing all configurations, test by creating a release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Verify:
1. swift-member-lineup Actions ran successfully
2. PR was created in the homebrew-tap repository

---

## Troubleshooting

**PR not created:**
- Verify the token has access to the `homebrew-tap` repository
- Verify Contents and Pull requests permissions are set to "Read and write"

**Permission denied error:**
- Regenerate the token with correct permissions
- Verify the `TAP_GITHUB_TOKEN` secret was saved correctly
