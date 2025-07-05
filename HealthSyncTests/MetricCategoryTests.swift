import XCTest
@testable import HealthSync

class MetricCategoryTests: XCTestCase {
    
    func testMetricCategoryAllCases() {
        let allCases = MetricCategory.allCases
        
        XCTAssertEqual(allCases.count, 6)
        XCTAssertTrue(allCases.contains(.vitals))
        XCTAssertTrue(allCases.contains(.activity))
        XCTAssertTrue(allCases.contains(.nutrition))
        XCTAssertTrue(allCases.contains(.sleep))
        XCTAssertTrue(allCases.contains(.lab))
        XCTAssertTrue(allCases.contains(.other))
    }
    
    func testMetricCategoryRawValues() {
        XCTAssertEqual(MetricCategory.vitals.rawValue, "vitals")
        XCTAssertEqual(MetricCategory.activity.rawValue, "activity")
        XCTAssertEqual(MetricCategory.nutrition.rawValue, "nutrition")
        XCTAssertEqual(MetricCategory.sleep.rawValue, "sleep")
        XCTAssertEqual(MetricCategory.lab.rawValue, "lab")
        XCTAssertEqual(MetricCategory.other.rawValue, "other")
    }
    
    func testMetricCategoryDisplayNames() {
        XCTAssertEqual(MetricCategory.vitals.displayName, "Vitals")
        XCTAssertEqual(MetricCategory.activity.displayName, "Activity")
        XCTAssertEqual(MetricCategory.nutrition.displayName, "Nutrition")
        XCTAssertEqual(MetricCategory.sleep.displayName, "Sleep")
        XCTAssertEqual(MetricCategory.lab.displayName, "Lab Results")
        XCTAssertEqual(MetricCategory.other.displayName, "Other")
    }
    
    func testMetricCategoryDescriptions() {
        XCTAssertFalse(MetricCategory.vitals.description.isEmpty)
        XCTAssertFalse(MetricCategory.activity.description.isEmpty)
        XCTAssertFalse(MetricCategory.nutrition.description.isEmpty)
        XCTAssertFalse(MetricCategory.sleep.description.isEmpty)
        XCTAssertFalse(MetricCategory.lab.description.isEmpty)
        XCTAssertFalse(MetricCategory.other.description.isEmpty)
        
        // Verify descriptions contain expected keywords
        XCTAssertTrue(MetricCategory.vitals.description.contains("Heart rate"))
        XCTAssertTrue(MetricCategory.activity.description.contains("Steps"))
        XCTAssertTrue(MetricCategory.nutrition.description.contains("Dietary"))
        XCTAssertTrue(MetricCategory.sleep.description.contains("Sleep"))
        XCTAssertTrue(MetricCategory.lab.description.contains("glucose"))
        XCTAssertTrue(MetricCategory.other.description.contains("Uncategorized"))
    }
    
    func testMetricCategoryCodable() throws {
        let originalCategory = MetricCategory.vitals
        
        // Encode to JSON
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(originalCategory)
        
        // Decode from JSON
        let decoder = JSONDecoder()
        let decodedCategory = try decoder.decode(MetricCategory.self, from: jsonData)
        
        XCTAssertEqual(originalCategory, decodedCategory)
    }
    
    func testMetricCategoryFromRawValue() {
        XCTAssertEqual(MetricCategory(rawValue: "vitals"), .vitals)
        XCTAssertEqual(MetricCategory(rawValue: "activity"), .activity)
        XCTAssertEqual(MetricCategory(rawValue: "nutrition"), .nutrition)
        XCTAssertEqual(MetricCategory(rawValue: "sleep"), .sleep)
        XCTAssertEqual(MetricCategory(rawValue: "lab"), .lab)
        XCTAssertEqual(MetricCategory(rawValue: "other"), .other)
        XCTAssertNil(MetricCategory(rawValue: "invalid"))
    }
}