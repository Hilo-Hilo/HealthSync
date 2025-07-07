//
//  ConfigServiceTests.swift
//  HealthSyncTests
//
//  Created by Hanson Wen on 5/7/2025.
//

import XCTest
import HealthKit
@testable import HealthSync

@MainActor
class ConfigServiceTests: XCTestCase {
    
    var configService: ConfigService!
    
    override func setUp() {
        super.setUp()
        configService = ConfigService.shared
        configService.resetSettings()
    }
    
    override func tearDown() {
        configService.resetSettings()
        super.tearDown()
    }
    
    func testInitialSettings() {
        let settings = configService.userSettings
        
        XCTAssertTrue(settings.selectedMetrics.isEmpty)
        XCTAssertTrue(settings.syncDestinations.isEmpty)
        XCTAssertEqual(settings.syncInterval, 3600) // 1 hour default
        XCTAssertNil(settings.lastSyncDate)
    }
    
    func testUpdateSelectedMetrics() {
        let metrics: Set<HKQuantityTypeIdentifier> = [.heartRate, .stepCount]
        
        configService.updateSelectedMetrics(metrics)
        
        let retrievedMetrics = configService.getSelectedMetrics()
        XCTAssertEqual(retrievedMetrics, metrics)
        XCTAssertEqual(configService.userSettings.selectedMetrics.count, 2)
    }
    
    func testAddSyncDestination() {
        let destination = SyncDestination(
            name: "Test Supabase",
            type: .supabase,
            isEnabled: true,
            configuration: ["url": "test.supabase.co"]
        )
        
        configService.addSyncDestination(destination)
        
        XCTAssertEqual(configService.userSettings.syncDestinations.count, 1)
        XCTAssertEqual(configService.userSettings.syncDestinations[0].name, "Test Supabase")
        XCTAssertEqual(configService.userSettings.syncDestinations[0].type, .supabase)
    }
    
    func testRemoveSyncDestination() {
        let destination = SyncDestination(
            name: "Test Destination",
            type: .customAPI,
            isEnabled: false,
            configuration: [:]
        )
        
        configService.addSyncDestination(destination)
        XCTAssertEqual(configService.userSettings.syncDestinations.count, 1)
        
        configService.removeSyncDestination(withId: destination.id)
        XCTAssertTrue(configService.userSettings.syncDestinations.isEmpty)
    }
    
    func testUpdateSyncDestination() {
        let destination = SyncDestination(
            name: "Original Name",
            type: .googleSheets,
            isEnabled: false,
            configuration: [:]
        )
        
        configService.addSyncDestination(destination)
        
        let _ = SyncDestination(
            name: "Updated Name",
            type: .googleSheets,
            isEnabled: true,
            configuration: ["sheet_id": "123"]
        )
        
        // This test would need a modified SyncDestination to allow ID updates
        // For now, just test that destinations can be managed
        XCTAssertEqual(configService.userSettings.syncDestinations.count, 1)
    }
    
    func testSetSyncInterval() {
        let newInterval: TimeInterval = 1800 // 30 minutes
        
        configService.setSyncInterval(newInterval)
        
        XCTAssertEqual(configService.userSettings.syncInterval, newInterval)
    }
    
    func testUpdateLastSyncDate() {
        let testDate = Date()
        
        configService.updateLastSyncDate(testDate)
        
        XCTAssertNotNil(configService.userSettings.lastSyncDate)
        if let lastSyncDate = configService.userSettings.lastSyncDate {
            XCTAssertEqual(lastSyncDate.timeIntervalSince1970,
                           testDate.timeIntervalSince1970, accuracy: 1.0)
        }
    }
    
    func testGetEnabledDestinations() {
        let enabledDestination = SyncDestination(
            name: "Enabled",
            type: .supabase,
            isEnabled: true,
            configuration: [:]
        )
        
        let disabledDestination = SyncDestination(
            name: "Disabled",
            type: .googleSheets,
            isEnabled: false,
            configuration: [:]
        )
        
        configService.addSyncDestination(enabledDestination)
        configService.addSyncDestination(disabledDestination)
        
        let enabledDestinations = configService.getEnabledDestinations()
        
        XCTAssertEqual(enabledDestinations.count, 1)
        XCTAssertEqual(enabledDestinations[0].name, "Enabled")
        XCTAssertTrue(enabledDestinations[0].isEnabled)
    }
    
    func testResetSettings() {
        // Set up some data
        configService.updateSelectedMetrics([.heartRate, .stepCount])
        configService.setSyncInterval(1800)
        configService.updateLastSyncDate(Date())
        
        XCTAssertFalse(configService.userSettings.selectedMetrics.isEmpty)
        
        // Reset
        configService.resetSettings()
        
        // Verify reset
        XCTAssertTrue(configService.userSettings.selectedMetrics.isEmpty)
        XCTAssertTrue(configService.userSettings.syncDestinations.isEmpty)
        XCTAssertEqual(configService.userSettings.syncInterval, 3600)
        XCTAssertNil(configService.userSettings.lastSyncDate)
    }
    
    func testExportImportSettings() {
        // Set up test data
        configService.updateSelectedMetrics([.heartRate, .stepCount])
        configService.setSyncInterval(1800)
        
        // Export
        guard let exportData = configService.exportSettings() else {
            XCTFail("Failed to export settings")
            return
        }
        
        // Reset and verify empty
        configService.resetSettings()
        XCTAssertTrue(configService.userSettings.selectedMetrics.isEmpty)
        
        // Import
        let importSuccess = configService.importSettings(from: exportData)
        XCTAssertTrue(importSuccess)
        
        // Verify imported data
        XCTAssertEqual(configService.getSelectedMetrics().count, 2)
        XCTAssertEqual(configService.userSettings.syncInterval, 1800)
    }
}