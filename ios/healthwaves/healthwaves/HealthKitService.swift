//
//  HealthKitService.swift
//  healthwaves
//
//  Created by Sophia Xu on 2026-02-07.
//
import HealthKit

import HealthKit

final class HealthKitService {
    private let store = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, "Health data not available on this device")
            return
        }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!

        store.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true, "OK")
                } else {
                    completion(false, error?.localizedDescription ?? "User denied / unknown error")
                }
            }
        }
    }
}


