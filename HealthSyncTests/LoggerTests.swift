//
//  LoggerTests.swift
//  HealthSyncTests
//
//  Created by Hanson Wen on 7/7/2025.
//

import XCTest
@testable import HealthSync

@MainActor
final class LoggerTests: XCTestCase {
    
    private var logger: Logger!
    private let testLogsKey = "test.healthsync.syncLogs"
    
    override func setUp() {
        super.setUp()
        // Use test-specific UserDefaults key
        UserDefaults.standard.removeObject(forKey: testLogsKey)
        logger = Logger.shared
        logger.clearLogs()
    }
    
    override func tearDown() {
        logger.clearLogs()
        UserDefaults.standard.removeObject(forKey: testLogsKey)
        logger = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testLoggerInitialization() {
        XCTAssertNotNil(logger)
        XCTAssertTrue(logger.logs.isEmpty)
    }
    
    func testLoggerSharedInstance() {
        let instance1 = Logger.shared
        let instance2 = Logger.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Log Management Tests
    
    func testLogSync() {
        let syncResult = createTestSyncResult(success: true)
        
        logger.logSync(result: syncResult)
        
        XCTAssertEqual(logger.logs.count, 1)
        XCTAssertEqual(logger.logs.first?.id, syncResult.id)
        XCTAssertTrue(logger.logs.first?.success == true)
    }
    
    func testLogSyncMultiple() {
        let result1 = createTestSyncResult(success: true)
        let result2 = createTestSyncResult(success: false)
        
        logger.logSync(result: result1)
        logger.logSync(result: result2)
        
        XCTAssertEqual(logger.logs.count, 2)
        // Newest logs should be first
        XCTAssertEqual(logger.logs.first?.id, result2.id)
        XCTAssertEqual(logger.logs.last?.id, result1.id)
    }
    
    func testLogSyncOrderNewestFirst() {
        let result1 = createTestSyncResult(success: true, destination: .supabase)
        let result2 = createTestSyncResult(success: false, destination: .googleSheets)
        let result3 = createTestSyncResult(success: true, destination: .zapier)
        
        logger.logSync(result: result1)
        logger.logSync(result: result2)
        logger.logSync(result: result3)
        
        XCTAssertEqual(logger.logs.count, 3)
        XCTAssertEqual(logger.logs[0].destination, .zapier)   // Most recent
        XCTAssertEqual(logger.logs[1].destination, .googleSheets)
        XCTAssertEqual(logger.logs[2].destination, .supabase) // Oldest
    }
    
    func testLogSyncLimitEnforcement() {
        // Add more than 100 logs (the max limit)
        for i in 0..<105 {
            let result = createTestSyncResult(success: i % 2 == 0, metricsCount: i)
            logger.logSync(result: result)
        }
        
        XCTAssertEqual(logger.logs.count, 100)
        // Most recent log should have metricsCount 104
        XCTAssertEqual(logger.logs.first?.metricsCount, 104)
        // Oldest log should have metricsCount 5 (104 - 100 + 1)
        XCTAssertEqual(logger.logs.last?.metricsCount, 5)
    }
    
    func testClearLogs() {
        let result1 = createTestSyncResult(success: true)
        let result2 = createTestSyncResult(success: false)
        
        logger.logSync(result: result1)
        logger.logSync(result: result2)
        
        XCTAssertEqual(logger.logs.count, 2)
        
        logger.clearLogs()
        
        XCTAssertTrue(logger.logs.isEmpty)
    }
    
    // MARK: - Persistence Tests
    
    func testLogsPersistence() {
        let result = createTestSyncResult(success: true, errorMessage: "Test error")
        
        logger.logSync(result: result)
        
        // Create a new logger instance to test persistence
        let newLogger = Logger.shared
        
        // The shared instance should maintain the same logs
        XCTAssertEqual(newLogger.logs.count, 1)
        XCTAssertEqual(newLogger.logs.first?.id, result.id)
    }
    
    // MARK: - Helper Methods
    
    private func createTestSyncResult(success: Bool, destination: SyncDestinationType = .supabase, metricsCount: Int = 5, errorMessage: String? = nil) -> SyncResult {
        return SyncResult(
            timestamp: Date(),
            success: success,
            destination: destination,
            metricsCount: metricsCount,
            errorMessage: errorMessage,
            responseCode: success ? 200 : 400,
            responseBody: success ? "Success" : "Error"
        )
    }
}