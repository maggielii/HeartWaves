import SwiftUI
import HealthKit

struct ContentView: View {
    private let hk = HealthKitManager()

    @State private var status = "Not connected"
    @State private var stepsText = "--"
    @State private var distanceText = "--"
    @State private var energyText = "--"

    var body: some View {
        VStack(spacing: 16) {
            Text(status)
            Text("Today’s steps: \(stepsText)")
                .font(.title2)
            Text("Today’s distance: \(distanceText)")
                .font(.title2)
            Text("Today’s acgive energy: \(energyText)")
                .font(.title2)

            Button("Connect Health") {
                hk.requestAuthorization { success, message in
                    status = success ? "✅ Authorized" : "❌ Not authorized: \(message)"
                    if success {
                        HomeView()
                            .transition(.opacity)
                            .ignoresSafeArea()
    
                    }
                }
            }

        }
        .padding()
    }

    
}
