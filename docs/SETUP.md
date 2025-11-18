# React Native Integration Setup Summary

## What We Accomplished

### 1. **Built React Native from Source**
   - Built React Native 0.81.5 and Hermes engine from source
   - Published artifacts to Maven Local (`~/.m2/repository`)
   - This ensures the Hermes executor library is available (not included in pre-built AARs)

### 2. **Fixed Native Library Loading**
   - Configured SoLoader with `OpenSourceMergedSoMapping` to map `hermes_executor` → `hermestooling`
   - The executor library is merged into `libhermestooling.so`, not a separate library

### 3. **Fixed Android SDK Path Detection**
   - Modified React Native's `hermes-engine/build.gradle.kts` to read from `local.properties` files
   - This allows Android Studio sync to work without environment variables

### 4. **Aligned Versions**
   - Downgraded Android Gradle Plugin from 8.13.0 to 8.11.0 to match React Native
   - Fixed React version mismatch (19.2.0 → 19.1.0) to match `react-native-renderer`

### 5. **Fixed Module Registration**
   - Updated `js/index.js` to properly import `@app/module-products` which triggers AppRegistry registration
   - The module registers itself with AppRegistry when imported

### 6. **Added Required Permissions**
   - Added `INTERNET` permission to `AndroidManifest.xml` for network requests

## Files Modified

### Permanent Changes (in your project)
- `app/src/main/java/com/dummyapp/nativeandroid/MainApplication.kt`
  - Added `OpenSourceMergedSoMapping` to SoLoader initialization
  
- `app/src/main/AndroidManifest.xml`
  - Added `INTERNET` permission

- `build.gradle`
  - Changed AGP version to 8.11.0

- `gradle.properties`
  - Added Android SDK path properties

- `js/package.json`
  - Fixed React version to 19.1.0
  - Added `postinstall` script for automatic fixes

- `js/index.js`
  - Updated to import module-products for AppRegistry registration

- `local.properties`
  - Contains Android SDK path

- `scripts/fix-react-native-sdk-path.sh`
  - Script to re-apply React Native fixes after npm install

### Temporary Changes (in node_modules - will be lost on npm install)
- `js/node_modules/react-native/ReactAndroid/hermes-engine/build.gradle.kts`
  - Modified `getSDKPath()` to read from `local.properties` files
- `js/node_modules/react-native/gradle/wrapper/gradle-wrapper.properties`
  - Updated Gradle version to 8.13

## Handling Fresh npm install

Since we modified files in `node_modules`, these changes will be lost when you run `npm install`. Here are your options:

### Option 1: Use patch-package (Recommended)

1. **Install patch-package:**
   ```bash
   cd /Users/mukulkishore/Desktop/native-android/js
   npm install --save-dev patch-package
   ```

2. **Create a patch:**
   ```bash
   npx patch-package react-native
   ```
   This creates a patch file in `js/patches/react-native+0.81.5.patch`

3. **Add postinstall script to package.json:**
   ```json
   {
     "scripts": {
       "postinstall": "patch-package"
     }
   }
   ```

4. **Commit the patch file:**
   ```bash
   git add js/patches/
   git commit -m "Add patch for React Native SDK path detection"
   ```

### Option 2: Manual Re-application Script

Create a script that re-applies the changes after npm install:

```bash
#!/bin/bash
# scripts/fix-react-native-sdk-path.sh

RN_DIR="js/node_modules/react-native/ReactAndroid/hermes-engine"
BUILD_FILE="$RN_DIR/build.gradle.kts"

if [ -f "$BUILD_FILE" ]; then
  # Check if already patched
  if ! grep -q "Fall back to local.properties" "$BUILD_FILE"; then
    echo "Applying React Native SDK path fix..."
    # Apply the patch (you'll need to save the exact changes)
    # This is a simplified version - you'll need the full patch
    sed -i.bak 's/else -> throw IllegalStateException("Neither ANDROID_SDK_ROOT nor ANDROID_HOME is set.")/else -> throw IllegalStateException("Neither ANDROID_SDK_ROOT nor ANDROID_HOME is set, and no local.properties found.")/' "$BUILD_FILE"
    # ... (full patch would go here)
  fi
fi
```

### Option 3: Fork React Native (Not Recommended)

Fork React Native, make the changes, and use your fork. This is overkill for this use case.

## Recommended Approach

**Use patch-package (Option 1)** - it's the standard solution for this problem and will automatically re-apply patches after `npm install`.

✅ **Already Set Up**: We've created a re-application script at `scripts/fix-react-native-sdk-path.sh` and added it to the `postinstall` script in `package.json`. The fix will automatically apply after every `npm install`.

**Note**: If the automatic fix fails, you can manually run:
```bash
bash scripts/fix-react-native-sdk-path.sh
```

This script fixes:
- React Native SDK path detection (reads from `local.properties`)
- Gradle wrapper version (updates to 8.13)

## Setup Checklist for New Developers

1. ✅ Install dependencies: `cd js && npm install` (automatically applies fixes via postinstall script)
2. ✅ Ensure `local.properties` exists with `sdk.dir` set
3. ✅ Build React Native from source: `./build-react-native.sh` (first time only, 10-30 min)
4. ✅ Sync project in Android Studio
5. ✅ Bundle JS modules: `cd js && npm run bundle:products`
6. ✅ Build and run: `./gradlew :app:assembleDebug :app:installDebug`

## Key Learnings

1. **React Native from source** is needed for full Hermes support in standalone apps
2. **SoLoader mapping** is required for merged native libraries
3. **Version alignment** is critical (AGP, React, React Native)
4. **local.properties** is essential for Android Studio sync
5. **AppRegistry registration** happens when modules are imported

