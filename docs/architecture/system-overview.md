# HealthSync System Architecture

## Core Architecture (Phase 2 Complete)

```
HealthKit → HealthKitManager → MetricNormalizer → HealthMetric
    ↓              ↓                   ↓              ↓
Authorization   Query Data      Standardize      Unified Model
& Discovery     with Dates      Units & Names    for App/API Use
```

## Implemented Components ✅

### HealthKitManager (Task 1)
- **Purpose**: HealthKit integration with async/await
- **Key Methods**: `requestAuthorization()`, `fetchAvailableDataTypes()`, `fetchSamples()`
- **Pattern**: Singleton with proper error handling

### HealthMetric (Task 2)
- **Purpose**: Unified data model for all health data
- **Properties**: `id`, `name`, `identifier`, `value`, `unit`, `timestamp`, `category`, `source`
- **Features**: Codable, Identifiable, standardized units

### MetricNormalizer (Task 2)
- **Purpose**: Convert HKSample to HealthMetric
- **Features**: Unit standardization, categorization, human-readable names
- **Supports**: All 70+ HealthKit quantity types

### MetricCategory (Task 2)
- **Categories**: `vitals`, `activity`, `nutrition`, `sleep`, `lab`, `other`
- **Usage**: UI grouping and organization

### ConfigService (Task 4) ✅
- **Purpose**: Centralized settings and preference management
- **Key Features**: UserDefaults persistence, ObservableObject pattern
- **Data Models**: UserSettings, SyncDestination with Codable support

### UI Components (Task 3) ✅
- **ContentView**: Tab-based navigation (Metrics & Settings)
- **MetricsSelectionView**: Interactive metrics selection with categories
- **SettingsView**: Comprehensive configuration interface
- **AuthorizationView**: User-friendly HealthKit permission flow

## Planned Architecture (Tasks 5-6)

```
┌─────────────────────────────────────────────────────────────┐
│                    HealthSync iOS App                        │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (SwiftUI) - ✅ Complete                          │
│  ├── MetricsSelectionView ✅                               │
│  ├── SyncDestinationsView ✅                               │
│  └── SettingsView ✅                                       │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                       │
│  ├── HealthKitManager ✅                                   │
│  ├── MetricNormalizer ✅                                   │
│  ├── ConfigService ✅                                     │
│  ├── SyncEngine - Task 6                                  │
│  └── SyncTargets - Task 5                                 │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                 │
│  ├── HealthMetric ✅                                       │
│  ├── SyncDestination ✅                                   │
│  └── UserSettings ✅                                      │
├─────────────────────────────────────────────────────────────┤
│  External Integrations                                      │
│  ├── HealthKit Framework ✅                               │
│  ├── Supabase API - Task 5                                │
│  ├── Google Sheets API - Task 5                           │
│  └── Custom APIs - Task 5                                 │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Current (Tasks 1-2) ✅
1. User authorizes HealthKit access
2. App discovers available data types
3. Queries sample data for selected metrics
4. Normalizes to HealthMetric objects

### Current (Tasks 3-4) ✅
5. User selects metrics via UI
6. ConfigService saves preferences
7. UI displays categorized metrics

### Future (Tasks 5-6)
8. SyncEngine processes selected metrics
9. SyncTargets handle API integrations
10. Results logged and displayed

## Technical Standards

### Error Handling
- Custom error types with descriptive messages
- Graceful degradation for missing data
- Proper async/await error propagation

### Data Privacy
- No persistent health data storage
- Process-and-sync approach
- User-controlled data access

### Testing
- ~95% test coverage (43+ tests with simulator compatibility)
- Mock objects for external dependencies
- Comprehensive edge case testing
- Robust error handling for simulator environments

## Ready for Next Phase
**Foundation Status**: ✅ Complete (Tasks 1-2)  
**UI & Configuration**: ✅ Complete (Tasks 3-4)  
**Next Milestone**: Tasks 5-6 (Sync Implementation)  
**Available Components**: HealthKitManager, HealthMetric, MetricNormalizer, MetricCategory, ConfigService, Complete UI Framework

**Last Updated**: 2025-07-06