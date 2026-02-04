import ArgumentParser
import Foundation

struct CheckCommand: AsyncParsableCommand {

    // MARK: - Configuration

    static let configuration = CommandConfiguration(
        commandName: "check",
        abstract: "Analyze Swift files and report structural order.",
        discussion: """
            Analyzes Swift files and reports which types need member reordering. \
            Exits with code 1 if any files need changes.

            EXAMPLES:
              swift-member-lineup check Sources/*.swift
              swift-member-lineup check --path Sources
              swift-member-lineup check --path Sources --warn-only
              swift-member-lineup check --config .swift-member-lineup.yaml --path Sources/
            """
    )

    // MARK: - Arguments

    @Argument(help: "Swift source files to analyze.")
    var files: [String] = []

    @Option(name: .shortAndLong, help: "Directory to recursively search for Swift files.")
    var path: String?

    @Option(name: .shortAndLong, help: "Path to configuration file.")
    var config: String?

    @Flag(name: .shortAndLong, help: "Only show files that need reordering.")
    var quiet: Bool = false

    @Flag(name: .long, help: "Exit with code 0 even if files need reordering. Useful for Xcode Build Phases.")
    var warnOnly: Bool = false

    // MARK: - Execution

    func run() async throws {
        let filesToCheck = try resolveFiles()

        guard !filesToCheck.isEmpty else {
            throw ValidationError("No Swift files found. Provide files as arguments or use --path.")
        }

        let fileIO = FileIOActor()
        let fileReader = FileReader()
        let configService = ConfigurationService(fileReader: fileReader)
        let configuration = try await configService.load(configPath: config)

        let coordinator = PipelineCoordinator(fileIO: fileIO, configuration: configuration)
        let results = try await coordinator.checkFiles(filesToCheck)

        var totalTypes = 0
        var typesNeedingReorder = 0
        var filesNeedingReorder: [String] = []

        for result in results {
            totalTypes += result.results.count

            if result.needsReorder {
                filesNeedingReorder.append(result.path)
                typesNeedingReorder += result.results.filter(\.needsReordering).count
            }

            if !quiet {
                let reportStage = ReorderReportStage()
                let reorderOutput = ReorderOutput(path: result.path, results: result.results)
                let reportOutput = try reportStage.process(reorderOutput)
                print(reportOutput.text)
                print()
            }
        }

        printSummary(
            totalFiles: filesToCheck.count,
            totalTypes: totalTypes,
            filesNeedingReorder: filesNeedingReorder,
            typesNeedingReorder: typesNeedingReorder
        )

        if !filesNeedingReorder.isEmpty && !warnOnly {
            throw ExitCode(1)
        }
    }

    // MARK: - Private Helpers

    private func printSummary(
        totalFiles: Int,
        totalTypes: Int,
        filesNeedingReorder: [String],
        typesNeedingReorder: Int
    ) {
        if filesNeedingReorder.isEmpty {
            print(
                "✓ All \(totalTypes) types in \(totalFiles) \(totalFiles == 1 ? "file" : "files") are correctly ordered"
            )
        } else {
            if quiet {
                for file in filesNeedingReorder {
                    print("\(file)")
                }
                print()
            }
            let typeWord = typesNeedingReorder == 1 ? "type" : "types"
            let fileWord = filesNeedingReorder.count == 1 ? "file needs" : "files need"
            print("✗ \(typesNeedingReorder) \(typeWord) in \(filesNeedingReorder.count) \(fileWord) reordering")
            print("  Run 'swift-member-lineup fix' to apply changes")
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
