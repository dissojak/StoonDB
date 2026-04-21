import Foundation

enum MySQLAction: String {
    case start
    case stop
    case restart

    var label: String {
        switch self {
        case .start:
            return "Start MySQL"
        case .stop:
            return "Stop MySQL"
        case .restart:
            return "Restart MySQL"
        }
    }
}

enum MySQLServiceState: String {
    case running = "Running"
    case stopped = "Stopped"
    case unknown = "Unknown"
}

struct MySQLActionResult {
    let success: Bool
    let message: String
    let details: String
    let state: MySQLServiceState
}

actor MySQLServiceController {
    private let runner: ShellCommandRunner

    init(runner: ShellCommandRunner = ShellCommandRunner()) {
        self.runner = runner
    }

    func perform(_ action: MySQLAction) async -> MySQLActionResult {
        guard let brewPath = await findBrewExecutable() else {
            return MySQLActionResult(
                success: false,
                message: "Homebrew is not available on this machine.",
                details: "Expected command: brew services \(action.rawValue) mysql",
                state: .unknown
            )
        }

        let result = await runner.run(
            executable: brewPath,
            arguments: ["services", action.rawValue, "mysql"],
            timeout: 20
        )
        let state = await queryState()

        if result.succeeded {
            let details = result.combinedOutput.isEmpty ? "Command completed successfully." : result.combinedOutput
            return MySQLActionResult(
                success: true,
                message: "\(action.label) succeeded.",
                details: details,
                state: state
            )
        }

        if result.timedOut {
            return MySQLActionResult(
                success: false,
                message: "\(action.label) timed out.",
                details: "brew services \(action.rawValue) mysql exceeded the time limit.",
                state: state
            )
        }

        let details = result.combinedOutput.isEmpty
            ? "Command failed with exit code \(result.exitCode)."
            : result.combinedOutput
        return MySQLActionResult(
            success: false,
            message: "\(action.label) failed.",
            details: details,
            state: state
        )
    }

    func queryState() async -> MySQLServiceState {
        guard let brewPath = await findBrewExecutable() else {
            return .unknown
        }

        let result = await runner.run(
            executable: brewPath,
            arguments: ["services", "list"],
            timeout: 8
        )
        guard result.succeeded else {
            return .unknown
        }

        return Self.parseState(from: result.standardOutput)
    }

    private func findBrewExecutable() async -> String? {
        let knownPaths = [
            "/opt/homebrew/bin/brew",
            "/usr/local/bin/brew"
        ]

        for path in knownPaths where FileManager.default.isExecutableFile(atPath: path) {
            return path
        }

        let whichResult = await runner.run(
            executable: "/usr/bin/env",
            arguments: ["which", "brew"],
            timeout: 3
        )
        guard whichResult.succeeded else {
            return nil
        }

        let path = whichResult.standardOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        return path.isEmpty ? nil : path
    }

    private static func parseState(from output: String) -> MySQLServiceState {
        let lines = output.split(separator: "\n")

        for line in lines {
            let columns = line.split(whereSeparator: { $0.isWhitespace })
            guard columns.count >= 2 else {
                continue
            }

            let formula = String(columns[0]).lowercased()
            guard formula == "mysql" || formula.hasPrefix("mysql@") else {
                continue
            }

            let status = String(columns[1]).lowercased()
            if status == "started" {
                return .running
            }

            if status == "stopped" || status == "none" || status == "error" {
                return .stopped
            }
        }

        return .unknown
    }
}
