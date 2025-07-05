# HealthSync System Architecture Overview

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    HealthSync iOS App                        │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (SwiftUI)                                         │
│  ├── MetricsSelectionView                                   │
│  ├── SyncDestinationsView                                   │
│  ├── LogsView                                              │
│  └── SettingsView                                          │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                       │
│  ├── HealthKitManager (Task 1)                             │
│  ├── MetricNormalizer (Task 2)                             │
│  ├── SyncEngine                                            │
│  ├── ConfigService                                         │
│  └── Logger                                                │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                 │
│  ├── HealthMetric (Task 2)                                 │
│  ├── SyncDestination                                       │
│  ├── UserSettings                                          │
│  └── SyncResult                                            │
├─────────────────────────────────────────────────────────────┤
│  External Integrations                                      │
│  ├── HealthKit Framework                                    │
│  ├── Supabase API                                         │
│  ├── Google Sheets API                                     │
│  ├── Zapier Webhooks                                       │
│  └── Custom APIs                                           │
└─────────────────────────────────────────────────────────────┘
```

## Core Components (Tasks 1 & 2)

### HealthKitManager
- **Purpose**: Interface with Apple HealthKit framework
- **Responsibilities**:
  - Request and manage authorization
  - Fetch available health data types
  - Query health samples with date ranges
  - Handle HealthKit errors and permissions
- **Pattern**: Singleton
- **Key Methods**:
  - `requestAuthorization() async throws -> Bool`
  - `fetchAvailableDataTypes() -> [HKQuantityTypeIdentifier]`
  - `fetchSamples(for:startDate:endDate:) async throws -> [HKSample]`

### HealthMetric (Data Model)
- **Purpose**: Unified representation of health data
- **Properties**:
  - `id: UUID` - Unique identifier
  - `name: String` - Human-readable name
  - `identifier: String` - HealthKit identifier
  - `value: Double` - Standardized numeric value
  - `unit: String` - Standardized unit
  - `timestamp: Date` - Measurement timestamp
  - `source: String?` - Recording device/app
  - `category: MetricCategory` - Data classification

### MetricNormalizer
- **Purpose**: Convert HealthKit data to HealthMetric objects
- **Responsibilities**:
  - Standardize units across different metric types
  - Categorize metrics for UI organization
  - Map technical identifiers to readable names
  - Handle data validation and edge cases
- **Key Methods**:
  - `categorizeMetric(_:) -> MetricCategory`
  - `normalizeQuantitySample(_:) -> HealthMetric`
  - `normalizedValue(for:) -> Double`
  - `normalizedUnit(for:) -> String`

### MetricCategory (Enum)
- **Purpose**: Classify health metrics for UI organization
- **Categories**:
  - `vitals` - Heart rate, blood pressure, temperature
  - `activity` - Steps, distance, energy, flights
  - `nutrition` - Dietary metrics, water intake
  - `sleep` - Sleep analysis and stages
  - `lab` - Blood work, glucose, cholesterol
  - `other` - Uncategorized metrics

## Data Flow (Tasks 1 & 2)

```
HealthKit → HealthKitManager → MetricNormalizer → HealthMetric
    ↓              ↓                   ↓              ↓
Authorization   Query Data      Standardize      Unified Model
& Discovery     with Dates      Units & Names    for App Use
```

### Step-by-Step Process
1. **Authorization**: User grants HealthKit permissions
2. **Discovery**: App discovers available health data types
3. **Selection**: User chooses which metrics to sync
4. **Querying**: App fetches sample data for selected metrics
5. **Normalization**: Raw HealthKit data converted to HealthMetric objects
6. **Standardization**: Units and names standardized for consistency

## Error Handling Strategy

### HealthKitManager Errors
- `HealthKitError.notAvailable` - HealthKit not supported
- `HealthKitError.authorizationFailed` - User denied permission
- `HealthKitError.queryFailed` - Data query failed

### Data Validation
- Invalid samples filtered out during normalization
- Missing data handled gracefully
- Type safety enforced throughout pipeline

## Security & Privacy

### Data Handling
- No persistent storage of health data
- Process-and-sync approach
- Minimal data access (user-selected only)
- Secure transmission to configured destinations

### Permissions
- Clear usage descriptions in Info.plist
- Granular permission requests
- Respect user privacy preferences
- Transparent data usage

## Testing Strategy

### Unit Testing
- Mock HealthStore for isolated testing
- Test data conversion accuracy
- Validate error handling
- Performance benchmarking

### Integration Testing
- End-to-end data flow validation
- Real HealthKit integration (device only)
- Edge case handling
- Large dataset processing

## Future Architecture Considerations

### Scalability
- Background processing support
- Incremental sync capabilities
- Data caching strategies
- Performance optimization

### Extensibility
- Plugin architecture for new sync destinations
- Custom metric type support
- User-defined categories
- Configurable normalization rules

## Dependencies

### Task 1 Dependencies
- HealthKit framework
- iOS 16+ deployment target
- Proper Info.plist configuration

### Task 2 Dependencies
- Task 1 completion (HealthKitManager)
- Swift Codable protocol
- Foundation framework

## Status: Implementation in Progress
**Tasks 1 & 2 Focus**: Foundation layer implementation
**Next Phase**: UI layer and sync engine development

**Last Updated**: 2025-07-05