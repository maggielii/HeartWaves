import Foundation

struct InsightPayload: Codable {
    let metric: String
    let unit: String
    let startISO: String
    let endISO: String
    let daily: [DailyPoint]
    let summary: Summary
}

struct DailyPoint: Codable {
    let dateISO: String
    let value: Double
}

struct Summary: Codable {
    let mean: Double
    let stdDev: Double
    let min: Double
    let max: Double
    let last7Avg: Double?
    let prev7Avg: Double?
    let weekOverWeekPct: Double?
    let outliers: [Outlier]
    let missingDays: Int
}

struct Outlier: Codable {
    let dateISO: String
    let value: Double
    let z: Double
}

enum Analytics {
    static func buildPayload(
        metric: String,
        unit: String,
        start: Date,
        end: Date,
        points: [HealthDataPoint]
    ) -> InsightPayload {

        let iso = ISO8601DateFormatter()

        let sorted = points.sorted { $0.date < $1.date }
        let daily = sorted.map { DailyPoint(dateISO: iso.string(from: $0.date), value: $0.value) }

        let values = sorted.map(\.value)
        let mean = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        let variance = values.isEmpty ? 0 : values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        let std = sqrt(variance)
        let minV = values.min() ?? 0
        let maxV = values.max() ?? 0

        func avg(_ arr: [Double]) -> Double? {
            guard !arr.isEmpty else { return nil }
            return arr.reduce(0, +) / Double(arr.count)
        }

        let last7 = values.count >= 7 ? avg(Array(values.suffix(7))) : nil
        let prev7 = values.count >= 14 ? avg(Array(values.suffix(14).prefix(7))) : nil
        let wowPct: Double? = {
            guard let l7 = last7, let p7 = prev7, p7 != 0 else { return nil }
            return (l7 - p7) / p7 * 100.0
        }()

        let outliers: [Outlier] = {
            guard std > 0 else { return [] }
            return sorted.map { p -> Outlier? in
                let z = (p.value - mean) / std
                return abs(z) >= 2.0 ? Outlier(dateISO: iso.string(from: p.date), value: p.value, z: z) : nil
            }.compactMap { $0 }
        }()

        // Missing day count (if you’re providing filled daily series, this will be 0)
        let missingDays = sorted.filter { $0.value == 0 }.count

        let summary = Summary(
            mean: mean,
            stdDev: std,
            min: minV,
            max: maxV,
            last7Avg: last7,
            prev7Avg: prev7,
            weekOverWeekPct: wowPct,
            outliers: outliers,
            missingDays: missingDays
        )

        return InsightPayload(
            metric: metric,
            unit: unit,
            startISO: iso.string(from: start),
            endISO: iso.string(from: end),
            daily: daily,
            summary: summary
        )
        
        
    }
    
    static func buildBackendRequest(
        metric: String,
        unit: String,
        start: Date,
        end: Date,
        points: [HealthDataPoint]
    ) -> BackendMetricRequest {

        let iso = ISO8601DateFormatter()
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "yyyy-MM-dd"
        dayFmt.locale = Locale(identifier: "en_US_POSIX")
        dayFmt.timeZone = .current

        let daily = points.map {
            BackendMetricRequest.Daily(dateISO: dayFmt.string(from: $0.date), value: $0.value)
        }

        return BackendMetricRequest(
            userId: nil,
            metric: metric,
            unit: unit,
            startISO: iso.string(from: start),
            endISO: iso.string(from: end),
            daily: daily
        )
    }

}

func buildBackendRequestForHR(
    points: [HealthDataPoint],
    start: Date,
    end: Date
) -> BackendMetricRequest {

    let iso = ISO8601DateFormatter()

    let dayFmt = DateFormatter()
    dayFmt.dateFormat = "yyyy-MM-dd"
    dayFmt.locale = Locale(identifier: "en_US_POSIX")
    dayFmt.timeZone = .current

    let daily = points.map {
        BackendMetricRequest.Daily(
            dateISO: dayFmt.string(from: $0.date),
            value: $0.value
        )
    }

    return BackendMetricRequest(
        userId: nil,
        metric: "heartRate",
        unit: "bpm",
        startISO: iso.string(from: start),
        endISO: iso.string(from: end),
        daily: daily
    )
}

