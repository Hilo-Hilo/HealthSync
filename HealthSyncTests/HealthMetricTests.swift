import XCTest
@testable import HealthSync

class HealthMetricTests: XCTestCase {
    
    func testHealthMetricInitialization() {
        let timestamp = Date()
        let metric = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: timestamp,
            category: .vitals,
            source: "Apple Watch"
        )
        
        XCTAssertEqual(metric.name, "Heart Rate")
        XCTAssertEqual(metric.identifier, "HKQuantityTypeIdentifierHeartRate")
        XCTAssertEqual(metric.value, 72.0)
        XCTAssertEqual(metric.unit, "bpm")
        XCTAssertEqual(metric.timestamp, timestamp)
        XCTAssertEqual(metric.category, .vitals)
        XCTAssertEqual(metric.source, "Apple Watch")
        XCTAssertNotNil(metric.id)
    }
    
    func testHealthMetricEquality() {
        let timestamp = Date()
        let metric1 = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: timestamp,
            category: .vitals,
            source: "Apple Watch"
        )
        
        let metric2 = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: timestamp,
            category: .vitals,
            source: "Apple Watch"
        )
        
        // Should be equal despite different UUIDs
        XCTAssertEqual(metric1, metric2)
        XCTAssertNotEqual(metric1.id, metric2.id)
    }
    
    func testHealthMetricInequality() {
        let timestamp = Date()
        let metric1 = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: timestamp,
            category: .vitals,
            source: "Apple Watch"
        )
        
        let metric2 = HealthMetric(
            name: "Step Count",
            identifier: "HKQuantityTypeIdentifierStepCount",
            value: 8542.0,
            unit: "steps",
            timestamp: timestamp,
            category: .activity,
            source: "iPhone"
        )
        
        XCTAssertNotEqual(metric1, metric2)
    }
    
    func testHealthMetricCodable() throws {
        let timestamp = Date()
        let originalMetric = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: timestamp,
            category: .vitals,
            source: "Apple Watch"
        )
        
        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(originalMetric)
        
        // Decode from JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedMetric = try decoder.decode(HealthMetric.self, from: jsonData)
        
        // Verify all properties are preserved (except UUID which is regenerated)
        XCTAssertEqual(originalMetric.name, decodedMetric.name)
        XCTAssertEqual(originalMetric.identifier, decodedMetric.identifier)
        XCTAssertEqual(originalMetric.value, decodedMetric.value)
        XCTAssertEqual(originalMetric.unit, decodedMetric.unit)
        XCTAssertEqual(originalMetric.timestamp.timeIntervalSince1970, decodedMetric.timestamp.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(originalMetric.category, decodedMetric.category)
        XCTAssertEqual(originalMetric.source, decodedMetric.source)
    }
    
    func testHealthMetricFormattedValue() {
        let metric1 = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: Date(),
            category: .vitals
        )
        
        let metric2 = HealthMetric(
            name: "Body Weight",
            identifier: "HKQuantityTypeIdentifierBodyMass",
            value: 70.123,
            unit: "kg",
            timestamp: Date(),
            category: .vitals
        )
        
        XCTAssertEqual(metric1.formattedValue, "72 bpm")
        XCTAssertEqual(metric2.formattedValue, "70.12 kg")
    }
    
    func testHealthMetricFormattedTimestamp() {
        let timestamp = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021
        let metric = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: timestamp,
            category: .vitals
        )
        
        let formatted = metric.formattedTimestamp
        XCTAssertTrue(formatted.contains("2021") || formatted.contains("21"))
    }
    
    func testHealthMetricIsRecent() {
        let recentMetric = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
            category: .vitals
        )
        
        let oldMetric = HealthMetric(
            name: "Heart Rate",
            identifier: "HKQuantityTypeIdentifierHeartRate",
            value: 72.0,
            unit: "bpm",
            timestamp: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            category: .vitals
        )
        
        XCTAssertTrue(recentMetric.isRecent)
        XCTAssertFalse(oldMetric.isRecent)
    }
    
    func testHealthMetricSampleData() {
        let sampleData = HealthMetric.sampleData()
        
        XCTAssertGreaterThan(sampleData.count, 0)
        XCTAssertEqual(sampleData.count, 5)
        
        // Verify sample data has variety
        let categories = Set(sampleData.map { $0.category })
        XCTAssertGreaterThan(categories.count, 1)
        
        // Verify all sample data is valid
        for metric in sampleData {
            XCTAssertFalse(metric.name.isEmpty)
            XCTAssertFalse(metric.identifier.isEmpty)
            XCTAssertGreaterThan(metric.value, 0)
            XCTAssertFalse(metric.unit.isEmpty)
        }
    }
}