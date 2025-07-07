//
//  SupabaseTarget.swift
//  HealthSync
//
//  Created by Hanson Wen on 7/7/2025.
//

import Foundation

// MARK: - SupabaseTarget
class SupabaseTarget: SyncTarget {
    let id: UUID
    let name: String
    let type: SyncDestinationType = .supabase
    var isEnabled: Bool
    var config: [String: String]
    
    // Required config keys
    private let urlKey = "url"
    private let apiKeyKey = "apiKey"
    private let tableNameKey = "tableName"
    
    init(destination: SyncDestination) {
        self.id = destination.id
        self.name = destination.name
        self.isEnabled = destination.isEnabled
        self.config = destination.configuration
    }
    
    func validate() -> Bool {
        guard let url = config[urlKey], !url.isEmpty,
              let apiKey = config[apiKeyKey], !apiKey.isEmpty,
              let tableName = config[tableNameKey], !tableName.isEmpty else {
            return false
        }
        
        // Validate URL format - must be a valid HTTP/HTTPS URL
        guard let validURL = URL(string: url),
              validURL.scheme == "http" || validURL.scheme == "https",
              validURL.host != nil else {
            return false
        }
        
        return true
    }
    
    func sync(metrics: [HealthMetric]) async throws -> SyncResult {
        guard validate() else {
            return SyncResult(
                timestamp: Date(),
                success: false,
                destination: type,
                metricsCount: metrics.count,
                errorMessage: "Invalid configuration: Missing URL, API key, or table name",
                responseCode: nil,
                responseBody: nil
            )
        }
        
        guard let url = URL(string: "\(config[urlKey]!)/rest/v1/\(config[tableNameKey]!)") else {
            throw SyncError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(config[apiKeyKey]!, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(config[apiKeyKey]!)", forHTTPHeaderField: "Authorization")
        request.addValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        // Convert metrics to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(metrics)
            request.httpBody = jsonData
        } catch {
            return SyncResult(
                timestamp: Date(),
                success: false,
                destination: type,
                metricsCount: metrics.count,
                errorMessage: "Failed to encode metrics: \(error.localizedDescription)",
                responseCode: nil,
                responseBody: nil
            )
        }
        
        // Perform request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SyncError.invalidResponse
            }
            
            let success = (200...299).contains(httpResponse.statusCode)
            let responseBody = String(data: data, encoding: .utf8)
            
            return SyncResult(
                timestamp: Date(),
                success: success,
                destination: type,
                metricsCount: metrics.count,
                errorMessage: success ? nil : "HTTP Error: \(httpResponse.statusCode)",
                responseCode: httpResponse.statusCode,
                responseBody: responseBody
            )
        } catch {
            return SyncResult(
                timestamp: Date(),
                success: false,
                destination: type,
                metricsCount: metrics.count,
                errorMessage: "Network error: \(error.localizedDescription)",
                responseCode: nil,
                responseBody: nil
            )
        }
    }
}