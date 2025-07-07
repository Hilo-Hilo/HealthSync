//
//  SyncTarget.swift
//  HealthSync
//
//  Created by Hanson Wen on 7/7/2025.
//

import Foundation

// MARK: - SyncTarget Protocol
protocol SyncTarget {
    var id: UUID { get }
    var name: String { get }
    var type: SyncDestinationType { get }
    var isEnabled: Bool { get set }
    var config: [String: String] { get set }
    
    func sync(metrics: [HealthMetric]) async throws -> SyncResult
    func validate() -> Bool
}

// MARK: - SyncDestinationType
enum SyncDestinationType: String, Codable, CaseIterable {
    case supabase
    case googleSheets
    case zapier
    case customAPI
    
    var displayName: String {
        switch self {
        case .supabase: return "Supabase"
        case .googleSheets: return "Google Sheets"
        case .zapier: return "Zapier"
        case .customAPI: return "Custom API"
        }
    }
    
    var iconName: String {
        switch self {
        case .supabase: return "externaldrive.fill"
        case .googleSheets: return "doc.fill"
        case .zapier: return "bolt.fill"
        case .customAPI: return "cloud.fill"
        }
    }
}

// MARK: - SyncResult
struct SyncResult: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let success: Bool
    let destination: SyncDestinationType
    let metricsCount: Int
    let errorMessage: String?
    let responseCode: Int?
    let responseBody: String?
    
    init(timestamp: Date, success: Bool, destination: SyncDestinationType, metricsCount: Int, errorMessage: String? = nil, responseCode: Int? = nil, responseBody: String? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.success = success
        self.destination = destination
        self.metricsCount = metricsCount
        self.errorMessage = errorMessage
        self.responseCode = responseCode
        self.responseBody = responseBody
    }
}

// MARK: - SyncError
enum SyncError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case configurationError
    case networkError(Error)
    case invalidConfiguration(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid response from server"
        case .configurationError:
            return "Configuration error"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        }
    }
}