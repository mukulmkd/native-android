#!/bin/bash
# Script to check React Native build status

echo "=== Checking React Native Build Status ==="
echo ""

# Check if gradle process is running
if pgrep -f "gradle.*ReactAndroid" > /dev/null; then
    echo "✅ React Native build is IN PROGRESS"
    echo ""
    echo "Running Gradle processes:"
    ps aux | grep -E "gradle.*ReactAndroid|gradle.*hermes" | grep -v grep | head -5
    echo ""
    echo "To see live progress, check the build log:"
    echo "  tail -f ~/.gradle/daemon/*/out.log"
else
    echo "❌ No React Native build process found"
    echo ""
    echo "The build may have:"
    echo "  - Completed successfully"
    echo "  - Failed with an error"
    echo "  - Not started yet"
    echo ""
fi

echo ""
echo "=== Checking for Built Artifacts ==="

# Check if React Native artifacts are in mavenLocal
RN_ARTIFACTS=$(find ~/.m2/repository/com/facebook/react -name "react-android-0.81.5*" -o -name "hermes-android-0.81.5*" 2>/dev/null | head -5)

if [ -n "$RN_ARTIFACTS" ]; then
    echo "✅ Found React Native artifacts in Maven Local:"
    echo "$RN_ARTIFACTS" | head -5
    echo ""
    echo "React Native has been built and published!"
else
    echo "❌ No React Native artifacts found in Maven Local"
    echo "   Location: ~/.m2/repository/com/facebook/react/"
    echo ""
    echo "The build may still be in progress or hasn't started."
fi

echo ""
echo "=== Checking for Executor Library ==="

# Check if executor library exists in React Native build
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXECUTOR=$(find "$SCRIPT_DIR/js/node_modules/react-native/ReactAndroid/build" -name "*hermes_executor*" 2>/dev/null | head -3)

if [ -n "$EXECUTOR" ]; then
    echo "✅ Found executor library in React Native build:"
    echo "$EXECUTOR" | head -3
else
    echo "❌ Executor library not found yet"
    echo "   This will be built as part of the React Native build process"
fi

echo ""
echo "=== Next Steps ==="
echo "1. If build is complete, rebuild your app:"
echo "   ./gradlew :app:clean :app:assembleDebug"
echo ""
echo "2. Check if executor is in the APK:"
echo "   unzip -l app/build/outputs/apk/debug/app-debug.apk | grep hermes_executor"
echo ""
echo "3. Install and test:"
echo "   ./gradlew :app:installDebug"

