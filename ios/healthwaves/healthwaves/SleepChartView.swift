//
//  SleepChartView.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//

import SwiftUI
import HealthKit
import Charts

struct SleepChartView: View {
    private let hk = HealthKitManager()
    @State private var sleepData: [SleepDataPoint] = []
    @State private var totalSleep: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sleep - Last 7 Days")
                .font(.headline)
            
            Text("\(String(format: "%.1f", totalSleep)) hours avg")
                .font(.title2)
                .foregroundColor(.purple)
            
            if sleepData.isEmpty {
                Text("No sleep data available")
                    .foregroundColor(.secondary)
            } else {
                Chart(sleepData) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.startDate, unit: .day),
                        y: .value("Hours", dataPoint.durationInHours)
                    )
                    .foregroundStyle(colorForSleepStage(dataPoint.value))
                }
                .frame(height: 200)
                .padding()
            }
            
            Button("Refresh") {
                loadSleepData()
            }
        }
        .padding()
        .onAppear {
            loadSleepData()
        }
    }
    
    private func loadSleepData() {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        
        hk.fetchSleepData(startDate: startDate, endDate: endDate) { data, error in
            if let error = error {
                print("Sleep fetch error: \(error)")
            } else {
                sleepData = data
                calculateTotalSleep()
            }
        }
    }
    
    private func calculateTotalSleep() {
        let totalSeconds = sleepData.reduce(0) { $0 + $1.duration }
        let days = sleepData.isEmpty ? 1 : 7
        totalSleep = (totalSeconds / 3600) / Double(days)
    }
    
    private func colorForSleepStage(_ stage: HKCategoryValueSleepAnalysis) -> Color {
        switch stage {
        case .asleepCore, .asleepUnspecified, .inBed:
            return .purple
        case .asleepDeep:
            return .indigo
        case .asleepREM:
            return .blue
        case .awake:
            return .orange
        @unknown default:
            return .gray
        }
    }
}
