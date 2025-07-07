import Foundation
import HealthKit

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case authorizationFailed
    case queryFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationFailed:
            return "HealthKit authorization failed"
        case .queryFailed:
            return "Failed to query health data"
        case .invalidData:
            return "Invalid health data received"
        }
    }
}

@MainActor
class HealthKitManager: @unchecked Sendable {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private var _isAuthorized = false
    
    var isAuthorized: Bool {
        return _isAuthorized
    }
    
    private init() {}
    
    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        // Get all readable quantity types
        let allTypes = HKQuantityType.allQuantityTypes()
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: allTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                Task { @MainActor in
                    self._isAuthorized = success
                }
                continuation.resume(returning: success)
            }
        }
    }
    
    func fetchAvailableDataTypes() -> [HKQuantityTypeIdentifier] {
        guard _isAuthorized else { return [] }
        
        return HKQuantityTypeIdentifier.allCases.filter { identifier in
            guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
                return false
            }
            
            let authStatus = healthStore.authorizationStatus(for: quantityType)
            return authStatus == .sharingAuthorized
        }
    }
    
    func fetchSamples(for typeIdentifier: HKQuantityTypeIdentifier, startDate: Date, endDate: Date) async throws -> [HKSample] {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            throw HealthKitError.invalidData
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: samples ?? [])
            }
            
            healthStore.execute(query)
        }
    }
    
    func getAuthorizationStatus(for typeIdentifier: HKQuantityTypeIdentifier) -> HKAuthorizationStatus {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            return .notDetermined
        }
        
        return healthStore.authorizationStatus(for: quantityType)
    }
    
    var authorizationStatus: Bool {
        return isAuthorized
    }
}

extension HKQuantityType {
    static func allQuantityTypes() -> Set<HKQuantityType> {
        return Set(HKQuantityTypeIdentifier.allCases.compactMap { identifier in
            HKQuantityType.quantityType(forIdentifier: identifier)
        })
    }
}

extension HKQuantityTypeIdentifier: @retroactive CaseIterable {
    public static var allCases: [HKQuantityTypeIdentifier] {
        return [
            // Body Measurements
            .bodyMassIndex,
            .bodyFatPercentage,
            .height,
            .bodyMass,
            .leanBodyMass,
            .waistCircumference,
            
            // Fitness
            .stepCount,
            .distanceWalkingRunning,
            .distanceCycling,
            .distanceWheelchair,
            .basalEnergyBurned,
            .activeEnergyBurned,
            .flightsClimbed,
            .nikeFuel,
            .appleExerciseTime,
            .pushCount,
            .distanceSwimming,
            .swimmingStrokeCount,
            .vo2Max,
            .distanceDownhillSnowSports,
            
            // Vitals
            .heartRate,
            .bodyTemperature,
            .basalBodyTemperature,
            .bloodPressureSystolic,
            .bloodPressureDiastolic,
            .respiratoryRate,
            .restingHeartRate,
            .walkingHeartRateAverage,
            .heartRateVariabilitySDNN,
            .oxygenSaturation,
            .peripheralPerfusionIndex,
            .bloodGlucose,
            .numberOfTimesFallen,
            .electrodermalActivity,
            .inhalerUsage,
            .insulinDelivery,
            .bloodAlcoholContent,
            .forcedVitalCapacity,
            .forcedExpiratoryVolume1,
            .peakExpiratoryFlowRate,
            .environmentalAudioExposure,
            .headphoneAudioExposure,
            
            // Nutrition
            .dietaryFatTotal,
            .dietaryFatPolyunsaturated,
            .dietaryFatMonounsaturated,
            .dietaryFatSaturated,
            .dietaryCholesterol,
            .dietarySodium,
            .dietaryCarbohydrates,
            .dietaryFiber,
            .dietarySugar,
            .dietaryEnergyConsumed,
            .dietaryProtein,
            .dietaryVitaminA,
            .dietaryVitaminB6,
            .dietaryVitaminB12,
            .dietaryVitaminC,
            .dietaryVitaminD,
            .dietaryVitaminE,
            .dietaryVitaminK,
            .dietaryCalcium,
            .dietaryIron,
            .dietaryThiamin,
            .dietaryRiboflavin,
            .dietaryNiacin,
            .dietaryFolate,
            .dietaryBiotin,
            .dietaryPantothenicAcid,
            .dietaryPhosphorus,
            .dietaryIodine,
            .dietaryMagnesium,
            .dietaryZinc,
            .dietarySelenium,
            .dietaryCopper,
            .dietaryManganese,
            .dietaryChromium,
            .dietaryMolybdenum,
            .dietaryChloride,
            .dietaryPotassium,
            .dietaryCaffeine,
            .dietaryWater,
            
            // UV Exposure
            .uvExposure
        ]
    }
}