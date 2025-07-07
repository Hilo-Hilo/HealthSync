//
//  MetricsSelectionView.swift
//  HealthSync
//
//  Created by Hanson Wen on 5/7/2025.
//

import SwiftUI
import HealthKit

struct MetricsSelectionView: View {
    @State private var isAuthorized = false
    @State private var availableMetrics: [HKQuantityTypeIdentifier] = []
    @State private var selectedMetrics: Set<HKQuantityTypeIdentifier> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @ObservedObject private var configService = ConfigService.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if !isAuthorized {
                    AuthorizationView { authorized in
                        isAuthorized = authorized
                        if authorized {
                            loadAvailableMetrics()
                        }
                    }
                } else {
                    if isLoading {
                        ProgressView("Loading health metrics...")
                            .padding()
                    } else {
                        MetricCategoryListView(
                            availableMetrics: availableMetrics,
                            selectedMetrics: $selectedMetrics
                        )
                    }
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Health Metrics")
            .onAppear {
                checkAuthorizationStatus()
                loadSavedMetrics()
            }
            .onChange(of: selectedMetrics) { oldValue, newValue in
                configService.updateSelectedMetrics(newValue)
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        Task { @MainActor in
            isAuthorized = HealthKitManager.shared.isAuthorized
            if isAuthorized {
                loadAvailableMetrics()
            }
        }
    }
    
    private func loadAvailableMetrics() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            availableMetrics = HealthKitManager.shared.fetchAvailableDataTypes()
            isLoading = false
        }
    }
    
    private func loadSavedMetrics() {
        selectedMetrics = configService.getSelectedMetrics()
    }
}

struct AuthorizationView: View {
    let onAuthorization: (Bool) -> Void
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("HealthKit Access Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("HealthSync needs access to your Health data to sync your metrics.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: requestAuthorization) {
                HStack {
                    if isRequesting {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isRequesting ? "Requesting..." : "Grant Access")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isRequesting)
        }
        .padding()
    }
    
    private func requestAuthorization() {
        isRequesting = true
        
        Task {
            do {
                let success = try await HealthKitManager.shared.requestAuthorization()
                await MainActor.run {
                    isRequesting = false
                    onAuthorization(success)
                }
            } catch {
                await MainActor.run {
                    isRequesting = false
                    onAuthorization(false)
                }
            }
        }
    }
}

struct MetricCategoryListView: View {
    let availableMetrics: [HKQuantityTypeIdentifier]
    @Binding var selectedMetrics: Set<HKQuantityTypeIdentifier>
    
    private var groupedMetrics: [MetricCategory: [HKQuantityTypeIdentifier]] {
        var groups: [MetricCategory: [HKQuantityTypeIdentifier]] = [:]
        
        for metric in availableMetrics {
            let category = MetricNormalizer.categorizeMetric(metric)
            if groups[category] == nil {
                groups[category] = []
            }
            groups[category]?.append(metric)
        }
        
        return groups
    }
    
    var body: some View {
        List {
            ForEach(MetricCategory.allCases, id: \.self) { category in
                if let metrics = groupedMetrics[category], !metrics.isEmpty {
                    Section(header: Text(category.displayName)) {
                        ForEach(metrics, id: \.self) { metric in
                            MetricRowView(
                                metric: metric,
                                isSelected: selectedMetrics.contains(metric)
                            ) { isSelected in
                                if isSelected {
                                    selectedMetrics.insert(metric)
                                } else {
                                    selectedMetrics.remove(metric)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct MetricRowView: View {
    let metric: HKQuantityTypeIdentifier
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    private var displayName: String {
        MetricNormalizer.humanReadableName(for: metric)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(displayName)
                    .font(.body)
                Text(metric.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { onToggle($0) }
            ))
        }
        .padding(.vertical, 2)
    }
}


#Preview {
    MetricsSelectionView()
}