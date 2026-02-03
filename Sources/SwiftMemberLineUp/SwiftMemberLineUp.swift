import ArgumentParser

@main
struct SwiftMemberLineUp: AsyncParsableCommand {

    // MARK: - Configuration

    static let configuration = CommandConfiguration(
        commandName: "swift-member-lineup",
        abstract: "Organize the internal structure of Swift types.",
        discussion: """
            Swift Member LineUp reorders members within Swift type declarations based on \
            configurable rules while preserving all comments and formatting.

            EXAMPLES:
              swift-member-lineup check Sources/**/*.swift
              swift-member-lineup fix --dry-run Sources/MyFile.swift
              swift-member-lineup init --force
            """,
        version: Version.current,
        subcommands: [InitCommand.self, CheckCommand.self, FixCommand.self]
    )
}
