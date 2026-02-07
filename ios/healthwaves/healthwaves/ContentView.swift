//
//  ContentView.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//

import SwiftUI

struct ContentView: View {
    let hk = HealthKitService()

    var body: some View {
        Button("Connect Health") {
            hk.requestAuthorization { success, message in
                   print(success)
                   print(message)
                    Text("connected")
               }
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}
