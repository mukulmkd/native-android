# How to Monitor React Native Build Status

## Quick Check Script

Run this anytime to check build status:
```bash
./scripts/check-build-status.sh
```

## Manual Checks

### 1. Check if Build Process is Running
```bash
# Check for Gradle processes
ps aux | grep gradle | grep -v grep

# Check for React Native specific builds
ps aux | grep "ReactAndroid\|hermes" | grep -v grep
```

### 2. Check Gradle Daemon Logs
```bash
# View latest Gradle daemon output
tail -f ~/.gradle/daemon/*/out.log

# Or find the latest log
ls -lt ~/.gradle/daemon/*/out.log | head -1 | awk '{print $NF}' | xargs tail -f
```

### 3. Check for Built Artifacts in Maven Local
```bash
# Check if React Native artifacts exist
ls -la ~/.m2/repository/com/facebook/react/react-android/0.81.5/
ls -la ~/.m2/repository/com/facebook/react/hermes-android/0.81.5/

# Check for executor library in React Native build
find js/node_modules/react-native/ReactAndroid/build -name "*hermes_executor*" 2>/dev/null
```

### 4. Check React Native Build Directory
```bash
# Check build progress
ls -lh js/node_modules/react-native/ReactAndroid/build/outputs/

# Check if native libraries are being built
find js/node_modules/react-native/ReactAndroid/build -name "*.so" 2>/dev/null | head -10
```

## Signs Build is Complete

✅ **Build is Complete When:**
1. No Gradle processes running (for React Native build)
2. Artifacts exist in `~/.m2/repository/com/facebook/react/`
3. Executor library exists: `js/node_modules/react-native/ReactAndroid/build/.../libhermes_executor.so`
4. You can see "BUILD SUCCESSFUL" in logs

## Starting the Build

If build hasn't started or failed, start it manually:

```bash
# From project root
./scripts/build-react-native.sh

# Or manually:
cd js/node_modules/react-native

# Set Android SDK (if not in local.properties)
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# Build and publish React Native
./gradlew :packages:react-native:ReactAndroid:publishToMavenLocal \
          :packages:react-native:ReactAndroid:hermes-engine:publishToMavenLocal

# This will take 10-30+ minutes on first build
```

## After Build Completes

1. **Rebuild your app:**
   ```bash
   ./gradlew :app:clean :app:assembleDebug
   ```

2. **Verify executor is included:**
   ```bash
   unzip -l app/build/outputs/apk/debug/app-debug.apk | grep hermes_executor
   ```

3. **Install and test:**
   ```bash
   ./gradlew :app:installDebug
   ```

## Build Time Estimates

- **First build:** 10-30+ minutes (downloads dependencies, builds everything)
- **Subsequent builds:** 1-5 minutes (incremental, only changed files)

## Troubleshooting

### Build Failed?
Check the error:
```bash
# Check last build log
tail -100 ~/.gradle/daemon/*/out.log

# Or rebuild with verbose output
cd js/node_modules/react-native
./gradlew :packages:react-native:ReactAndroid:publishToMavenLocal --stacktrace
```

### Build Stuck?
```bash
# Kill all Gradle processes
pkill -f gradle

# Clean and retry
cd js/node_modules/react-native
./gradlew clean
./gradlew :packages:react-native:ReactAndroid:publishToMavenLocal
```

