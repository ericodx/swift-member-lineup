# Swift Member LineUp (Entry Point)

**Source**: `Sources/SwiftMemberLineUp/SwiftMemberLineUp.swift`

The root command that serves as the CLI entry point.

## Structure

| Component | Description |
|-----------|-------------|
| **Type** | `struct SwiftMemberLineUp` |
| **Protocol** | `AsyncParsableCommand` |
| **Attribute** | `@main` (application entry point) |

## Configuration

| Property | Value |
|----------|-------|
| `commandName` | `"swift-member-lineup"` |
| `abstract` | Short description for help |
| `discussion` | Extended help with examples |
| `version` | Semantic version string |
| `subcommands` | Array of command types |

## Responsibilities

- Defines the CLI name and version
- Registers all subcommands
- Provides root-level help text
- Delegates execution to subcommands

## Notes

- Uses `AsyncParsableCommand` to support async subcommands
- Does not implement `run()` - only serves as command container
