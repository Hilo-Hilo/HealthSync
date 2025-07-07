//
//  SyncButton.swift
//  HealthSync
//
//  Created by Hanson Wen on 7/7/2025.
//

import SwiftUI

// MARK: - SyncButton Component
struct SyncButton: View {
    @ObservedObject private var syncEngine = SyncEngine.shared
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if syncEngine.isSyncing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Syncing...")
                } else {
                    Image(systemName: "arrow.clockwise")
                    Text("Sync Now")
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(syncEngine.canSync() ? Color.blue : Color.gray)
            .cornerRadius(8)
        }
        .disabled(!syncEngine.canSync())
    }
}

// MARK: - SyncStatusView
struct SyncStatusView: View {
    @ObservedObject private var syncEngine = SyncEngine.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Sync Status")
                .font(.headline)
            
            Text(syncEngine.getSyncStatus())
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !syncEngine.lastSyncResults.isEmpty {
                HStack {
                    let successCount = syncEngine.lastSyncResults.filter { $0.success }.count
                    let failureCount = syncEngine.lastSyncResults.count - successCount
                    
                    if successCount > 0 {
                        Label("\(successCount)", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    if failureCount > 0 {
                        Label("\(failureCount)", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SyncButton {
            print("Sync button tapped")
        }
        
        SyncStatusView()
    }
    .padding()
}