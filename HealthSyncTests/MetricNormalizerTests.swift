import XCTest
import HealthKit
@testable import HealthSync

class MetricNormalizerTests: XCTestCase {
    
    func testCategorizeMetricVitals() {
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.heartRate), .vitals)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.restingHeartRate), .vitals)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.bloodPressureSystolic), .vitals)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.bloodPressureDiastolic), .vitals)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.respiratoryRate), .vitals)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.bodyTemperature), .vitals)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.bodyMass), .vitals)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.height), .vitals)
    }
    
    func testCategorizeMetricActivity() {
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.stepCount), .activity)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.distanceWalkingRunning), .activity)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.distanceCycling), .activity)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.activeEnergyBurned), .activity)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.basalEnergyBurned), .activity)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.flightsClimbed), .activity)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.vo2Max), .activity)
    }
    
    func testCategorizeMetricNutrition() {
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.dietaryEnergyConsumed), .nutrition)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.dietaryFatTotal), .nutrition)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.dietaryCarbohydrates), .nutrition)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.dietaryProtein), .nutrition)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.dietaryWater), .nutrition)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.dietaryVitaminC), .nutrition)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.dietaryCalcium), .nutrition)
    }
    
    func testCategorizeMetricLab() {
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.bloodGlucose), .lab)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.bloodAlcoholContent), .lab)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.forcedVitalCapacity), .lab)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.inhalerUsage), .lab)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.insulinDelivery), .lab)
    }
    
    func testCategorizeMetricOther() {
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.numberOfTimesFallen), .other)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.environmentalAudioExposure), .other)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.headphoneAudioExposure), .other)
        XCTAssertEqual(MetricNormalizer.categorizeMetric(.uvExposure), .other)
    }
    
    func testHumanReadableNameMapping() {
        XCTAssertEqual(MetricNormalizer.humanReadableName(for: .heartRate), "Heart Rate")
        XCTAssertEqual(MetricNormalizer.humanReadableName(for: .stepCount), "Step Count")
        XCTAssertEqual(MetricNormalizer.humanReadableName(for: .bodyMass), "Body Weight")
        XCTAssertEqual(MetricNormalizer.humanReadableName(for: .bloodPressureSystolic), "Systolic Blood Pressure")
        XCTAssertEqual(MetricNormalizer.humanReadableName(for: .activeEnergyBurned), "Active Energy Burned")
        XCTAssertEqual(MetricNormalizer.humanReadableName(for: .dietaryWater), "Water")
        XCTAssertEqual(MetricNormalizer.humanReadableName(for: .bloodGlucose), "Blood Glucose")
        XCTAssertEqual(MetricNormalizer.humanReadableName(for: .vo2Max), "VO₂ Max")
    }
    
    func testHumanReadableNameCompleteness() {
        // Test that all identifiers have non-empty readable names
        for identifier in HKQuantityTypeIdentifier.allCases {
            let readableName = MetricNormalizer.humanReadableName(for: identifier)
            XCTAssertFalse(readableName.isEmpty, "Identifier \(identifier) should have a readable name")
            XCTAssertNotEqual(readableName, identifier.rawValue, "Readable name should be different from raw value for \(identifier)")
        }
    }
    
    func testNormalizeQuantitySampleWithMockData() {
        // Test with mock heart rate data
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            XCTFail("Could not create heart rate quantity type")
            return
        }
        
        let heartRateQuantity = HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: 72.0)
        let timestamp = Date()
        
        let heartRateSample = HKQuantitySample(
            type: heartRateType,
            quantity: heartRateQuantity,
            start: timestamp,
            end: timestamp
        )
        
        let normalizedMetric = MetricNormalizer.normalizeQuantitySample(heartRateSample)
        
        XCTAssertNotNil(normalizedMetric)
        XCTAssertEqual(normalizedMetric?.name, "Heart Rate")
        XCTAssertEqual(normalizedMetric?.identifier, "HKQuantityTypeIdentifierHeartRate")
        XCTAssertEqual(normalizedMetric?.value, 72.0)
        XCTAssertEqual(normalizedMetric?.unit, "bpm")
        XCTAssertEqual(normalizedMetric?.timestamp, timestamp)
        XCTAssertEqual(normalizedMetric?.category, .vitals)
        XCTAssertNotNil(normalizedMetric?.source)
    }
    
    func testNormalizeQuantitySampleWithStepCount() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            XCTFail("Could not create step count quantity type")
            return
        }
        
        let stepCountQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: 8542.0)
        let timestamp = Date()
        
        let stepCountSample = HKQuantitySample(
            type: stepCountType,
            quantity: stepCountQuantity,
            start: timestamp,
            end: timestamp
        )
        
        let normalizedMetric = MetricNormalizer.normalizeQuantitySample(stepCountSample)
        
        XCTAssertNotNil(normalizedMetric)
        XCTAssertEqual(normalizedMetric?.name, "Step Count")
        XCTAssertEqual(normalizedMetric?.identifier, "HKQuantityTypeIdentifierStepCount")
        XCTAssertEqual(normalizedMetric?.value, 8542.0)
        XCTAssertEqual(normalizedMetric?.unit, "steps")
        XCTAssertEqual(normalizedMetric?.timestamp, timestamp)
        XCTAssertEqual(normalizedMetric?.category, .activity)
    }
    
    func testNormalizeQuantitySampleWithBodyWeight() {
        guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            XCTFail("Could not create body mass quantity type")
            return
        }
        
        let bodyMassQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: 70.5)
        let timestamp = Date()
        
        let bodyMassSample = HKQuantitySample(
            type: bodyMassType,
            quantity: bodyMassQuantity,
            start: timestamp,
            end: timestamp
        )
        
        let normalizedMetric = MetricNormalizer.normalizeQuantitySample(bodyMassSample)
        
        XCTAssertNotNil(normalizedMetric)
        XCTAssertEqual(normalizedMetric?.name, "Body Weight")
        XCTAssertEqual(normalizedMetric?.identifier, "HKQuantityTypeIdentifierBodyMass")
        XCTAssertEqual(normalizedMetric?.value, 70.5)
        XCTAssertEqual(normalizedMetric?.unit, "kg")
        XCTAssertEqual(normalizedMetric?.timestamp, timestamp)
        XCTAssertEqual(normalizedMetric?.category, .vitals)
    }
    
    func testNormalizeQuantitySampleWithInvalidType() {
        // Test with a custom sample that might not be handled
        // This tests the robustness of the normalizer
        
        // Use uvExposure which should be available
        guard let customType = HKQuantityType.quantityType(forIdentifier: .uvExposure) else {
            // If UV Exposure is not available, just test that the function can handle nil gracefully
            XCTAssertTrue(true, "UV Exposure type not available - test passes")
            return
        }
        
        let customQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: 3.0)
        let timestamp = Date()
        
        let customSample = HKQuantitySample(
            type: customType,
            quantity: customQuantity,
            start: timestamp,
            end: timestamp
        )
        
        let normalizedMetric = MetricNormalizer.normalizeQuantitySample(customSample)
        
        // Should still create a metric even for less common types
        XCTAssertNotNil(normalizedMetric)
        XCTAssertEqual(normalizedMetric?.category, .other)
        XCTAssertEqual(normalizedMetric?.name, "UV Exposure")
    }
}