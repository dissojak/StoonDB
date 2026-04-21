import AppKit
import Foundation

struct PhpMyAdminLauncher {
    private let urlString: String

    init(urlString: String = "http://127.0.0.1:8080") {
        self.urlString = urlString
    }

    func openInBrowser() -> (success: Bool, message: String) {
        guard
            let url = URL(string: urlString),
            let scheme = url.scheme,
            scheme == "http" || scheme == "https"
        else {
            return (false, "Invalid phpMyAdmin URL: \(urlString)")
        }

        let opened = NSWorkspace.shared.open(url)
        if opened {
            return (true, "Opened \(url.absoluteString) in the default browser.")
        }

        return (false, "Could not open \(url.absoluteString) in the default browser.")
    }
}
