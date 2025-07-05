# Build Issues and Fixes

## Compilation Errors Fixed

### 1. Swift Concurrency Issues
**Error**: `Capture of 'self' with non-sendable type 'HealthKitManager' in a '@Sendable' closure`
**Fix**: Added `@MainActor` and `@unchecked Sendable` to HealthKitManager class
```swift
@MainActor
class HealthKitManager: @unchecked Sendable {
```

### 2. Protocol Conformance Warning
**Error**: `Extension declares a conformance of imported type 'HKQuantityTypeIdentifier' to imported protocol 'CaseIterable'`
**Fix**: Added `@retroactive` attribute
```swift
extension HKQuantityTypeIdentifier: @retroactive CaseIterable {
```

### 3. Incorrect HealthKit Identifier
**Error**: `Type 'HKQuantityTypeIdentifier' has no member 'dietaryPantothenicAid'`
**Fix**: Corrected to `dietaryPantothenicAcid` (spelling error)

### 4. Optional Binding Issue
**Error**: `Initializer for conditional binding must have Optional type, not 'HKQuantityTypeIdentifier'`
**Fix**: Added proper optional handling
```swift
guard let identifier = HKQuantityTypeIdentifier(rawValue: type.identifier) else {
    return sample.quantity.doubleValue(for: HKUnit.count())
}
```

### 5. Invalid Property Access
**Error**: `Value of type 'HKQuantity' has no member 'unit'`
**Fix**: Removed invalid property access and used HKUnit.count() as default

### 6. Info.plist Conflict
**Error**: `Multiple commands produce Info.plist`
**Issue**: Xcode project may have auto-generated Info.plist conflicting with manual one
**Solution**: Need to configure project build settings properly in Xcode

## Remaining Issues to Address

1. **Info.plist Duplicate**: Check Xcode project settings for Info.plist configuration
2. **Test Target**: Ensure test target is properly configured in Xcode scheme

## Files Modified
- `HealthSync/HealthKitManager.swift`: Fixed concurrency and conformance issues
- `HealthSync/MetricNormalizer.swift`: Fixed optional binding and property access issues

## Status
- ✅ Swift compilation errors fixed
- ⚠️ Info.plist conflict needs Xcode configuration
- ⚠️ Test target needs proper setup

## Info.plist Conflict Resolution

**Problem**: Xcode is generating an automatic Info.plist AND trying to use our manual one, causing a conflict.

**Solutions** (try in order):

### Option 1: Remove Manual Info.plist Reference
1. Open `HealthSync.xcodeproj` in Xcode
2. Select the project (HealthSync) in navigator
3. Select the HealthSync target
4. Go to **Build Settings**
5. Search for "Info.plist File"
6. Clear the value (it might be pointing to `HealthSync/Info.plist`)
7. Let Xcode auto-generate the Info.plist

### Option 2: Keep Manual Info.plist
1. In Build Settings, ensure "Info.plist File" points to `HealthSync/Info.plist`
2. Set "Generate Info.plist File" to **NO**
3. Clean build folder (Product > Clean Build Folder)

### Option 3: Remove File from Copy Bundle Phase
1. Select target → Build Phases
2. Look for "Copy Bundle Resources"
3. Remove `Info.plist` if it's listed there

## Test Configuration

Once Info.plist is fixed:
1. Create Unit Testing Bundle target if not exists
2. Add test files to HealthSyncTests target
3. Configure scheme to include tests
4. Run tests with `Cmd+U`

## Next Steps
1. Open project in Xcode
2. Fix Info.plist conflict using options above
3. Configure test target properly
4. Run tests to verify fixes