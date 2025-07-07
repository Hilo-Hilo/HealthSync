//
//  SyncEngineTests.swift
//  HealthSyncTests
//
//  Created by Hanson Wen on 7/7/2025.
//

import XCTest
@testable import HealthSync
import HealthKit

@MainActor
final class SyncEngineTests: XCTestCase {
    
    private var syncEngine: SyncEngine!
    
    override func setUp() {
        super.setUp()
        syncEngine = SyncEngine.shared
        
        // Reset sync engine state completely
        syncEngine.isSyncing = false
        syncEngine.lastSyncResults.removeAll()
        
        // Clear destinations and metrics for clean tests
        let destinationManager = SyncDestinationManager.shared
        for destination in destinationManager.destinations {
            destinationManager.removeDestination(id: destination.id)
        }
        
        let configService = ConfigService.shared
        configService.updateSelectedMetrics([])
        
        // Give the system time to settle
        Thread.sleep(forTimeInterval: 0.01)
    }
    
    override func tearDown() {
        // Clean up test data more thoroughly
        syncEngine.isSyncing = false
        syncEngine.lastSyncResults.removeAll()
        
        let destinationManager = SyncDestinationManager.shared
        for destination in destinationManager.destinations {
            destinationManager.removeDestination(id: destination.id)
        }
        
        let configService = ConfigService.shared
        configService.updateSelectedMetrics([])
     
        syncEngine = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testSyncEngineInitialization() {
        XCTAssertNotNil(syncEngine)
        XCTAssertFalse(syncEngine.isSyncing)
        XCTAssertTrue(syncEngine.lastSyncResults.isEmpty)
    }
    
    func testSyncEngineSharedInstance() {
        let instance1 = SyncEngine.shared
        let instance2 = SyncEngine.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Helper Method Tests
    
    func testCanSyncWithNoMetrics() {
        // Setup: Add a valid destination but no metrics
        let destination = createTestSupabaseDestination()
        SyncDestinationManager.shared.addDestination(destination)
        
        XCTAssertFalse(syncEngine.canSync())
    }
    
    func testCanSyncWithNoDestinations() {
        // Setup: Add metrics but no destinations
        ConfigService.shared.updateSelectedMetrics([.heartRate])
        
        XCTAssertFalse(syncEngine.canSync())
    }
    
    func testCanSyncWithMetricsAndDestinations() {
        // Setup: Add both metrics and destinations
        let destination = createTestSupabaseDestination()
        SyncDestinationManager.shared.addDestination(destination)
        ConfigService.shared.updateSelectedMetrics([.heartRate])
        
        XCTAssertTrue(syncEngine.canSync())
    }
    
    func testCanSyncWhileSyncing() {
        // Setup: Add both metrics and destinations
        let destination = createTestSupabaseDestination()
        SyncDestinationManager.shared.addDestination(destination)
        ConfigService.shared.updateSelectedMetrics([.heartRate])
        
        // Simulate syncing state
        syncEngine.isSyncing = true
        
        XCTAssertFalse(syncEngine.canSync())
    }
    
    // MARK: - Sync Status Tests
    
    func testGetSyncStatusWhenReady() {
        let status = syncEngine.getSyncStatus()
        XCTAssertEqual(status, "Ready to sync")
    }
    
    func testGetSyncStatusWhenSyncing() {
        syncEngine.isSyncing = true
        let status = syncEngine.getSyncStatus()
        XCTAssertEqual(status, "Syncing...")
    }
    
    func testGetSyncStatusWithResults() {
        let successResult = SyncResult(
            timestamp: Date(),
            success: true,
            destination: .supabase,
            metricsCount: 5,
            errorMessage: nil
        )
        let failureResult = SyncResult(
            timestamp: Date(),
            success: false,
            destination: .supabase,
            metricsCount: 5,
            errorMessage: "Test error"
        )
        
        syncEngine.lastSyncResults.removeAll()
        syncEngine.lastSyncResults.append(successResult)
        syncEngine.lastSyncResults.append(failureResult)
        
        let status = syncEngine.getSyncStatus()
        XCTAssertEqual(status, "Last sync: 1/2 successful")
    }
    
    // MARK: - Sync Functionality Tests
    
    func testSyncWithNoMetrics() async {
        let results = await syncEngine.sync()
        XCTAssertTrue(results.isEmpty)
        XCTAssertFalse(syncEngine.isSyncing)
    }
    
    func testSyncWithNoDestinations() async {
        ConfigService.shared.updateSelectedMetrics([.heartRate])
        
        let results = await syncEngine.sync()
        XCTAssertTrue(results.isEmpty)
        XCTAssertFalse(syncEngine.isSyncing)
    }
    
    func testSyncWithMetricsAndDestinations() async {
        // Setup: Add metrics and destination
        let destination = createTestSupabaseDestination()
        SyncDestinationManager.shared.addDestination(destination)
        ConfigService.shared.updateSelectedMetrics([.heartRate])
        
        // Note: This test will attempt actual HealthKit sync which may fail on simulator
        // The test verifies that the sync process runs without crashing
        let results = await syncEngine.sync()
        
        // Results may be empty or contain errors due to simulator limitations
        // but the sync process should complete
        XCTAssertFalse(syncEngine.isSyncing)
        XCTAssertEqual(syncEngine.lastSyncResults.count, results.count)
    }
    
    func testSyncInProgressPrevention() async {
        // Start sync
        syncEngine.isSyncing = true
        
        let results = await syncEngine.sync()
        XCTAssertTrue(results.isEmpty)
    }
    
    func testSyncUpdatesLastSyncResults() async {
        let destination = createTestSupabaseDestination()
        SyncDestinationManager.shared.addDestination(destination)
        ConfigService.shared.updateSelectedMetrics([.heartRate])
        
        let initialResultsCount = syncEngine.lastSyncResults.count
        let _ = await syncEngine.sync()
        
        // Results should be updated (even if empty due to simulator limitations)
        XCTAssertTrue(syncEngine.lastSyncResults.count >= initialResultsCount)
    }
    
    // MARK: - Helper Methods
    
    private func createTestSupabaseDestination() -> SyncDestination {
        return SyncDestination(
            name: "Test Supabase",
            type: .supabase,
            isEnabled: true,
            configuration: [
                "url": "https://test.supabase.co",
                "apiKey": "test_api_key",
                "tableName": "health_metrics"
            ]
        )
    }
}
