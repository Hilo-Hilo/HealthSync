//
//  SyncTargetTests.swift
//  HealthSyncTests
//
//  Created by Hanson Wen on 7/7/2025.
//

import XCTest
@testable import HealthSync

@MainActor
final class SyncTargetTests: XCTestCase {
    
    // MARK: - SyncResult Tests
    
    func testSyncResultInitialization() {
        let result = SyncResult(
            timestamp: Date(),
            success: true,
            destination: .supabase,
            metricsCount: 5,
            errorMessage: nil,
            responseCode: 200,
            responseBody: "Success"
        )
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.destination, .supabase)
        XCTAssertEqual(result.metricsCount, 5)
        XCTAssertNil(result.errorMessage)
        XCTAssertEqual(result.responseCode, 200)
        XCTAssertEqual(result.responseBody, "Success")
    }
    
    func testSyncResultCodable() throws {
        let originalResult = SyncResult(
            timestamp: Date(),
            success: false,
            destination: .googleSheets,
            metricsCount: 3,
            errorMessage: "Test error",
            responseCode: 400,
            responseBody: "Error response"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalResult)
        
        let decoder = JSONDecoder()
        let decodedResult = try decoder.decode(SyncResult.self, from: data)
        
        XCTAssertEqual(originalResult.id, decodedResult.id)
        XCTAssertEqual(originalResult.success, decodedResult.success)
        XCTAssertEqual(originalResult.destination, decodedResult.destination)
        XCTAssertEqual(originalResult.metricsCount, decodedResult.metricsCount)
        XCTAssertEqual(originalResult.errorMessage, decodedResult.errorMessage)
        XCTAssertEqual(originalResult.responseCode, decodedResult.responseCode)
        XCTAssertEqual(originalResult.responseBody, decodedResult.responseBody)
    }
    
    // MARK: - SyncDestinationType Tests
    
    func testSyncDestinationTypeDisplayNames() {
        XCTAssertEqual(SyncDestinationType.supabase.displayName, "Supabase")
        XCTAssertEqual(SyncDestinationType.googleSheets.displayName, "Google Sheets")
        XCTAssertEqual(SyncDestinationType.zapier.displayName, "Zapier")
        XCTAssertEqual(SyncDestinationType.customAPI.displayName, "Custom API")
    }
    
    func testSyncDestinationTypeIconNames() {
        XCTAssertEqual(SyncDestinationType.supabase.iconName, "externaldrive.fill")
        XCTAssertEqual(SyncDestinationType.googleSheets.iconName, "doc.fill")
        XCTAssertEqual(SyncDestinationType.zapier.iconName, "bolt.fill")
        XCTAssertEqual(SyncDestinationType.customAPI.iconName, "cloud.fill")
    }
    
    func testSyncDestinationTypeAllCases() {
        let expectedTypes: [SyncDestinationType] = [.supabase, .googleSheets, .zapier, .customAPI]
        XCTAssertEqual(SyncDestinationType.allCases, expectedTypes)
    }
    
    // MARK: - SyncError Tests
    
    func testSyncErrorDescriptions() {
        XCTAssertEqual(SyncError.invalidURL.errorDescription, "Invalid URL configuration")
        XCTAssertEqual(SyncError.invalidResponse.errorDescription, "Invalid response from server")
        XCTAssertEqual(SyncError.configurationError.errorDescription, "Configuration error")
        XCTAssertEqual(SyncError.invalidConfiguration("Missing API key").errorDescription, "Invalid configuration: Missing API key")
        
        let testError = NSError(domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test network error"])
        XCTAssertEqual(SyncError.networkError(testError).errorDescription, "Network error: Test network error")
    }
}