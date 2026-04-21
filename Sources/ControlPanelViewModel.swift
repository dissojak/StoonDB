import Foundation

@MainActor
final class ControlPanelViewModel: ObservableObject {
    @Published var isBusy = false
    @Published var mysqlState: MySQLServiceState = .unknown
    @Published var statusMessage = "Ready."
    @Published var lastOutput = ""

    private let mysqlController: MySQLServiceController
    private let phpMyAdminLauncher: PhpMyAdminLauncher

    init(
        mysqlController: MySQLServiceController = MySQLServiceController(),
        phpMyAdminLauncher: PhpMyAdminLauncher = PhpMyAdminLauncher()
    ) {
        self.mysqlController = mysqlController
        self.phpMyAdminLauncher = phpMyAdminLauncher
    }

    func loadInitialState() {
        Task {
            let state = await mysqlController.queryState()
            mysqlState = state
            statusMessage = "MySQL state loaded."
        }
    }

    func runMySQLAction(_ action: MySQLAction) {
        guard !isBusy else {
            return
        }

        isBusy = true
        statusMessage = "\(action.label)..."
        lastOutput = ""

        Task {
            let result = await mysqlController.perform(action)
            mysqlState = result.state
            statusMessage = result.message
            lastOutput = result.details
            isBusy = false
        }
    }

    func openPhpMyAdmin() {
        let result = phpMyAdminLauncher.openInBrowser()
        if result.success {
            statusMessage = result.message
            lastOutput = ""
        } else {
            statusMessage = "Open phpMyAdmin failed."
            lastOutput = result.message
        }
    }
}
