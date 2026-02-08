//
//  InsightsCardView.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//


import SwiftUI

struct InsightsCardView: View {

    @StateObject private var vm = InsightsViewModel(apiKey: "<YOUR_GEMINI_API_KEY>")

    var body: some View {
        VStack(spacing: 16) {

            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Insights")
                        .font(.system(size: 22, weight: .bold))
                    Text("Active Energy (28 days)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            ScrollView {
                Text(vm.insightText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
            }
            .frame(height: 160)

            Button {
                vm.analyzeActiveEnergyLast28Days()
            } label: {
                HStack {
                    Image(systemName: vm.isLoading ? "hourglass" : "sparkles")
                    Text(vm.isLoading ? "Analyzing..." : "Analyze")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.purple)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.12))
                )
            }
            .disabled(vm.isLoading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}
