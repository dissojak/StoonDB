import SwiftUI

struct ControlPanelView: View {
    @StateObject private var viewModel = ControlPanelViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Local Development Control Panel")
                .font(.headline)

            HStack {
                Text("MySQL Status")
                Spacer()
                Text(viewModel.mysqlState.rawValue)
                    .fontWeight(.semibold)
                    .foregroundStyle(stateColor)
            }

            VStack(spacing: 8) {
                actionButton("Start MySQL") {
                    viewModel.runMySQLAction(.start)
                }

                actionButton("Stop MySQL") {
                    viewModel.runMySQLAction(.stop)
                }

                actionButton("Restart MySQL") {
                    viewModel.runMySQLAction(.restart)
                }

                actionButton("Open phpMyAdmin") {
                    viewModel.openPhpMyAdmin()
                }
            }

            if viewModel.isBusy {
                ProgressView("Running command...")
                    .controlSize(.small)
            }

            Text(viewModel.statusMessage)
                .font(.callout)

            GroupBox("Last Command Output") {
                ScrollView {
                    Text(viewModel.lastOutput.isEmpty ? "No output." : viewModel.lastOutput)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 11, design: .monospaced))
                        .textSelection(.enabled)
                }
                .frame(height: 110)
            }
        }
        .padding(16)
        .frame(width: 420, height: 420)
        .onAppear {
            viewModel.loadInitialState()
        }
    }

    private var stateColor: Color {
        switch viewModel.mysqlState {
        case .running:
            return .green
        case .stopped:
            return .orange
        case .unknown:
            return .secondary
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isBusy)
    }
}
