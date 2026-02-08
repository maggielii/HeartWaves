//
//  BackendMetricRequest.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-08.
//


import Foundation

struct BackendMetricRequest: Codable {
    struct Daily: Codable {
        let dateISO: String
        let value: Double
    }

    let userId: String?
    let metric: String
    let unit: String
    let startISO: String
    let endISO: String
    let daily: [Daily]
}

struct BackendMetricResponse: Codable {
    struct Summary: Codable {
        let mean: Double
        let trend: String
        let weekOverWeekPct: Double?
    }
    struct Outlier: Codable {
        let dateISO: String
        let value: Double
        let z: Double
    }

    let metric: String
    let summary: Summary
    let outliers: [Outlier]
    let blurb: String
}

struct BackendBatchRequest: Codable {
    let userId: String?
    let startISO: String
    let endISO: String
    let metrics: [BackendMetricRequest]
}

struct BackendBatchResponse: Codable {
    let results: [BackendMetricResponse] // one response per metric
}


final class BackendClient {

    let baseURL: URL
    init(baseURL: URL) { self.baseURL = baseURL }

    func analyzeMetric(_ req: BackendMetricRequest) async throws -> BackendMetricResponse {
        let url = baseURL.appendingPathComponent("analyze")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(req)

        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "Backend", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: raw])
        }

        return try JSONDecoder().decode(BackendMetricResponse.self, from: data)
    }
    
    func analyzeBatch(_ req: BackendBatchRequest) async throws -> BackendBatchResponse {
        let url = baseURL.appendingPathComponent("analyze-batch")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(req)

        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "Backend", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: raw])
        }

        return try JSONDecoder().decode(BackendBatchResponse.self, from: data)
    }

    
    
}
