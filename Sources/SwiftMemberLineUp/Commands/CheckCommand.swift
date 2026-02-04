import ArgumentParser
import Foundation

struct CheckCommand: AsyncParsableCommand {

    // MARK: - Configuration

    @Argument(help: "Swift source files to analyze.")
    var files: [String] = []

    @Option(name: .shortAndLong, help: "Directory to recursively search for Swift files.")
    var path: String?

    @Option(name: .shortAndLong, help: "Path to configuration file.")
    var config: String?

    @Flag(name: .shortAndLong, help: "Only show files that need reordering.")
    var quiet: Bool = false

    @Flag(name: .long, help: "Exit with code 0 even if files need reordering.")
    var warnOnly: Bool = false

    @Flag(name: .long, help: "Output warnings in Xcode-compatible format. Implies --warn-only.")
    var xcode: Bool = false

    // MARK: - Arguments

    static let configuration = CommandConfiguration(
        commandName: "check",
        abstract: "Analyze Swift files and report structural order.",
        discussion: """
            Analyzes Swift files and reports which types need member reordering. \
            Exits with code 1 if any files need changes.

            EXAMPLES:
              swift-member-lineup check Sources/*.swift
              swift-member-lineup check --path Sources
              swift-member-lineup check --xcode --path Sources
              swift-member-lineup check --config .swift-member-lineup.yaml --path Sources/
            """
    )

    // MARK: - Execution

    func run() async throws {
        let filesToCheck = SwiftFileResolver.resolve(files: files, path: path)

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

            if xcode {
                printXcodeWarnings(path: result.path, results: result.results)
            } else if !quiet {
                let reportStage = ReorderReportStage()
                let reorderOutput = ReorderOutput(path: result.path, results: result.results)
                let reportOutput = try reportStage.process(reorderOutput)
                print(reportOutput.text)
                print()
            }
        }

        if !xcode {
            printSummary(
                totalFiles: filesToCheck.count,
                totalTypes: totalTypes,
                filesNeedingReorder: filesNeedingReorder,
                typesNeedingReorder: typesNeedingReorder
            )
        }

        let shouldFail = !filesNeedingReorder.isEmpty && !warnOnly && !xcode
        if shouldFail {
            throw ExitCode(1)
        }
    }

    // MARK: - Private Helpers

    private func printXcodeWarnings(path: String, results: [TypeReorderResult]) {
        for result in results where result.needsReordering {
            print("\(path):\(result.line): warning: '\(result.name)' members need reordering")
        }
    }

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

}
