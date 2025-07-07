//
//  SettingsView.swift
//  HealthSync
//
//  Created by Hanson Wen on 5/7/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var configService = ConfigService.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Sync Configuration") {
                    NavigationLink("Sync Destinations") {
                        SyncDestinationConfigView()
                    }
                    
                    NavigationLink("Sync Preferences") {
                        SyncPreferencesView()
                    }
                }
                
                Section("Selected Metrics") {
                    HStack {
                        Text("Active Metrics")
                        Spacer()
                        Text("\(configService.userSettings.selectedMetrics.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastSync = configService.userSettings.lastSyncDate {
                        HStack {
                            Text("Last Sync")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Data Management") {
                    Button("Reset All Settings") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Settings", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    configService.resetSettings()
                }
            } message: {
                Text("This will reset all your preferences and sync destinations. This action cannot be undone.")
            }
        }
    }
}

struct SyncDestinationConfigView: View {
    @ObservedObject private var configService = ConfigService.shared
    
    var body: some View {
        Form {
            Section("Available Destinations") {
                ForEach(SyncDestination.DestinationType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.iconName)
                        Text(type.displayName)
                        Spacer()
                        Text("Coming Soon")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            
            Section("Configured Destinations") {
                if configService.userSettings.syncDestinations.isEmpty {
                    Text("No sync destinations configured")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(configService.userSettings.syncDestinations) { destination in
                        HStack {
                            Image(systemName: destination.type.iconName)
                            VStack(alignment: .leading) {
                                Text(destination.name)
                                Text(destination.type.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if destination.isEnabled {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Sync Destinations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SyncPreferencesView: View {
    @ObservedObject private var configService = ConfigService.shared
    
    private let intervalOptions: [(String, TimeInterval)] = [
        ("15 minutes", 900),
        ("30 minutes", 1800),
        ("1 hour", 3600),
        ("4 hours", 14400),
        ("12 hours", 43200),
        ("24 hours", 86400)
    ]
    
    var body: some View {
        Form {
            Section("Sync Frequency") {
                ForEach(intervalOptions, id: \.1) { option in
                    HStack {
                        Text(option.0)
                        Spacer()
                        if configService.userSettings.syncInterval == option.1 {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        configService.setSyncInterval(option.1)
                    }
                }
            }
            
            Section("Status") {
                HStack {
                    Text("Selected Metrics")
                    Spacer()
                    Text("\(configService.userSettings.selectedMetrics.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Active Destinations")
                    Spacer()
                    Text("\(configService.getEnabledDestinations().count)")
                        .foregroundColor(.secondary)
                }
                
                if let lastSync = configService.userSettings.lastSyncDate {
                    HStack {
                        Text("Last Sync")
                        Spacer()
                        Text(lastSync, style: .relative)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Sync Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}