//
//  HomeView.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//

import SwiftUI
import HealthKit

struct HomeView: View {
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
            
            
            
            
            
            
            Button("Refresh Steps") {
                loadSteps()
                loadDistance()
                loadActiveEnergy()
            }
        }
        .padding()
        .onAppear( perform: {loadSteps(); loadDistance(); loadActiveEnergy()} )
    }
    
    
    private func loadSteps() {
        hk.fetchTodayGeneral(id: .stepCount, unit: .count(), completion: { steps, error in
            if let error = error {
                status = "❌ Step fetch failed: \(error)"
                stepsText = "--"
            } else {
                status = "✅ Steps loaded"
                stepsText = String(Int(steps))
            }
            
        }
        )
    }
    
    private func loadDistance() {
        hk.fetchTodayGeneral(id: .distanceWalkingRunning, unit: .meter(), completion: { distance, error in
            if let error = error {
                status = "❌ Step fetch failed: \(error)"
                distanceText = "--"
            } else {
                status = "✅ Steps loaded"
                distanceText = String(Int(distance))
            }
            
        }
        )
    }
    
    private func loadActiveEnergy() {
        hk.fetchTodayGeneral(id: .activeEnergyBurned, unit: .kilocalorie(), completion: { energy, error in
            if let error = error {
                status = "❌ Step fetch failed: \(error)"
                energyText = "--"
            } else {
                status = "✅ Steps loaded"
                energyText = String(Int(energy))
            }
            
        }
        )
    }
}
