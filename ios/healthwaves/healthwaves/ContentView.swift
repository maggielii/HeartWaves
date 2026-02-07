//
//  ContentView.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var symptoms: String = ""
    @State private var healthSummary: String = "Health data will appear here."

    private let healthKitManager = HealthKitManager()

    var body: some View {
        VStack {
            // HealthKit Summary Section
            Text("Health Summary")
                .font(.headline)
            Text(healthSummary)
                .padding()

            // Symptom Input Section
            Text("Enter Your Symptoms")
                .font(.headline)
            TextEditor(text: $symptoms)
                .frame(height: 150)
                .border(Color.gray, width: 1)
                .padding()

            // Generate PDF Button
            Button(action: generatePDF) {
                Text("Generate PDF Summary")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onAppear(perform: setupHealthKit)
    }

    func setupHealthKit() {
        healthKitManager.requestAuthorization { success in
            if success {
                healthKitManager.fetchHealthData { summary in
                    DispatchQueue.main.async {
                        healthSummary = summary
                    }
                }
            } else {
                DispatchQueue.main.async {
                    healthSummary = "Authorization failed."
                }
            }
        }
    }

    func generatePDF() {
        // Placeholder for PDF generation logic
        print("PDF generation triggered")
    }
}

#Preview {
    ContentView()
}
