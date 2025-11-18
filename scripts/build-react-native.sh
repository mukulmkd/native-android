#!/bin/bash
# Build React Native from source and publish to Maven Local

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Set Android SDK
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# Set CMake path (use Homebrew CMake if available)
CMAKE_BREW=$(brew --prefix cmake 2>/dev/null)
if [ -n "$CMAKE_BREW" ] && [ -d "$CMAKE_BREW" ]; then
    export CMAKE_PATH="$CMAKE_BREW"
    echo "Using CMake from Homebrew: $CMAKE_PATH"
fi

if [ ! -d "$ANDROID_HOME" ]; then
    echo "Error: Android SDK not found at $ANDROID_HOME"
    echo "Please set ANDROID_HOME or install Android SDK"
    exit 1
fi

echo "========================================="
echo "Building React Native from Source"
echo "========================================="
echo "Android SDK: $ANDROID_HOME"
echo "This will take 10-30+ minutes on first build..."
echo ""

# Copy gradlew to React Native directory if it doesn't exist
RN_DIR="$SCRIPT_DIR/js/node_modules/react-native"
if [ ! -f "$RN_DIR/gradlew" ]; then
    echo "Setting up React Native build environment..."
    cp "$SCRIPT_DIR/gradlew" "$RN_DIR/"
    cp -r "$SCRIPT_DIR/gradle" "$RN_DIR/" 2>/dev/null || true
    chmod +x "$RN_DIR/gradlew"
fi

# Verify React Native settings includes the plugin build
RN_SETTINGS="$RN_DIR/settings.gradle.kts"
if ! grep -q "includeBuild.*gradle-plugin" "$RN_SETTINGS" 2>/dev/null; then
    echo "⚠️  Warning: React Native settings.gradle.kts doesn't include the plugin build"
    echo "   This should have been configured automatically. Please check the file."
fi

# Build React Native from its own directory
cd "$RN_DIR"

echo "Building ReactAndroid and Hermes Engine..."
echo "This is a long-running process. You can monitor progress in another terminal."
echo ""

# Build and publish to Maven Local
./gradlew :packages:react-native:ReactAndroid:publishToMavenLocal \
          :packages:react-native:ReactAndroid:hermes-engine:publishToMavenLocal

cd "$SCRIPT_DIR"

echo ""
echo "========================================="
echo "✅ React Native build complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Rebuild your app:"
echo "   ./gradlew :app:clean :app:assembleDebug"
echo ""
echo "2. Check for executor library:"
echo "   unzip -l app/build/outputs/apk/debug/app-debug.apk | grep hermes_executor"
echo ""
echo "3. Install and test:"
echo "   ./gradlew :app:installDebug"

