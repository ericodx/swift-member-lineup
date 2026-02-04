import Testing

@testable import swift_member_lineup

@Suite("Version Tests")
struct VersionTests {

    @Test("Given Version.current, when accessed, then returns a non-empty string")
    func currentVersionIsNotEmpty() {
        #expect(!Version.current.isEmpty)
    }

    @Test("Given Version.current, when accessed, then matches semantic versioning pattern")
    func currentVersionMatchesSemanticPattern() {
        let semverPattern = #"^\d+\.\d+\.\d+(-\w+)?$"#
        let regex = try? Regex(semverPattern)

        #expect(regex != nil)
        #expect(Version.current.contains(regex!))
    }
}
