//
//  ConfigService.swift
//  HealthSync
//
//  Created by Hanson Wen on 5/7/2025.
//

import Foundation
import HealthKit

struct SyncDestination: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: SyncDestinationType
    let isEnabled: Bool
    let configuration: [String: String]
    
    init(name: String, type: SyncDestinationType, isEnabled: Bool, configuration: [String: String]) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.isEnabled = isEnabled
        self.configuration = configuration
    }
    
    init(id: UUID = UUID(), name: String, type: SyncDestinationType, isEnabled: Bool, configuration: [String: String]) {
        self.id = id
        self.name = name
        self.type = type
        self.isEnabled = isEnabled
        self.configuration = configuration
    }
}

struct UserSettings: Codable {
    var selectedMetrics: Set<String>
    var syncDestinations: [SyncDestination]
    var syncInterval: TimeInterval
    var lastSyncDate: Date?
    
    init() {
        self.selectedMetrics = []
        self.syncDestinations = []
        self.syncInterval = 3600 // 1 hour default
        self.lastSyncDate = nil
    }
}

@MainActor
class ConfigService: ObservableObject {
    static let shared = ConfigService()
    
    @Published var userSettings: UserSettings
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "HealthSyncUserSettings"
    
    private init() {
        // Initialize with default settings first to avoid crashes
        self.userSettings = UserSettings()
        
        // Then attempt to load saved settings
        self.loadSettings()
    }
    
    private func loadSettings() {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            return
        }
        
        do {
            self.userSettings = try JSONDecoder().decode(UserSettings.self, from: data)
        } catch {
            print("Failed to load user settings: \(error)")
            // Keep default settings if loading fails
        }
    }
    
    func saveSettings() {
        do {
            let data = try JSONEncoder().encode(userSettings)
            userDefaults.set(data, forKey: settingsKey)
            userDefaults.synchronize() // Force immediate save
        } catch {
            print("Failed to save user settings: \(error)")
        }
    }
    
    func updateSelectedMetrics(_ metrics: Set<HKQuantityTypeIdentifier>) {
        userSettings.selectedMetrics = Set(metrics.map { $0.rawValue })
        saveSettings()
    }
    
    func getSelectedMetrics() -> Set<HKQuantityTypeIdentifier> {
        return Set(userSettings.selectedMetrics.compactMap { HKQuantityTypeIdentifier(rawValue: $0) })
    }
    
    func addSyncDestination(_ destination: SyncDestination) {
        userSettings.syncDestinations.append(destination)
        saveSettings()
    }
    
    func removeSyncDestination(withId id: UUID) {
        userSettings.syncDestinations.removeAll { $0.id == id }
        saveSettings()
    }
    
    func updateSyncDestination(_ destination: SyncDestination) {
        if let index = userSettings.syncDestinations.firstIndex(where: { $0.id == destination.id }) {
            userSettings.syncDestinations[index] = destination
            saveSettings()
        }
    }
    
    func setSyncInterval(_ interval: TimeInterval) {
        userSettings.syncInterval = interval
        saveSettings()
    }
    
    func updateLastSyncDate(_ date: Date) {
        userSettings.lastSyncDate = date
        saveSettings()
    }
    
    func getEnabledDestinations() -> [SyncDestination] {
        return userSettings.syncDestinations.filter { $0.isEnabled }
    }
    
    func resetSettings() {
        userSettings = UserSettings()
        saveSettings()
    }
}

extension ConfigService {
    func exportSettings() -> Data? {
        return try? JSONEncoder().encode(userSettings)
    }
    
    func importSettings(from data: Data) -> Bool {
        do {
            let settings = try JSONDecoder().decode(UserSettings.self, from: data)
            userSettings = settings
            saveSettings()
            return true
        } catch {
            print("Failed to import settings: \(error)")
            return false
        }
    }
}