import Foundation
import HealthKit

class MetricNormalizer {
    
    // MARK: - Public Methods
    
    static func categorizeMetric(_ identifier: HKQuantityTypeIdentifier) -> MetricCategory {
        switch identifier {
        // Vitals
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage, .heartRateVariabilitySDNN,
             .bloodPressureSystolic, .bloodPressureDiastolic,
             .respiratoryRate, .bodyTemperature, .basalBodyTemperature,
             .oxygenSaturation, .peripheralPerfusionIndex,
             .bodyMass, .bodyMassIndex, .bodyFatPercentage, .leanBodyMass,
             .height, .waistCircumference:
            return .vitals
            
        // Activity
        case .stepCount, .distanceWalkingRunning, .distanceCycling, .distanceWheelchair,
             .basalEnergyBurned, .activeEnergyBurned, .flightsClimbed,
             .nikeFuel, .appleExerciseTime, .pushCount, .distanceSwimming,
             .swimmingStrokeCount, .vo2Max, .distanceDownhillSnowSports:
            return .activity
            
        // Nutrition
        case .dietaryFatTotal, .dietaryFatPolyunsaturated, .dietaryFatMonounsaturated,
             .dietaryFatSaturated, .dietaryCholesterol, .dietarySodium,
             .dietaryCarbohydrates, .dietaryFiber, .dietarySugar,
             .dietaryEnergyConsumed, .dietaryProtein, .dietaryVitaminA,
             .dietaryVitaminB6, .dietaryVitaminB12, .dietaryVitaminC,
             .dietaryVitaminD, .dietaryVitaminE, .dietaryVitaminK,
             .dietaryCalcium, .dietaryIron, .dietaryThiamin, .dietaryRiboflavin,
             .dietaryNiacin, .dietaryFolate, .dietaryBiotin, .dietaryPantothenicAcid,
             .dietaryPhosphorus, .dietaryIodine, .dietaryMagnesium, .dietaryZinc,
             .dietarySelenium, .dietaryCopper, .dietaryManganese, .dietaryChromium,
             .dietaryMolybdenum, .dietaryChloride, .dietaryPotassium,
             .dietaryCaffeine, .dietaryWater:
            return .nutrition
            
        // Lab Results
        case .bloodGlucose, .bloodAlcoholContent, .forcedVitalCapacity,
             .forcedExpiratoryVolume1, .peakExpiratoryFlowRate,
             .electrodermalActivity, .inhalerUsage, .insulinDelivery:
            return .lab
            
        // Other/Environmental
        case .numberOfTimesFallen, .environmentalAudioExposure,
             .headphoneAudioExposure, .uvExposure:
            return .other
            
        // Default fallback
        default:
            return .other
        }
    }
    
    static func normalizeQuantitySample(_ sample: HKQuantitySample) -> HealthMetric? {
        let typeIdentifier = sample.quantityType.identifier
        
        let hkIdentifier = HKQuantityTypeIdentifier(rawValue: typeIdentifier)
        
        let value = normalizedValue(for: sample)
        let unit = normalizedUnit(for: sample.quantityType)
        let name = humanReadableName(for: hkIdentifier)
        let category = categorizeMetric(hkIdentifier)
        let source = sample.sourceRevision.source.name
        
        return HealthMetric(
            name: name,
            identifier: typeIdentifier,
            value: value,
            unit: unit,
            timestamp: sample.startDate,
            category: category,
            source: source
        )
    }
    
    // MARK: - Private Helper Methods
    
