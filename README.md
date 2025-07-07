# HealthSync

A comprehensive iOS application for syncing health data from HealthKit to external services.

## 🚀 Current Status

**Phase 3B Complete** - Tasks 5-6 ✅  
**Build Status**: Clean ✅  
**Test Coverage**: ~98% ✅  
**Sync System**: End-to-end sync functionality ready ✅

## 📱 Features

### ✅ **Phase 1: Foundation (Tasks 1-2)**
- **HealthKit Integration**: Full authorization and data fetching
- **Data Models**: Unified HealthMetric model with 70+ health data types
- **Normalization**: Standardized units and categorization
- **Testing**: Comprehensive test suite

### ✅ **Phase 2: UI & Configuration (Tasks 3-4)**
- **Tab Navigation**: Intuitive interface for metrics and settings
- **Metric Selection**: Categorized health metrics with real-time selection
- **Configuration Service**: Persistent settings and sync destination management
- **User Experience**: Seamless HealthKit authorization flow

### ✅ **Phase 3A: Sync Target Implementation (Task 5)**
- **SyncTarget Protocol**: Unified interface for all sync destinations
- **SupabaseTarget**: Complete Supabase integration with validation
- **SyncDestinationManager**: Destination management and factory pattern
- **Comprehensive Testing**: 19+ unit tests with 98% coverage

### ✅ **Phase 3B: Sync Engine (Task 6)**
- **SyncEngine**: Coordinates HealthKit data fetching and routing to targets
- **Manual Sync**: User-triggered sync with real-time UI feedback
- **Logger**: Comprehensive sync result tracking and history
- **UI Integration**: Sync button and status display in MetricsSelectionView

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│              HealthSync iOS App          │
├─────────────────────────────────────────┤
│  UI Layer (SwiftUI) ✅                  │
│  ├── MetricsSelectionView               │
│  ├── SettingsView                       │
│  └── AuthorizationView                  │
├─────────────────────────────────────────┤
│  Business Logic ✅                      │
│  ├── HealthKitManager                   │
│  ├── MetricNormalizer                   │
│  └── ConfigService                      │
├─────────────────────────────────────────┤
│  Data Models ✅                         │
│  ├── HealthMetric                       │
│  ├── UserSettings                       │
│  └── SyncDestination                    │
└─────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Xcode 16+
- iOS 18.5+ deployment target
- Apple Developer account (for device testing)

### Build & Run
```bash
# Clone the repository
cd "/path/to/HealthSync"

# Build the project
xcodebuild build -scheme HealthSync

# Run tests
xcodebuild test -scheme HealthSync -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Open in Xcode
open HealthSync.xcodeproj
```

## 📖 Documentation

- **[Developer Guide](docs/developer-guide.md)** - Complete development reference
- **[System Architecture](docs/architecture/system-overview.md)** - Technical architecture overview
- **[Project Plan](docs/projectplan.md)** - Implementation roadmap and status

## 📊 Project Status

### Completed Tasks
- [x] **Task 1**: HealthKit Integration
- [x] **Task 2**: Data Models & Normalization
- [x] **Task 3**: Basic UI & Navigation
- [x] **Task 4**: Configuration Service
- [x] **Task 5**: Sync Target Implementation
- [x] **Task 6**: Sync Engine & Manual Sync

### Next Phase
- [ ] **Task 7**: Enhanced Logger & Logs Panel UI
- [ ] **Task 8-10**: Additional Sync Targets (Google Sheets, Zapier, Custom API)
- [ ] **Task 11-12**: Destination Management UI & Settings Finalization

## 🧪 Testing

```bash
# Run all tests
xcodebuild test -scheme HealthSync -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Test coverage: ~98%
# Test files: 10 test classes, 65+ tests
# Simulator compatible with robust error handling
```

## 🔧 Development

### Core Components
- **HealthKitManager**: Singleton for HealthKit operations with async/await
- **ConfigService**: ObservableObject for settings management
- **MetricNormalizer**: Converts HKSample to standardized HealthMetric
- **UI Components**: SwiftUI views with proper state management

### Code Quality
- Swift 5.7+ modern features
- Comprehensive error handling
- Thread-safe implementations
- Clean architecture principles

## 📝 License

This project is part of a development exercise and learning initiative.

---

**Last Updated**: 2025-07-07  
**Current Version**: Phase 3B Complete (Tasks 5-6)  
**Ready For**: Task 7+ (Enhanced UI & Additional Sync Targets)