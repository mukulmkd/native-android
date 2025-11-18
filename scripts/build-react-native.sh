#!/bin/bash
# Build React Native from source and publish to Maven Local

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

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

# Check if node_modules exists (required before building)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
JS_DIR="$PROJECT_ROOT/js"
NODE_MODULES_DIR="$JS_DIR/node_modules"

if [ ! -d "$NODE_MODULES_DIR" ]; then
    echo "❌ Error: node_modules not found!"
    echo ""
    echo "You must install JavaScript dependencies first:"
    echo ""
    echo "  1. Navigate to js directory:"
    echo "     cd $JS_DIR"
    echo ""
    echo "  2. Install dependencies:"
    echo "     npm install --legacy-peer-deps"
    echo ""
    echo "  3. Then return here and run this script again:"
    echo "     cd $PROJECT_ROOT"
    echo "     ./scripts/build-react-native.sh"
    echo ""
    exit 1
fi

# Check if React Native is installed
RN_DIR="$NODE_MODULES_DIR/react-native"
if [ ! -d "$RN_DIR" ]; then
    echo "❌ Error: react-native not found in node_modules!"
    echo ""
    echo "Please ensure you've installed dependencies:"
    echo "  cd $JS_DIR"
    echo "  npm install --legacy-peer-deps"
    echo ""
    exit 1
fi

# Copy gradlew to React Native directory if it doesn't exist
if [ ! -f "$RN_DIR/gradlew" ]; then
    echo "Setting up React Native build environment..."
    cp "$PROJECT_ROOT/gradlew" "$RN_DIR/"
    cp -r "$PROJECT_ROOT/gradle" "$RN_DIR/" 2>/dev/null || true
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

cd "$PROJECT_ROOT"

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

