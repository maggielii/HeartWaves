//
//  InsightsViewModel.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//


import Foundation
import HealthKit
import Combine


@MainActor
final class InsightsViewModel: ObservableObject {

    @Published var insightText: String = "Tap Analyze to generate insights."
    @Published var isLoading: Bool = false

    private let hk = HealthKitManager()
    private let gemini: GeminiClient

    init(apiKey: String) {
        self.gemini = GeminiClient(apiKey: Secrets.geminiKey)
    }

    func analyzeActiveEnergyLast28Days() {
        isLoading = true
        insightText = "Analyzing..."

        let cal = Calendar.current
        let end = Date()
        let start = cal.date(byAdding: .day, value: -28, to: end)!

        hk.fetchDailyQuantity(
            id: .activeEnergyBurned,
            unit: .kilocalorie(),
            startDate: start,
            endDate: end,
            options: .cumulativeSum
        ) { [weak self] points, error in
            guard let self else { return }

            if let error = error {
                self.isLoading = false
                self.insightText = "HealthKit error: \(error)"
                return
            }

            // Fill missing days so the model can reason about zeros vs missing
            let filled = self.hk.fillMissingDays(points: points, startDate: start, endDate: end)

            let payload = Analytics.buildPayload(
                metric: "Active Energy",
                unit: "kcal",
                start: start,
                end: end,
                points: filled
            )

            do {
                let data = try JSONEncoder().encode(payload)
                let payloadJSON = String(data: data, encoding: .utf8) ?? "{}"

                Task {
                    do {
                        let text = try await self.gemini.getInsights(payloadJSON: payloadJSON)
                        self.insightText = text
                        self.isLoading = false
                    } catch {
                        self.insightText = "Gemini error: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            } catch {
                self.isLoading = false
                self.insightText = "Encoding error: \(error.localizedDescription)"
            }
        }
    }
}
