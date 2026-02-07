import HealthKit

final class HealthKitManager {
    private let store = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, "Health data not available on this device")
            return
        }

        guard let steps = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false, "StepCount type not available")
            return
        }

        store.requestAuthorization(toShare: [], read: [steps]) { success, error in
            DispatchQueue.main.async {
                completion(success, error?.localizedDescription ?? "OK")
            }
        }
    }

    func fetchTodaySteps(completion: @escaping (Double, String?) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0, "StepCount type not available")
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepsType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, result, error in
            let sum = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            DispatchQueue.main.async {
                completion(sum, error?.localizedDescription)
            }
        }

        store.execute(query)
    }
}
