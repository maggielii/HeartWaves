//
//  GeminiClient.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//


import Foundation

final class GeminiClient {

    private let apiKey: String
    init(apiKey: String) { self.apiKey = apiKey }

    func getInsights(payloadJSON: String) async throws -> String {

        // You can switch model to whatever your Gemini account supports.
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)")!

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt =
        """
        You are a health analytics assistant. Analyze the provided daily aggregated metric.

        Requirements:
        - Identify trends (up/down/flat), week-over-week change, and variability.
        - Identify maximums and mininums and state them. 
        - Flag outliers and give plausible NON-medical explanations (workout, travel, missed wear, logging gaps).
        - If data quality is poor (lots of zeros/missing), say so.
        - Output EXACTLY in this format:

        
        Data (JSON):
        \(payloadJSON)
        """

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.35,
                "maxOutputTokens": 1000
            ]
        ]

        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw NSError(domain: "Gemini", code: -1, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
        }
        guard http.statusCode == 200 else {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "Gemini", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: raw])
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let candidates = json?["candidates"] as? [[String: Any]]
        let content = candidates?.first?["content"] as? [String: Any]
        let parts = content?["parts"] as? [[String: Any]]
        let text = parts?.first?["text"] as? String
        return text ?? "No insight text returned."
    }
}
