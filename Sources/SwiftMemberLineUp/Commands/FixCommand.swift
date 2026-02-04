import ArgumentParser
import Foundation

struct FixCommand: AsyncParsableCommand {

    // MARK: - Configuration

    static let configuration = CommandConfiguration(
        commandName: "fix",
        abstract: "Reorder members in Swift files.",
        discussion: """
            Applies member reordering to Swift files. Use --dry-run to preview \
            changes without modifying files. In dry-run mode, exits with code 1 \
            if any files would be modified.

            EXAMPLES:
              swift-member-lineup fix Sources/*.swift
              swift-member-lineup fix --path Sources
              swift-member-lineup fix --path Sources --dry-run
              swift-member-lineup fix --quiet --config custom.yaml --path Sources/
            """
    )

    // MARK: - Arguments

    @Argument(help: "Swift source files to fix.")
    var files: [String] = []

    @Option(name: .shortAndLong, help: "Directory to recursively search for Swift files.")
    var path: String?

    @Option(name: .shortAndLong, help: "Path to configuration file.")
    var config: String?

    @Flag(name: .long, help: "Show changes without modifying files.")
    var dryRun: Bool = false

    @Flag(name: .shortAndLong, help: "Only show summary.")
    var quiet: Bool = false

    // MARK: - Execution

    func run() async throws {
        let filesToFix = try resolveFiles()

        guard !filesToFix.isEmpty else {
            throw ValidationError("No Swift files found. Provide files as arguments or use --path.")
        }

        let fileIO = FileIOActor()
        let fileReader = FileReader()
        let configService = ConfigurationService(fileReader: fileReader)
        let configuration = try await configService.load(configPath: config)

        let coordinator = PipelineCoordinator(fileIO: fileIO, configuration: configuration)
        let results = try await coordinator.fixFiles(filesToFix, dryRun: dryRun)

        var modifiedFiles: [String] = []

        for result in results where result.modified {
            modifiedFiles.append(result.path)

            if !quiet {
                if dryRun {
                    print("Would reorder: \(result.path)")
                } else {
                    print("Reordered: \(result.path)")
                }
            }
        }

        printSummary(
            totalFiles: filesToFix.count,
            modifiedFiles: modifiedFiles,
            dryRun: dryRun
        )

        if dryRun && !modifiedFiles.isEmpty {
            throw ExitCode(1)
        }
    }

    // MARK: - Private Helpers

    private func printSummary(totalFiles: Int, modifiedFiles: [String], dryRun: Bool) {
        let count = modifiedFiles.count

        if count == 0 {
            print("✓ All \(totalFiles) \(totalFiles == 1 ? "file" : "files") already correctly ordered")
        } else if dryRun {
            print("⚠ \(count) \(count == 1 ? "file" : "files") would be modified")
        } else {
            print("✓ \(count) \(count == 1 ? "file" : "files") reordered")
        }
    }

    private func resolveFiles() throws -> [String] {
        var result = files

        if let path = path {
            let pathFiles = findSwiftFiles(in: path)
            result.append(contentsOf: pathFiles)
        }

        return result
    }

    private func findSwiftFiles(in directory: String) -> [String] {
        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: directory)

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var swiftFiles: [String] = []

        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "swift" {
                swiftFiles.append(fileURL.path)
            }
        }

        return swiftFiles.sorted()
    }
}
