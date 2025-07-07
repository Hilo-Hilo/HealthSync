//
//  ContentView.swift
//  HealthSync
//
//  Created by Hanson Wen on 5/7/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MetricsSelectionView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Metrics")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
}
