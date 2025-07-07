//
//  SyncDestinationManagerTests.swift
//  HealthSyncTests
//
//  Created by Hanson Wen on 7/7/2025.
//

import XCTest
@testable import HealthSync

@MainActor
final class SyncDestinationManagerTests: XCTestCase {
    
    private var manager: SyncDestinationManager!
    private let testDestinationsKey = "test.healthsync.syncDestinations"
    
    override func setUp() {
        super.setUp()
        // Use a separate UserDefaults suite for testing
        UserDefaults.standard.removeObject(forKey: testDestinationsKey)
        manager = SyncDestinationManager.shared
        // Clear any existing destinations for clean tests
        for destination in manager.destinations {
            manager.removeDestination(id: destination.id)
        }
    }
    
    override func tearDown() {
        // Clean up test data
        for destination in manager.destinations {
            manager.removeDestination(id: destination.id)
        }
        UserDefaults.standard.removeObject(forKey: testDestinationsKey)
        manager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testManagerInitialization() {
        XCTAssertNotNil(manager)
        XCTAssertTrue(manager.destinations.isEmpty)
    }
    
    // MARK: - Add Destination Tests
    
    func testAddDestination() {
        let destination = createTestSupabaseDestination()
        
        manager.addDestination(destination)
        
        XCTAssertEqual(manager.destinations.count, 1)
        XCTAssertEqual(manager.destinations.first?.id, destination.id)
        XCTAssertEqual(manager.destinations.first?.name, destination.name)
        XCTAssertEqual(manager.destinations.first?.type, destination.type)
    }
    
    func testAddMultipleDestinations() {
        let supabaseDestination = createTestSupabaseDestination()
        let googleSheetsDestination = createTestGoogleSheetsDestination()
        
        manager.addDestination(supabaseDestination)
        manager.addDestination(googleSheetsDestination)
        
        XCTAssertEqual(manager.destinations.count, 2)
        XCTAssertTrue(manager.destinations.contains { $0.id == supabaseDestination.id })
        XCTAssertTrue(manager.destinations.contains { $0.id == googleSheetsDestination.id })
    }
    
    // MARK: - Update Destination Tests
    
    func testUpdateDestination() {
        let destination = createTestSupabaseDestination()
        manager.addDestination(destination)
        
        var updatedDestination = destination
        updatedDestination = SyncDestination(
            id: destination.id,
            name: "Updated Supabase",
            type: destination.type,
            isEnabled: false,
            configuration: destination.configuration
        )
        
        manager.updateDestination(updatedDestination)
        
        XCTAssertEqual(manager.destinations.count, 1)
        XCTAssertEqual(manager.destinations.first?.name, "Updated Supabase")
        XCTAssertFalse(manager.destinations.first?.isEnabled ?? true)
    }
    
    func testUpdateNonexistentDestination() {
        let destination = createTestSupabaseDestination()
        
        manager.updateDestination(destination)
        
        XCTAssertTrue(manager.destinations.isEmpty)
    }
    
    // MARK: - Remove Destination Tests
    
    func testRemoveDestination() {
        let destination = createTestSupabaseDestination()
        manager.addDestination(destination)
        
        XCTAssertEqual(manager.destinations.count, 1)
        
        manager.removeDestination(id: destination.id)
        
        XCTAssertTrue(manager.destinations.isEmpty)
    }
    
    func testRemoveNonexistentDestination() {
        let destination = createTestSupabaseDestination()
        manager.addDestination(destination)
        
        let nonexistentId = UUID()
        manager.removeDestination(id: nonexistentId)
        
        XCTAssertEqual(manager.destinations.count, 1)
        XCTAssertEqual(manager.destinations.first?.id, destination.id)
    }
    
    // MARK: - Get Enabled Destinations Tests
    
    func testGetEnabledDestinations() {
        let enabledDestination = createTestSupabaseDestination()
        let disabledDestination = SyncDestination(
            name: "Disabled Supabase",
            type: .supabase,
            isEnabled: false,
            configuration: [:]
        )
        
        manager.addDestination(enabledDestination)
        manager.addDestination(disabledDestination)
        
        let enabledDestinations = manager.getEnabledDestinations()
        
        XCTAssertEqual(enabledDestinations.count, 1)
        XCTAssertEqual(enabledDestinations.first?.id, enabledDestination.id)
    }
    
    func testGetEnabledDestinationsWithNoEnabledDestinations() {
        let disabledDestination = SyncDestination(
            name: "Disabled Supabase",
            type: .supabase,
            isEnabled: false,
            configuration: [:]
        )
        
        manager.addDestination(disabledDestination)
        
        let enabledDestinations = manager.getEnabledDestinations()
        
        XCTAssertTrue(enabledDestinations.isEmpty)
    }
    
    // MARK: - Create Sync Target Tests
    
    func testCreateSyncTargetForSupabase() {
        let destination = createTestSupabaseDestination()
        
        let syncTarget = manager.createSyncTarget(from: destination)
        
        XCTAssertNotNil(syncTarget)
        XCTAssertTrue(syncTarget is SupabaseTarget)
        XCTAssertEqual(syncTarget?.id, destination.id)
        XCTAssertEqual(syncTarget?.name, destination.name)
        XCTAssertEqual(syncTarget?.type, .supabase)
    }
    
    func testCreateSyncTargetForUnsupportedType() {
        let destination = createTestGoogleSheetsDestination()
        
        let syncTarget = manager.createSyncTarget(from: destination)
        
        // Google Sheets target is not implemented yet in Task 5
        XCTAssertNil(syncTarget)
    }
    
    // MARK: - Get Sync Targets Tests
    
    func testGetAllSyncTargets() {
        let supabaseDestination = createTestSupabaseDestination()
        let googleSheetsDestination = createTestGoogleSheetsDestination()
        
        manager.addDestination(supabaseDestination)
        manager.addDestination(googleSheetsDestination)
        
        let syncTargets = manager.getAllSyncTargets()
        
        // Only Supabase is supported in Task 5
        XCTAssertEqual(syncTargets.count, 1)
        XCTAssertTrue(syncTargets.first is SupabaseTarget)
    }
    
    func testGetEnabledSyncTargets() {
        let enabledSupabaseDestination = createTestSupabaseDestination()
        let disabledSupabaseDestination = SyncDestination(
            name: "Disabled Supabase",
            type: .supabase,
            isEnabled: false,
            configuration: [
                "url": "https://disabled.supabase.co",
                "apiKey": "disabled_api_key",
                "tableName": "disabled_table"
            ]
        )
        
        manager.addDestination(enabledSupabaseDestination)
        manager.addDestination(disabledSupabaseDestination)
        
        let enabledSyncTargets = manager.getEnabledSyncTargets()
        
        XCTAssertEqual(enabledSyncTargets.count, 1)
        XCTAssertEqual(enabledSyncTargets.first?.id, enabledSupabaseDestination.id)
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
    
    private func createTestGoogleSheetsDestination() -> SyncDestination {
        return SyncDestination(
            name: "Test Google Sheets",
            type: .googleSheets,
            isEnabled: true,
            configuration: [
                "webhookUrl": "https://script.google.com/test",
                "secret": "test_secret"
            ]
        )
    }
}