    private static func normalizedValue(for sample: HKQuantitySample) -> Double {
        let type = sample.quantityType
        let identifier = HKQuantityTypeIdentifier(rawValue: type.identifier)
        
        switch identifier {
        // Heart Rate - beats per minute
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage:
            return sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            
        // Distance - meters
        case .distanceWalkingRunning, .distanceCycling, .distanceWheelchair, .distanceSwimming, .distanceDownhillSnowSports:
            return sample.quantity.doubleValue(for: HKUnit.meter())
            
        // Energy - kilocalories
        case .basalEnergyBurned, .activeEnergyBurned, .dietaryEnergyConsumed:
            return sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            
        // Weight/Mass - kilograms
        case .bodyMass, .leanBodyMass:
            return sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            
        // Height - meters
        case .height:
            return sample.quantity.doubleValue(for: HKUnit.meter())
            
        // Blood Pressure - mmHg
        case .bloodPressureSystolic, .bloodPressureDiastolic:
            return sample.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            
        // Temperature - Celsius
        case .bodyTemperature, .basalBodyTemperature:
            return sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
            
        // Percentages
        case .bodyFatPercentage, .oxygenSaturation:
            return sample.quantity.doubleValue(for: HKUnit.percent()) * 100
            
        // Blood Glucose - mg/dL
        case .bloodGlucose:
            return sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci)))
            
        // Steps - count
        case .stepCount, .flightsClimbed, .swimmingStrokeCount, .pushCount:
            return sample.quantity.doubleValue(for: HKUnit.count())
            
        // Volume - liters
        case .dietaryWater, .forcedVitalCapacity, .forcedExpiratoryVolume1:
            return sample.quantity.doubleValue(for: HKUnit.liter())
            
        // Mass - grams
        case .dietaryFatTotal, .dietaryFatPolyunsaturated, .dietaryFatMonounsaturated,
             .dietaryFatSaturated, .dietaryCholesterol, .dietarySodium,
             .dietaryCarbohydrates, .dietaryFiber, .dietarySugar, .dietaryProtein:
            return sample.quantity.doubleValue(for: HKUnit.gram())
            
        // Milligrams
        case .dietaryVitaminA, .dietaryVitaminB6, .dietaryVitaminB12, .dietaryVitaminC,
             .dietaryVitaminD, .dietaryVitaminE, .dietaryVitaminK, .dietaryCalcium,
             .dietaryIron, .dietaryThiamin, .dietaryRiboflavin, .dietaryNiacin,
             .dietaryFolate, .dietaryBiotin, .dietaryPantothenicAcid, .dietaryPhosphorus,
             .dietaryIodine, .dietaryMagnesium, .dietaryZinc, .dietarySelenium,
             .dietaryCopper, .dietaryManganese, .dietaryChromium, .dietaryMolybdenum,
             .dietaryChloride, .dietaryPotassium, .dietaryCaffeine:
            return sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .milli))
            
        // Time - minutes
        case .appleExerciseTime:
            return sample.quantity.doubleValue(for: HKUnit.minute())
            
        // Default - use count unit
        default:
            return sample.quantity.doubleValue(for: HKUnit.count())
        }
    }
    
    private static func normalizedUnit(for quantityType: HKQuantityType) -> String {
        let identifier = HKQuantityTypeIdentifier(rawValue: quantityType.identifier)
        
        switch identifier {
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage:
            return "bpm"
            
        case .distanceWalkingRunning, .distanceCycling, .distanceWheelchair,
             .distanceSwimming, .distanceDownhillSnowSports, .height:
            return "m"
            
        case .basalEnergyBurned, .activeEnergyBurned, .dietaryEnergyConsumed:
            return "kcal"
            
        case .bodyMass, .leanBodyMass:
            return "kg"
            
        case .bloodPressureSystolic, .bloodPressureDiastolic:
            return "mmHg"
            
        case .bodyTemperature, .basalBodyTemperature:
            return "°C"
            
        case .bodyFatPercentage, .oxygenSaturation:
            return "%"
            
        case .bloodGlucose:
            return "mg/dL"
            
        case .stepCount:
            return "steps"
            
        case .flightsClimbed:
            return "flights"
            
        case .swimmingStrokeCount:
            return "strokes"
            
        case .pushCount:
            return "pushes"
            
        case .dietaryWater, .forcedVitalCapacity, .forcedExpiratoryVolume1:
            return "L"
            
        case .dietaryFatTotal, .dietaryFatPolyunsaturated, .dietaryFatMonounsaturated,
             .dietaryFatSaturated, .dietaryCholesterol, .dietarySodium,
             .dietaryCarbohydrates, .dietaryFiber, .dietarySugar, .dietaryProtein:
            return "g"
            
        case .dietaryVitaminA, .dietaryVitaminB6, .dietaryVitaminB12, .dietaryVitaminC,
             .dietaryVitaminD, .dietaryVitaminE, .dietaryVitaminK, .dietaryCalcium,
             .dietaryIron, .dietaryThiamin, .dietaryRiboflavin, .dietaryNiacin,
             .dietaryFolate, .dietaryBiotin, .dietaryPantothenicAcid, .dietaryPhosphorus,
             .dietaryIodine, .dietaryMagnesium, .dietaryZinc, .dietarySelenium,
             .dietaryCopper, .dietaryManganese, .dietaryChromium, .dietaryMolybdenum,
             .dietaryChloride, .dietaryPotassium, .dietaryCaffeine:
            return "mg"
            
        case .appleExerciseTime:
            return "min"
            
        case .respiratoryRate:
            return "breaths/min"
            
        case .heartRateVariabilitySDNN:
            return "ms"
            
        case .waistCircumference:
            return "cm"
            
        case .bodyMassIndex:
            return "kg/m²"
            
        case .vo2Max:
            return "mL/kg⋅min"
            
        case .peripheralPerfusionIndex:
            return "index"
            
        case .bloodAlcoholContent:
            return "%"
            
        case .peakExpiratoryFlowRate:
            return "L/min"
            
        case .electrodermalActivity:
            return "µS"
            
        case .inhalerUsage, .insulinDelivery:
            return "units"
            
        case .numberOfTimesFallen:
            return "count"
            
        case .environmentalAudioExposure, .headphoneAudioExposure:
            return "dB"
            
        case .uvExposure:
            return "index"
            
        case .nikeFuel:
            return "NikeFuel"
            
        default:
            return ""
        }
    }
    
    static func humanReadableName(for typeIdentifier: HKQuantityTypeIdentifier) -> String {
        switch typeIdentifier {
        case .heartRate:
            return "Heart Rate"
        case .restingHeartRate:
            return "Resting Heart Rate"
        case .walkingHeartRateAverage:
            return "Walking Heart Rate Average"
        case .heartRateVariabilitySDNN:
            return "Heart Rate Variability"
        case .stepCount:
            return "Step Count"
        case .distanceWalkingRunning:
            return "Walking + Running Distance"
        case .distanceCycling:
            return "Cycling Distance"
        case .distanceWheelchair:
            return "Wheelchair Distance"
        case .basalEnergyBurned:
            return "Basal Energy Burned"
        case .activeEnergyBurned:
            return "Active Energy Burned"
        case .flightsClimbed:
            return "Flights Climbed"
        case .bodyMass:
            return "Body Weight"
        case .bodyMassIndex:
            return "Body Mass Index"
        case .bodyFatPercentage:
            return "Body Fat Percentage"
        case .leanBodyMass:
            return "Lean Body Mass"
        case .height:
            return "Height"
        case .waistCircumference:
            return "Waist Circumference"
        case .bloodPressureSystolic:
            return "Systolic Blood Pressure"
        case .bloodPressureDiastolic:
            return "Diastolic Blood Pressure"
        case .respiratoryRate:
            return "Respiratory Rate"
        case .bodyTemperature:
            return "Body Temperature"
        case .basalBodyTemperature:
            return "Basal Body Temperature"
        case .oxygenSaturation:
            return "Oxygen Saturation"
        case .peripheralPerfusionIndex:
            return "Peripheral Perfusion Index"
        case .bloodGlucose:
            return "Blood Glucose"
        case .bloodAlcoholContent:
            return "Blood Alcohol Content"
        case .numberOfTimesFallen:
            return "Number of Times Fallen"
        case .electrodermalActivity:
            return "Electrodermal Activity"
        case .inhalerUsage:
            return "Inhaler Usage"
        case .insulinDelivery:
            return "Insulin Delivery"
        case .forcedVitalCapacity:
            return "Forced Vital Capacity"
        case .forcedExpiratoryVolume1:
            return "Forced Expiratory Volume"
        case .peakExpiratoryFlowRate:
            return "Peak Expiratory Flow Rate"
        case .environmentalAudioExposure:
            return "Environmental Audio Exposure"
        case .headphoneAudioExposure:
            return "Headphone Audio Exposure"
        case .uvExposure:
            return "UV Exposure"
        case .vo2Max:
            return "VO₂ Max"
        case .distanceSwimming:
            return "Swimming Distance"
        case .swimmingStrokeCount:
            return "Swimming Stroke Count"
        case .distanceDownhillSnowSports:
            return "Downhill Snow Sports Distance"
        case .nikeFuel:
            return "NikeFuel"
        case .appleExerciseTime:
            return "Exercise Time"
        case .pushCount:
            return "Push Count"
        case .dietaryEnergyConsumed:
            return "Energy Consumed"
        case .dietaryWater:
            return "Water"
        case .dietaryFatTotal:
            return "Total Fat"
        case .dietaryFatSaturated:
            return "Saturated Fat"
        case .dietaryFatMonounsaturated:
            return "Monounsaturated Fat"
        case .dietaryFatPolyunsaturated:
            return "Polyunsaturated Fat"
        case .dietaryCholesterol:
            return "Cholesterol"
        case .dietarySodium:
            return "Sodium"
        case .dietaryCarbohydrates:
            return "Carbohydrates"
        case .dietaryFiber:
            return "Fiber"
        case .dietarySugar:
            return "Sugar"
        case .dietaryProtein:
            return "Protein"
        case .dietaryVitaminA:
            return "Vitamin A"
        case .dietaryVitaminB6:
            return "Vitamin B6"
        case .dietaryVitaminB12:
            return "Vitamin B12"
        case .dietaryVitaminC:
            return "Vitamin C"
        case .dietaryVitaminD:
            return "Vitamin D"
        case .dietaryVitaminE:
            return "Vitamin E"
        case .dietaryVitaminK:
            return "Vitamin K"
        case .dietaryCalcium:
            return "Calcium"
        case .dietaryIron:
            return "Iron"
        case .dietaryThiamin:
            return "Thiamin"
        case .dietaryRiboflavin:
            return "Riboflavin"
        case .dietaryNiacin:
            return "Niacin"
        case .dietaryFolate:
            return "Folate"
        case .dietaryBiotin:
            return "Biotin"
        case .dietaryPantothenicAcid:
            return "Pantothenic Acid"
        case .dietaryPhosphorus:
            return "Phosphorus"
        case .dietaryIodine:
            return "Iodine"
        case .dietaryMagnesium:
            return "Magnesium"
        case .dietaryZinc:
            return "Zinc"
        case .dietarySelenium:
            return "Selenium"
        case .dietaryCopper:
            return "Copper"
        case .dietaryManganese:
            return "Manganese"
        case .dietaryChromium:
            return "Chromium"
        case .dietaryMolybdenum:
            return "Molybdenum"
        case .dietaryChloride:
            return "Chloride"
        case .dietaryPotassium:
            return "Potassium"
        case .dietaryCaffeine:
            return "Caffeine"
        default:
            return typeIdentifier.rawValue
        }
    }
}