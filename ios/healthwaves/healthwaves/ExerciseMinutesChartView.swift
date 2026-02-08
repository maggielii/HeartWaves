//
//  ExerciseMinutesChartView.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//

import SwiftUI
import Foundation
import Charts
import HealthKit


struct ExerciseMinutesChartView: View {
    private let hk = HealthKitManager()
    @State private var dataPoints: [HealthDataPoint] = []
    @State private var avgMinutes: Int = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Exercise Minutes - Last 7 Days")
                .font(.headline)
            
            Text("\(avgMinutes) avg min/day")
                .font(.title2)
                .foregroundColor(.green)
            
            if dataPoints.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
            } else {
                Chart(dataPoints) { point in
                    AreaMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Minutes", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Minutes", point.value)
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 200)
                .padding()
            }
            
            Button("Refresh") {
                loadExerciseMinutes()
            }
        }
        .padding()
        .onAppear {
            loadExerciseMinutes()
        }
    }
    
    private func loadExerciseMinutes() {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        
        // Break this into separate variables
        let id: HKQuantityTypeIdentifier = .appleExerciseTime
        let unit: HKUnit = .minute()
        
        hk.fetchSamples(
            id: id,
            unit: unit,
            startDate: startDate,
            endDate: endDate
        ) { points, error in
            if let error = error {
                print("Exercise fetch error: \(error)")
            } else {
                dataPoints = points
                avgMinutes = points.isEmpty ? 0 : Int(points.map { $0.value }.reduce(0, +) / Double(points.count))
            }
        }
    }
}
