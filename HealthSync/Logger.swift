//
//  Logger.swift
//  HealthSync
//
//  Created by Hanson Wen on 7/7/2025.
//

import Foundation

// MARK: - Simple Logger (Task 7 Preview)
// This is a minimal implementation to support Task 6
// Full implementation will be done in Task 7
@MainActor
class Logger: ObservableObject {
    static let shared = Logger()
    
    @Published private(set) var logs: [SyncResult] = []
    
    private let userDefaults = UserDefaults.standard
    private let logsKey = "healthsync.syncLogs"
    private let maxLogEntries = 100
    
    private init() {
        loadLogs()
    }
    
    private func loadLogs() {
        if let data = userDefaults.data(forKey: logsKey) {
            do {
                logs = try JSONDecoder().decode([SyncResult].self, from: data)
            } catch {
                print("Failed to load sync logs: \(error)")
                logs = []
            }
        }
    }
    
    private func saveLogs() {
        do {
            let data = try JSONEncoder().encode(logs)
            userDefaults.set(data, forKey: logsKey)
            userDefaults.synchronize()
        } catch {
            print("Failed to save sync logs: \(error)")
        }
    }
    
    func logSync(result: SyncResult) {
        var updatedLogs = logs
        updatedLogs.insert(result, at: 0)
        
        // Limit the number of logs
        if updatedLogs.count > maxLogEntries {
            updatedLogs = Array(updatedLogs.prefix(maxLogEntries))
        }
        
        logs = updatedLogs
        saveLogs()
    }
    
    func clearLogs() {
        logs = []
        saveLogs()
    }
}