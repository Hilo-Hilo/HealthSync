//
//  SyncEngine.swift
//  HealthSync
//
//  Created by Hanson Wen on 7/7/2025.
//

import Foundation
import HealthKit

// MARK: - SyncEngine
@MainActor
class SyncEngine: ObservableObject {
    static let shared = SyncEngine()
    
    @Published var isSyncing = false
    @Published var lastSyncResults: [SyncResult] = []
    
    private let healthKitManager = HealthKitManager.shared
    private let configService = ConfigService.shared
    private let destinationManager = SyncDestinationManager.shared
    private let logger = Logger.shared
    
    private init() {}
    
    func sync() async -> [SyncResult] {
        guard !isSyncing else { 
            print("Sync already in progress")
            return [] 
        }
        
        isSyncing = true
        lastSyncResults = []
        
        defer {
            self.isSyncing = false
        }
        
        // Get selected metric identifiers
        let selectedMetrics = configService.getSelectedMetrics()
        guard !selectedMetrics.isEmpty else {
            print("No metrics selected for sync")
            return []
        }
        
        // Get enabled destinations
        let enabledDestinations = destinationManager.getEnabledDestinations()
        guard !enabledDestinations.isEmpty else {
            print("No enabled sync destinations")
            return []
        }
        
        // Create sync targets from destinations
        let syncTargets = enabledDestinations.compactMap { destinationManager.createSyncTarget(from: $0) }
        guard !syncTargets.isEmpty else {
            print("No valid sync targets available")
            return []
        }
        
        var results: [SyncResult] = []
        
        // Fetch health data for selected metrics
        var allMetrics: [HealthMetric] = []
        
        for typeIdentifier in selectedMetrics {
            do {
                // Get data from the last 24 hours
                let endDate = Date()
                let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
                
                let samples = try await healthKitManager.fetchSamples(
                    for: typeIdentifier,
                    startDate: startDate,
                    endDate: endDate
                )
                
                // Convert samples to HealthMetric objects
                let metrics: [HealthMetric] = samples.compactMap { sample in
                    guard let quantitySample = sample as? HKQuantitySample else { return nil }
                    return MetricNormalizer.normalizeQuantitySample(quantitySample)
                }
                
                allMetrics.append(contentsOf: metrics)
                print("Fetched \(metrics.count) metrics for \(typeIdentifier.rawValue)")
            } catch {
                print("Failed to fetch samples for \(typeIdentifier.rawValue): \(error)")
                // Continue with other metrics even if one fails
            }
        }
        
        print("Total metrics fetched: \(allMetrics.count)")
        
        // Sync to each target
        for target in syncTargets {
            do {
                let result = try await target.sync(metrics: allMetrics)
                results.append(result)
                logger.logSync(result: result)
                print("Sync result for \(target.name): \(result.success ? "Success" : "Failed")")
            } catch {
                let errorResult = SyncResult(
                    timestamp: Date(),
                    success: false,
                    destination: target.type,
                    metricsCount: allMetrics.count,
                    errorMessage: "Sync failed: \(error.localizedDescription)",
                    responseCode: nil,
                    responseBody: nil
                )
                results.append(errorResult)
                logger.logSync(result: errorResult)
                print("Sync error for \(target.name): \(error.localizedDescription)")
            }
        }
        
        // Update last sync date if any sync was successful
        let hasSuccessfulSync = results.contains { $0.success }
        if hasSuccessfulSync {
            configService.updateLastSyncDate(Date())
        }
        
        lastSyncResults = results
        return results
    }
    
    // MARK: - Helper Methods
    
    func canSync() -> Bool {
        return !isSyncing && 
               !configService.getSelectedMetrics().isEmpty && 
               !destinationManager.getEnabledDestinations().isEmpty
    }
    
    func getSyncStatus() -> String {
        if isSyncing {
            return "Syncing..."
        } else if lastSyncResults.isEmpty {
            return "Ready to sync"
        } else {
            let successCount = lastSyncResults.filter { $0.success }.count
            let totalCount = lastSyncResults.count
            return "Last sync: \(successCount)/\(totalCount) successful"
        }
    }
}