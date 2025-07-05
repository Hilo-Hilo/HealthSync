import Foundation

enum MetricCategory: String, Codable, CaseIterable {
    case vitals
    case activity
    case nutrition
    case sleep
    case lab
    case other
    
    var displayName: String {
        switch self {
        case .vitals:
            return "Vitals"
        case .activity:
            return "Activity"
        case .nutrition:
            return "Nutrition"
        case .sleep:
            return "Sleep"
        case .lab:
            return "Lab Results"
        case .other:
            return "Other"
        }
    }
    
    var description: String {
        switch self {
        case .vitals:
            return "Heart rate, blood pressure, respiratory rate, body temperature"
        case .activity:
            return "Steps, distance, active energy, flights climbed"
        case .nutrition:
            return "Dietary metrics, water intake, macronutrients"
        case .sleep:
            return "Sleep analysis and sleep stages"
        case .lab:
            return "Blood glucose, cholesterol, lab results"
        case .other:
            return "Uncategorized or custom metrics"
        }
    }
}

struct HealthMetric: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String           // Human-readable name (e.g., "Heart Rate")
    let identifier: String     // HKQuantityTypeIdentifier string for traceability
    let value: Double          // Numeric value in standardized unit
    let unit: String           // Standardized unit string (e.g., "bpm", "kg")
    let timestamp: Date        // When the measurement was taken
    let category: MetricCategory // Classification for UI grouping
    
    // Optional metadata
    var source: String?        // App or device that recorded the data (e.g., "Apple Watch")
    
    init(name: String, identifier: String, value: Double, unit: String, timestamp: Date, category: MetricCategory, source: String? = nil) {
        self.name = name
        self.identifier = identifier
        self.value = value
        self.unit = unit
        self.timestamp = timestamp
        self.category = category
        self.source = source
    }
    
    // Equatable implementation (excluding id since it's always unique)
    static func == (lhs: HealthMetric, rhs: HealthMetric) -> Bool {
        return lhs.name == rhs.name &&
               lhs.identifier == rhs.identifier &&
               lhs.value == rhs.value &&
               lhs.unit == rhs.unit &&
               lhs.timestamp == rhs.timestamp &&
               lhs.category == rhs.category &&
               lhs.source == rhs.source
    }
}

// MARK: - Convenience Extensions
extension HealthMetric {
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        guard let formattedNumber = formatter.string(from: NSNumber(value: value)) else {
            return String(value)
        }
        
        return "\(formattedNumber) \(unit)"
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var isRecent: Bool {
        let twentyFourHoursAgo = Date().addingTimeInterval(-86400)
        return timestamp > twentyFourHoursAgo
    }
}

// MARK: - Sample Data for Testing
extension HealthMetric {
    static func sampleData() -> [HealthMetric] {
        let now = Date()
        return [
            HealthMetric(
                name: "Heart Rate",
                identifier: "HKQuantityTypeIdentifierHeartRate",
                value: 72.0,
                unit: "bpm",
                timestamp: now.addingTimeInterval(-3600),
                category: .vitals,
                source: "Apple Watch"
            ),
            HealthMetric(
                name: "Step Count",
                identifier: "HKQuantityTypeIdentifierStepCount",
                value: 8542.0,
                unit: "steps",
                timestamp: now.addingTimeInterval(-7200),
                category: .activity,
                source: "iPhone"
            ),
            HealthMetric(
                name: "Body Mass",
                identifier: "HKQuantityTypeIdentifierBodyMass",
                value: 70.5,
                unit: "kg",
                timestamp: now.addingTimeInterval(-10800),
                category: .vitals,
                source: "Health App"
            ),
            HealthMetric(
                name: "Active Energy Burned",
                identifier: "HKQuantityTypeIdentifierActiveEnergyBurned",
                value: 245.7,
                unit: "kcal",
                timestamp: now.addingTimeInterval(-14400),
                category: .activity,
                source: "Apple Watch"
            ),
            HealthMetric(
                name: "Blood Glucose",
                identifier: "HKQuantityTypeIdentifierBloodGlucose",
                value: 95.0,
                unit: "mg/dL",
                timestamp: now.addingTimeInterval(-18000),
                category: .lab,
                source: "Health App"
            )
        ]
    }
}

// MARK: - JSON Encoding/Decoding Extensions
extension HealthMetric {
    enum CodingKeys: String, CodingKey {
        case name
        case identifier
        case value
        case unit
        case timestamp
        case category
        case source
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        identifier = try container.decode(String.self, forKey: .identifier)
        value = try container.decode(Double.self, forKey: .value)
        unit = try container.decode(String.self, forKey: .unit)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        category = try container.decode(MetricCategory.self, forKey: .category)
        source = try container.decodeIfPresent(String.self, forKey: .source)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(value, forKey: .value)
        try container.encode(unit, forKey: .unit)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(source, forKey: .source)
    }
}