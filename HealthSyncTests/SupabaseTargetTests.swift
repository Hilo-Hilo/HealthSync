//
//  SupabaseTargetTests.swift
//  HealthSyncTests
//
//  Created by Hanson Wen on 7/7/2025.
//

import XCTest
@testable import HealthSync

@MainActor
final class SupabaseTargetTests: XCTestCase {
    
    private var testDestination: SyncDestination!
    private var supabaseTarget: SupabaseTarget!
    
    override func setUp() {
        super.setUp()
        testDestination = SyncDestination(
            name: "Test Supabase",
            type: .supabase,
            isEnabled: true,
            configuration: [
                "url": "https://test.supabase.co",
                "apiKey": "test_api_key",
                "tableName": "health_metrics"
            ]
        )
        supabaseTarget = SupabaseTarget(destination: testDestination)
    }
    
    override func tearDown() {
        testDestination = nil
        supabaseTarget = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testSupabaseTargetInitialization() {
        XCTAssertEqual(supabaseTarget.id, testDestination.id)
        XCTAssertEqual(supabaseTarget.name, "Test Supabase")
        XCTAssertEqual(supabaseTarget.type, .supabase)
        XCTAssertTrue(supabaseTarget.isEnabled)
        XCTAssertEqual(supabaseTarget.config["url"], "https://test.supabase.co")
        XCTAssertEqual(supabaseTarget.config["apiKey"], "test_api_key")
        XCTAssertEqual(supabaseTarget.config["tableName"], "health_metrics")
    }
    
    // MARK: - Validation Tests
    
    func testValidateWithValidConfiguration() {
        XCTAssertTrue(supabaseTarget.validate())
    }
    
    func testValidateWithMissingURL() {
        supabaseTarget.config.removeValue(forKey: "url")
        XCTAssertFalse(supabaseTarget.validate())
    }
    
    func testValidateWithEmptyURL() {
        supabaseTarget.config["url"] = ""
        XCTAssertFalse(supabaseTarget.validate())
    }
    
    func testValidateWithMissingAPIKey() {
        supabaseTarget.config.removeValue(forKey: "apiKey")
        XCTAssertFalse(supabaseTarget.validate())
    }
    
    func testValidateWithEmptyAPIKey() {
        supabaseTarget.config["apiKey"] = ""
        XCTAssertFalse(supabaseTarget.validate())
    }
    
    func testValidateWithMissingTableName() {
        supabaseTarget.config.removeValue(forKey: "tableName")
        XCTAssertFalse(supabaseTarget.validate())
    }
    
    func testValidateWithEmptyTableName() {
        supabaseTarget.config["tableName"] = ""
        XCTAssertFalse(supabaseTarget.validate())
    }
    
    func testValidateWithInvalidURL() {
        supabaseTarget.config["url"] = "not-a-valid-url"
        XCTAssertFalse(supabaseTarget.validate())
    }
    
    // MARK: - Sync Tests
    
    func testSyncWithInvalidConfiguration() async {
        // Create target with invalid configuration
        let invalidDestination = SyncDestination(
            name: "Invalid Supabase",
            type: .supabase,
            isEnabled: true,
            configuration: [:]
        )
        let invalidTarget = SupabaseTarget(destination: invalidDestination)
        
        let testMetrics = createTestMetrics()
        let result = try! await invalidTarget.sync(metrics: testMetrics)
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.destination, .supabase)
        XCTAssertEqual(result.metricsCount, testMetrics.count)
        XCTAssertTrue(result.errorMessage?.contains("Invalid configuration") == true)
        XCTAssertNil(result.responseCode)
        XCTAssertNil(result.responseBody)
    }
    
    func testSyncWithInvalidURL() async {
        supabaseTarget.config["url"] = "not-a-url"
        
        let testMetrics = createTestMetrics()
        let result = try! await supabaseTarget.sync(metrics: testMetrics)
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.destination, .supabase)
        XCTAssertEqual(result.metricsCount, testMetrics.count)
        XCTAssertTrue(result.errorMessage?.contains("Invalid configuration") == true)
        XCTAssertNil(result.responseCode)
        XCTAssertNil(result.responseBody)
    }
    
    // MARK: - Helper Methods
    
    private func createTestMetrics() -> [HealthMetric] {
        return [
            HealthMetric(
                name: "Heart Rate",
                identifier: "HKQuantityTypeIdentifierHeartRate",
                value: 72.0,
                unit: "bpm",
                timestamp: Date(),
                category: .vitals,
                source: "Test"
            ),
            HealthMetric(
                name: "Step Count",
                identifier: "HKQuantityTypeIdentifierStepCount",
                value: 1000.0,
                unit: "count",
                timestamp: Date(),
                category: .activity,
                source: "Test"
            )
        ]
    }
}