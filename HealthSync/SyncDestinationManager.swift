//
//  SyncDestinationManager.swift
//  HealthSync
//
//  Created by Hanson Wen on 7/7/2025.
//

import Foundation

// MARK: - SyncDestinationManager
@MainActor
class SyncDestinationManager: ObservableObject {
    static let shared = SyncDestinationManager()
    
    @Published private(set) var destinations: [SyncDestination] = []
    
    private let userDefaults = UserDefaults.standard
    private let destinationsKey = "healthsync.syncDestinations"
    
    private init() {
        loadDestinations()
    }
    
    private func loadDestinations() {
        if let data = userDefaults.data(forKey: destinationsKey) {
            do {
                destinations = try JSONDecoder().decode([SyncDestination].self, from: data)
            } catch {
                print("Failed to load sync destinations: \(error)")
                destinations = []
            }
        }
    }
    
    private func saveDestinations() {
        do {
            let data = try JSONEncoder().encode(destinations)
            userDefaults.set(data, forKey: destinationsKey)
            userDefaults.synchronize()
        } catch {
            print("Failed to save sync destinations: \(error)")
        }
    }
    
    func addDestination(_ destination: SyncDestination) {
        destinations.append(destination)
        saveDestinations()
    }
    
    func updateDestination(_ destination: SyncDestination) {
        if let index = destinations.firstIndex(where: { $0.id == destination.id }) {
            destinations[index] = destination
            saveDestinations()
        }
    }
    
    func removeDestination(id: UUID) {
        destinations.removeAll { $0.id == id }
        saveDestinations()
    }
    
    func getEnabledDestinations() -> [SyncDestination] {
        return destinations.filter { $0.isEnabled }
    }
    
    func createSyncTarget(from destination: SyncDestination) -> SyncTarget? {
        switch destination.type {
        case .supabase:
            return SupabaseTarget(destination: destination)
        case .googleSheets:
            // Will be implemented in subsequent tasks
            return nil
        case .zapier:
            // Will be implemented in subsequent tasks
            return nil
        case .customAPI:
            // Will be implemented in subsequent tasks
            return nil
        }
    }
    
    func getAllSyncTargets() -> [SyncTarget] {
        return destinations.compactMap { createSyncTarget(from: $0) }
    }
    
    func getEnabledSyncTargets() -> [SyncTarget] {
        return getEnabledDestinations().compactMap { createSyncTarget(from: $0) }
    }
}