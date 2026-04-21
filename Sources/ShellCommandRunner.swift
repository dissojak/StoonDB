import Foundation

struct CommandResult {
    let exitCode: Int32
    let standardOutput: String
    let standardError: String
    let timedOut: Bool

    var succeeded: Bool {
        exitCode == 0 && !timedOut
    }

    var combinedOutput: String {
        [
            standardOutput.trimmingCharacters(in: .whitespacesAndNewlines),
            standardError.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
    }
}

struct ShellCommandRunner: Sendable {
    func run(executable: String, arguments: [String], timeout: TimeInterval = 12) async -> CommandResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = Self.runBlocking(executable: executable, arguments: arguments, timeout: timeout)
                continuation.resume(returning: result)
            }
        }
    }

    func commandExists(_ command: String) async -> Bool {
        let result = await run(
            executable: "/usr/bin/env",
            arguments: ["which", command],
            timeout: 3
        )
        return result.succeeded
    }

    private static func runBlocking(executable: String, arguments: [String], timeout: TimeInterval) -> CommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        let completionGroup = DispatchGroup()
        completionGroup.enter()
        process.terminationHandler = { _ in
            completionGroup.leave()
        }

        do {
            try process.run()
        } catch {
            return CommandResult(
                exitCode: 1,
                standardOutput: "",
                standardError: error.localizedDescription,
                timedOut: false
            )
        }

        let completed = completionGroup.wait(timeout: .now() + timeout)
        let timedOut = completed == .timedOut

        if timedOut {
            process.terminate()
            _ = completionGroup.wait(timeout: .now() + 1)
        }

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        return CommandResult(
            exitCode: timedOut ? 124 : process.terminationStatus,
            standardOutput: String(data: stdoutData, encoding: .utf8) ?? "",
            standardError: String(data: stderrData, encoding: .utf8) ?? "",
            timedOut: timedOut
        )
    }
}
