//
//  HeartRateChartView.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//


import SwiftUI
import HealthKit
import Charts

struct HeartRateChartView: View {

    private let hk = HealthKitManager()

    @State private var dataPoints: [HealthDataPoint] = []
    @State private var avgBPM: Double = 0
    @State private var weeksBack: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {

                // Header
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.red)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Heart Rate")
                            .font(.system(size: 24, weight: .bold))

                        Text(weekRangeText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .animation(.easeInOut(duration: 0.3), value: weeksBack)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                // Navigation
                HStack(spacing: 16) {

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            weeksBack += 1
                        }
                        loadHeartRate()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.red.opacity(0.1)))
                    }

                    Text(weeksBack == 0 ? "This Week" : "\(weeksBack) week\(weeksBack == 1 ? "" : "s") ago")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)

                    Button {
                        if weeksBack > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                weeksBack -= 1
                            }
                            loadHeartRate()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(weeksBack > 0 ? .red : .gray.opacity(0.3))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(
                                    weeksBack > 0
                                    ? Color.red.opacity(0.1)
                                    : Color.gray.opacity(0.05)
                                )
                            )
                    }
                    .disabled(weeksBack == 0)
                }
                .padding(.horizontal)

                // Avg stat
                VStack(spacing: 4) {
                    Text(avgBPMText)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.red)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: avgBPM)

                    Text("avg bpm")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)

                // Chart
                if dataPoints.isEmpty {
                    Text("No data available")
                        .foregroundColor(.secondary)
                        .frame(height: 200)
                        .transition(.opacity)

                } else {

                    Chart {

                        ForEach(dataPoints) { point in
                            AreaMark(
                                x: .value("Day", point.date, unit: .day),
                                y: .value("BPM", point.value)
                            )
                            .foregroundStyle(.red.opacity(0.12))
                            .interpolationMethod(.catmullRom)
                        }

                        ForEach(dataPoints) { point in
                            LineMark(
                                x: .value("Day", point.date, unit: .day),
                                y: .value("BPM", point.value)
                            )
                            .foregroundStyle(.red)
                            .lineStyle(
                                StrokeStyle(
                                    lineWidth: 3,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }

                        ForEach(dataPoints) { point in
                            PointMark(
                                x: .value("Day", point.date, unit: .day),
                                y: .value("BPM", point.value)
                            )
                            .foregroundStyle(.red)
                            .symbolSize(30)
                        }
                    }
                    .chartYScale(domain: yDomain)
                    .frame(height: 220)
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // Refresh
                Button {
                    loadHeartRate()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                .padding(.bottom)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .onAppear { loadHeartRate() }
    }

    // MARK: Helpers

    private var avgBPMText: String {
        avgBPM == 0 ? "--" : String(format: "%.0f", avgBPM)
    }

    private var yDomain: ClosedRange<Double> {
        let vals = dataPoints.map { $0.value }
        guard let minVal = vals.min(),
              let maxVal = vals.max() else {
            return 40...120
        }

        let pad = Swift.max(5, (maxVal - minVal) * 0.35)
        return (minVal - pad)...(maxVal + pad)
    }

    private var weekRangeText: String {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date()))!
        let ws = cal.date(byAdding: .weekOfYear, value: -weeksBack, to: start)!
        let we = cal.date(byAdding: .day, value: 6, to: ws)!
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: ws)) - \(f.string(from: we))"
    }

    private func loadHeartRate() {

        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date()))!
        let ws = cal.date(byAdding: .weekOfYear, value: -weeksBack, to: start)!
        let we = cal.date(byAdding: .day, value: 7, to: ws)!

        withAnimation(.easeOut(duration: 0.15)) {
            dataPoints = []
        }

        hk.fetchDailyQuantity(
            id: .heartRate,
            unit: HKUnit.count().unitDivided(by: HKUnit.minute()),
            startDate: ws,
            endDate: we,
            options: .discreteAverage
        ) { points, error in

            if let error = error {
                print(error)
                return
            }

            withAnimation(.easeInOut(duration: 0.5).delay(0.15)) {
                dataPoints = points.filter { $0.value > 0 }
                avgBPM = dataPoints.map { $0.value }.reduce(0,+)
                        / Double(max(dataPoints.count,1))
            }
        }
    }
}
