import SwiftUI
import HealthKit

struct ContentView: View {
    private let hk = HealthKitManager()

    @State private var status = "Not connected"
    @State private var isAuthorized: Bool = false;
    

    var body: some View {
        VStack(spacing: 16) {
            if  (isAuthorized) {
                HomeView()
                    .transition(.opacity)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(status)
                Button("Connect Health") {
                    hk.requestAuthorization { success, message in
                        status = success ? "✅ Authorized" : "❌ Not authorized: \(message)"
                        if success {
                            isAuthorized = true;
        
                        }
                    }
                }
            }
            

        }
        .padding()
    }

    
}


