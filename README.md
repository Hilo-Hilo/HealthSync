# HealthSync

A comprehensive iOS application for syncing health data from HealthKit to external services.

## 🚀 Current Status

**Phase 2 Complete** - Tasks 3-4 ✅  
**Build Status**: Clean ✅  
**Test Coverage**: ~95% ✅  
**UI**: Fully functional ✅

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

### 🔄 **Phase 3: Sync Implementation (Tasks 5-6)**
- **Sync Targets**: Supabase, Google Sheets, Custom APIs
- **Background Sync**: Configurable intervals and error handling
- **Authentication**: OAuth flows for external services

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

### Next Phase
- [ ] **Task 5**: Sync Target Implementation
- [ ] **Task 6**: Sync Engine & Scheduling

## 🧪 Testing

```bash
# Run all tests
xcodebuild test -scheme HealthSync -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Test coverage: ~95%
# Test files: 5 test classes, 43+ tests
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

**Last Updated**: 2025-07-06  
**Current Version**: Phase 2 Complete  
**Ready For**: Tasks 5-6 (Sync Implementation)