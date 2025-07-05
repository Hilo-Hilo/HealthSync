# Test Troubleshooting Guide

## No Test Output Issue

If you're not seeing test output even after build succeeds, here are the steps:

### Step 1: Verify Test Target Configuration
1. In Xcode, go to **Product** > **Scheme** > **Edit Scheme**
2. Select **Test** in the left sidebar
3. Make sure `HealthSyncTests` is listed and **checked ✅**
4. If not, click **+** and add `HealthSyncTests`

### Step 2: Check Test File Target Membership
For each test file (`HealthKitManagerTests.swift`, etc.):
1. Select the file in Project Navigator
2. In **File Inspector** (right panel), check **Target Membership**
3. Ensure **HealthSyncTests** is checked ✅
4. Ensure **HealthSync** (main target) is **unchecked** ❌

### Step 3: Verify Test Bundle Settings
1. Select **HealthSyncTests target** in project settings
2. Go to **Build Settings**
3. Search for "**Host Application**"
4. Make sure it's set to `HealthSync`

### Step 4: Run Tests
Try these commands in order:

**In Xcode:**
- `Cmd + U` (Run Tests)
- Or **Product** > **Test**

**Command Line:**
```bash
cd "/Users/hansonwen/random code/HealthSync"
xcodebuild test -scheme HealthSync -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Step 5: Check Console Output
1. When running tests, open **Console** (View > Debug Area > Activate Console)
2. Look for test output there
3. Or check **Test Navigator** (`Cmd + 6`) for test results

## Expected Test Output
You should see ~32 tests across 4 classes:
- HealthKitManagerTests: 8 tests
- HealthMetricTests: 7 tests  
- MetricCategoryTests: 6 tests
- MetricNormalizerTests: 11 tests

## If Tests Still Don't Work
1. Delete HealthSyncTests target
2. Create new Unit Testing Bundle target
3. Add our test files to the new target
4. Configure scheme again