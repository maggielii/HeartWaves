import SwiftUI

struct ContentView: View {
    private let hk = HealthKitManager()

    @State private var status = "Not connected"
    @State private var stepsText = "--"

    var body: some View {
        VStack(spacing: 16) {
            Text(status)
            Text("Today’s steps: \(stepsText)")
                .font(.title2)

            Button("Connect Health") {
                hk.requestAuthorization { success, message in
                    status = success ? "✅ Authorized" : "❌ Not authorized: \(message)"
                    if success {
                        loadSteps()
                    }
                }
            }

            Button("Refresh Steps") {
                loadSteps()
            }
        }
        .padding()
    }

    private func loadSteps() {
        hk.fetchTodaySteps { steps, error in
            if let error = error {
                status = "❌ Step fetch failed: \(error)"
                stepsText = "--"
            } else {
                status = "✅ Steps loaded"
                stepsText = String(Int(steps))
            }
        }
    }
}
