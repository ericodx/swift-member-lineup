import PackagePlugin

@main
struct SwiftMemberLineUpPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else {
            return []
        }

        let tool = try context.tool(named: "swift-member-lineup")
        let outputPath = context.pluginWorkDirectoryURL.appending(path: "swift-member-lineup.marker")

        return [
            .buildCommand(
                displayName: "Swift Member LineUp Check",
                executable: tool.url,
                arguments: [
                    "check",
                    "--xcode",
                    "--path", sourceTarget.directoryURL.path(),
                    "--output", outputPath.path(),
                ],
                outputFiles: [outputPath]
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SwiftMemberLineUpPlugin: XcodeBuildToolPlugin {
        func createBuildCommands(
            context: XcodePluginContext,
            target: XcodeTarget
        ) throws -> [Command] {
            let tool = try context.tool(named: "swift-member-lineup")
            let outputPath = context.pluginWorkDirectoryURL.appending(path: "swift-member-lineup.marker")

            return [
                .buildCommand(
                    displayName: "Swift Member LineUp Check",
                    executable: tool.url,
                    arguments: [
                        "check",
                        "--xcode",
                        "--path", context.xcodeProject.directoryURL.path(),
                        "--output", outputPath.path(),
                    ],
                    outputFiles: [outputPath]
                )
            ]
        }
    }
#endif
