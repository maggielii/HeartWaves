//
//  SleepTimelineView.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//


import SwiftUI
import HealthKit
import Charts

struct SleepTimelineView: View {

    private let hk = HealthKitManager()

    @State private var segments: [SleepSegment] = []
    @State private var totalSleepSeconds: Double = 0
    @State private var weeksBack: Int = 0  // 0 = current week, 1 = last week, etc.

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {

                // Header
                HStack {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.indigo)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sleep")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)

                        Text(weekRangeText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .animation(.easeInOut(duration: 0.3), value: weeksBack)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                // Week navigation
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            weeksBack += 1
                        }
                        loadSleep()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.indigo)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.indigo.opacity(0.1)))
                    }

                    Text(weeksBack == 0 ? "This Week" : "\(weeksBack) week\(weeksBack == 1 ? "" : "s") ago")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.3), value: weeksBack)

                    Button {
                        if weeksBack > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                weeksBack -= 1
                            }
                            loadSleep()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(weeksBack > 0 ? .indigo : .gray.opacity(0.3))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(weeksBack > 0 ? Color.indigo.opacity(0.1) : Color.gray.opacity(0.05))
                            )
                    }
                    .disabled(weeksBack == 0)
                }
                .padding(.horizontal)

                // Total sleep stat
                VStack(spacing: 4) {
                    Text(totalSleepText)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.indigo)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: totalSleepSeconds)

                    Text("total asleep")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)

                // Timeline chart
                if segments.isEmpty {
                    Text("No sleep data available")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(height: 220)
                        .transition(.opacity)
                } else {
                    Chart(segments) { seg in
                        BarMark(
                            xStart: .value("Start", seg.start),
                            xEnd: .value("End", seg.end),
                            y: .value("Night", seg.night, unit: .day)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .foregroundStyle(seg.color)
                    }
                    .chartXScale(domain: chartDomain)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                                .foregroundStyle(Color.primary.opacity(0.06))
                            AxisTick()
                                .foregroundStyle(Color.secondary.opacity(0.25))
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(dayLabel(date))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                            AxisGridLine()
                                .foregroundStyle(Color.primary.opacity(0.06))
                            AxisTick()
                                .foregroundStyle(Color.secondary.opacity(0.25))
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(timeLabel(date))
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .frame(height: 240)
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // Refresh
                Button {
                    loadSleep()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Refresh")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.indigo)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.indigo.opacity(0.1))
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
        .onAppear { loadSleep() }
    }

    // MARK: - Date helpers

    private var weekRangeText: String {
        let cal = Calendar.current
        let startOfCurrentWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekStart = cal.date(byAdding: .weekOfYear, value: -weeksBack, to: startOfCurrentWeek)!
        let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart)!

        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: weekStart)) - \(f.string(from: weekEnd))"
    }

    private var chartDomain: ClosedRange<Date> {
        // Show a consistent “sleep window” that makes sense on a timeline:
        // from 6pm of the first day to 12pm of the last day.
        let cal = Calendar.current
        let startOfCurrentWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekStart = cal.date(byAdding: .weekOfYear, value: -weeksBack, to: startOfCurrentWeek)!
        let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart)! // exclusive end

        let domainStart = cal.date(bySettingHour: 18, minute: 0, second: 0, of: weekStart) ?? weekStart
        let domainEnd = cal.date(bySettingHour: 12, minute: 0, second: 0, of: weekEnd) ?? weekEnd
        return domainStart...domainEnd
    }

    private func dayLabel(_ date: Date) -> String {
        // “Mon”, “Tue”, ...
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    private func timeLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "ha" // 6PM, 12AM, 6AM...
        return f.string(from: date)
    }

    private var totalSleepText: String {
        let hours = totalSleepSeconds / 3600.0
        if totalSleepSeconds <= 0 { return "--" }
        if hours >= 10 { return String(format: "%.0f h", hours) }
        return String(format: "%.1f h", hours)
    }

    // MARK: - Loading / Transform

    private func loadSleep() {
        let cal = Calendar.current
        let startOfCurrentWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekStart = cal.date(byAdding: .weekOfYear, value: -weeksBack, to: startOfCurrentWeek)!
        let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart)! // exclusive end

        // Fade out
        withAnimation(.easeOut(duration: 0.15)) {
            segments = []
            totalSleepSeconds = 0
        }

        hk.fetchSleepData(startDate: weekStart, endDate: weekEnd) { samples, error in
            if let error = error {
                print("Sleep fetch error: \(error)")
                return
            }

            let transformed = makeSegments(from: samples, weekStart: weekStart, weekEnd: weekEnd)

            let asleepSeconds = transformed
                .filter { $0.isAsleep }
                .reduce(0.0) { $0 + $1.end.timeIntervalSince($1.start) }

            withAnimation(.easeInOut(duration: 0.5).delay(0.15)) {
                segments = transformed
                totalSleepSeconds = asleepSeconds
            }
        }
    }

    private func makeSegments(from samples: [SleepDataPoint], weekStart: Date, weekEnd: Date) -> [SleepSegment] {
        let cal = Calendar.current
        let domain = chartDomain

        func clamp(_ date: Date) -> Date {
            min(max(date, domain.lowerBound), domain.upperBound)
        }

        var out: [SleepSegment] = []

        for s in samples {
            // Keep only sleep-related entries; ignore “in bed” if you don’t want it
            // (if your data includes “inBed”, you can choose to show it as a faint color)
            let stage = SleepStage(from: s.value)

            // Assign each segment to the “wake day” (common UX): use endDate's day as the row.
            let night = cal.startOfDay(for: s.endDate)

            // Only include nights that fall within the requested week window (by row)
            guard night >= cal.startOfDay(for: weekStart), night < cal.startOfDay(for: weekEnd) else { continue }

            // Clamp segments to the visible domain so the chart stays readable
            let start = clamp(s.startDate)
            let end = clamp(s.endDate)
            guard end > start else { continue }

            out.append(
                SleepSegment(
                    id: UUID(),
                    night: night,
                    start: start,
                    end: end,
                    stage: stage
                )
            )
        }

        // Sort: top-to-bottom by day, left-to-right by time
        return out.sorted {
            if $0.night == $1.night { return $0.start < $1.start }
            return $0.night < $1.night
        }
    }
}

// MARK: - Segment model / stage mapping

private struct SleepSegment: Identifiable {
    let id: UUID
    let night: Date         // row grouping
    let start: Date
    let end: Date
    let stage: SleepStage

    var isAsleep: Bool { stage != .awake && stage != .unknown }

    var color: Color {
        switch stage {
        case .deep: return .purple
        case .core: return .blue
        case .rem: return .teal
        case .awake: return .orange
        case .asleepUnspecified: return .indigo
        case .inBed: return .gray.opacity(0.35)
        case .unknown: return .gray.opacity(0.25)
        }
    }
}

private enum SleepStage {
    case awake
    case rem
    case core
    case deep
    case asleepUnspecified
    case inBed
    case unknown

    init(from value: HKCategoryValueSleepAnalysis) {
        // iOS may provide either the newer “sleep stages” or older values.
        switch value {
        case .awake:
            self = .awake
        case .asleepREM:
            self = .rem
        case .asleepCore:
            self = .core
        case .asleepDeep:
            self = .deep
        case .asleepUnspecified:
            self = .asleepUnspecified
        case .inBed:
            self = .inBed
        @unknown default:
            self = .unknown
        }
    }
}
