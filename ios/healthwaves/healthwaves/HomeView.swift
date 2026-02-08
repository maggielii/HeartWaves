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
    @State private var heartRateText = "--"
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                Text("Today's Summary")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        HealthCard(
                            icon: "figure.walk",
                            title: "Steps",
                            value: stepsText,
                            unit: "",
                            color: .blue
                        )
                        HealthCard(
                            icon: "figure.walk",
                            title: "Distance",
                            value: distanceText,
                            unit: "km",
                            color: .blue
                        )
                        HealthCard(
                            icon: "figure.walk",
                            title: "Energy",
                            value: energyText,
                            unit: "kcal",
                            color: .blue
                        )
                        HealthCard(
                            icon: "waveform.path.ecg",
                            title: "Heart Rate",
                            value: heartRateText,
                            unit: "bpm",
                            color: .blue
                        )
                    }
                    
                }
                StepsChartView()
                RestingHRChartView()
                SleepTimelineView()
                ExerciseMinutesChartView()
                EnergyHeatmapView()
                HeartRateChartView()
                InsightsCardView()

                
                
                
                
                
                
                
                
                Button("Refresh Steps") {
                    loadSteps()
                    loadDistance()
                    loadActiveEnergy()
                    loadHeartRate()
                }
            }
            .padding()
            .onAppear( perform: {loadSteps(); loadDistance(); loadActiveEnergy(); loadHeartRate()} )
        }
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
    
    private func loadHeartRate() {
        hk.fetchTodayDiscrete(id: .heartRate, unit: .count().unitDivided(by: .minute()), completion: { heartrate, error in
            if let error = error {
                status = "❌ Step fetch failed: \(error)"
                heartRateText = "--"
            } else {
                status = "✅ Steps loaded"
                heartRateText = String(Int(heartrate))
            }
            
        }
        )
    }
    
    
}
