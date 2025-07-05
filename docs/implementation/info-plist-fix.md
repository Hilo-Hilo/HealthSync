# Info.plist Fix - Step by Step

## The Problem
The exact error shows: `The Copy Bundle Resources build phase contains this target's Info.plist file`

This means Info.plist is being processed TWICE:
1. As the target's Info.plist file (correct)
2. In the Copy Bundle Resources phase (incorrect - causing duplicate)

## Exact Solution

### Step 1: Open Xcode Project
1. Open `HealthSync.xcodeproj` in Xcode
2. In the Project Navigator, click on the **HealthSync project** (top level)
3. Select the **HealthSync target** (under TARGETS)

### Step 2: Remove from Copy Bundle Resources
1. Click on **Build Phases** tab
2. Expand **Copy Bundle Resources** section
3. **Look for `Info.plist` in the list**
4. **Select `Info.plist`** and click the **`-` (minus) button** to remove it
5. Info.plist should NO LONGER appear in Copy Bundle Resources

### Step 3: Verify Build Settings
1. Click on **Build Settings** tab
2. Search for "**Info.plist File**"
3. Make sure it shows: `HealthSync/Info.plist` (this is correct)
4. Search for "**Generate Info.plist File**"
5. Make sure it's set to **NO** (since we have our own)

### Step 4: Clean and Build
1. Go to **Product** > **Clean Build Folder**
2. Try building again with **Product** > **Build** (or `Cmd+B`)

## Expected Result
After removing Info.plist from Copy Bundle Resources, the build should succeed.

## If Still Failing
If it still fails, try this alternative:
1. Delete the manual `HealthSync/Info.plist` file
2. Set "Generate Info.plist File" to **YES**
3. Add the HealthKit permissions in the project's Info.plist section in Xcode

## Next: Configure Tests
Once the build succeeds:
1. Edit the scheme to include tests
2. Product > Test (or `Cmd+U`) should work