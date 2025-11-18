#!/bin/bash
# Fix React Native SDK path detection and Gradle version after npm install
# This script re-applies the changes to hermes-engine/build.gradle.kts and updates Gradle wrapper

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RN_BUILD_FILE="$SCRIPT_DIR/../js/node_modules/react-native/ReactAndroid/hermes-engine/build.gradle.kts"
RN_GRADLE_WRAPPER="$SCRIPT_DIR/../js/node_modules/react-native/gradle/wrapper/gradle-wrapper.properties"

if [ ! -f "$RN_BUILD_FILE" ]; then
    echo "Error: React Native build file not found at $RN_BUILD_FILE"
    echo "Make sure you've run 'npm install' in the js/ directory first"
    exit 1
fi

# Check if already patched
if grep -q "Fall back to local.properties files" "$RN_BUILD_FILE"; then
    echo "✅ React Native SDK path fix already applied"
    exit 0
fi

echo "Applying React Native SDK path fix..."

# Use Python to apply the fix (more reliable than sed for complex replacements)
# Pass file path as environment variable since heredoc doesn't pass arguments to sys.argv
RN_BUILD_FILE="$RN_BUILD_FILE" python3 << 'PYTHON_SCRIPT'
import sys
import os
import re

# Get file path from environment variable instead of sys.argv
file_path = os.environ.get('RN_BUILD_FILE')
if not file_path:
    print("Error: RN_BUILD_FILE environment variable not set")
    sys.exit(1)

with open(file_path, 'r') as f:
    content = f.read()

# Check if already patched
if "Fall back to local.properties files" in content:
    print("✅ Already patched")
    sys.exit(0)

# Find the getSDKPath function and replace it
old_pattern = r'fun getSDKPath\(\): String \{\s+val androidSdkRoot = System\.getenv\("ANDROID_SDK_ROOT"\)\s+val androidHome = System\.getenv\("ANDROID_HOME"\)\s+return when \{\s+!androidSdkRoot\.isNullOrBlank\(\) -> androidSdkRoot\s+!androidHome\.isNullOrBlank\(\) -> androidHome\s+else -> throw IllegalStateException\("Neither ANDROID_SDK_ROOT nor ANDROID_HOME is set\."\)\s+\}\s+\}'

new_function = '''fun getSDKPath(): String {
  val androidSdkRoot = System.getenv("ANDROID_SDK_ROOT")
  val androidHome = System.getenv("ANDROID_HOME")
  
  // Try environment variables first
  when {
    !androidSdkRoot.isNullOrBlank() -> return androidSdkRoot
    !androidHome.isNullOrBlank() -> return androidHome
  }
  
  // Fall back to local.properties files
  // Try React Native's local.properties first (js/node_modules/react-native/local.properties)
  val rnLocalProperties = File(projectDir.parentFile.parentFile, "local.properties")
  if (rnLocalProperties.exists()) {
    rnLocalProperties.readLines().forEach { line ->
      if (line.startsWith("sdk.dir=")) {
        val sdkDir = line.substring(8).trim()
        if (sdkDir.isNotBlank()) {
          return sdkDir
        }
      }
    }
  }
  
  // Try root project's local.properties (native-android/local.properties)
  // From hermes-engine: go up 5 levels to reach native-android root
  val rootLocalProperties = File(projectDir.parentFile.parentFile.parentFile.parentFile.parentFile, "local.properties")
  if (rootLocalProperties.exists()) {
    rootLocalProperties.readLines().forEach { line ->
      if (line.startsWith("sdk.dir=")) {
        val sdkDir = line.substring(8).trim()
        if (sdkDir.isNotBlank()) {
          return sdkDir
        }
      }
    }
  }
  
  // Default location
  val defaultSdk = "${System.getProperty("user.home")}/Library/Android/sdk"
  if (File(defaultSdk).exists()) {
    return defaultSdk
  }
  
  throw IllegalStateException("Neither ANDROID_SDK_ROOT nor ANDROID_HOME is set, and no local.properties found.")
}'''

# Try to match and replace
if re.search(r'fun getSDKPath\(\): String', content):
    # More flexible pattern - match the function body
    pattern = r'(fun getSDKPath\(\): String \{[^}]*val androidSdkRoot = System\.getenv\("ANDROID_SDK_ROOT"\)[^}]*val androidHome = System\.getenv\("ANDROID_HOME"\)[^}]*return when \{[^}]*!androidSdkRoot\.isNullOrBlank\(\) -> androidSdkRoot[^}]*!androidHome\.isNullOrBlank\(\) -> androidHome[^}]*else -> throw IllegalStateException\("Neither ANDROID_SDK_ROOT nor ANDROID_HOME is set\."\)[^}]*\}[^}]*\})'
    
    if re.search(pattern, content, re.DOTALL):
        new_content = re.sub(pattern, new_function, content, flags=re.DOTALL)
        with open(file_path, 'w') as f:
            f.write(new_content)
        print("✅ Successfully applied React Native SDK path fix")
        sys.exit(0)
    else:
        # Try a simpler approach - find the function and replace just the return statement
        lines = content.split('\n')
        in_function = False
        function_start = -1
        brace_count = 0
        
        for i, line in enumerate(lines):
            if 'fun getSDKPath(): String {' in line:
                in_function = True
                function_start = i
                brace_count = line.count('{') - line.count('}')
            elif in_function:
                brace_count += line.count('{') - line.count('}')
                if brace_count == 0:
                    # Found the end of the function
                    # Replace the function body
                    before = '\n'.join(lines[:function_start])
                    after = '\n'.join(lines[i+1:])
                    new_content = before + '\n' + new_function + '\n' + after
                    with open(file_path, 'w') as f:
                        f.write(new_content)
                    print("✅ Successfully applied React Native SDK path fix (method 2)")
                    sys.exit(0)
        
        print("⚠️  Could not find exact pattern. Manual edit may be required.")
        print(f"   Edit file: {file_path}")
        print("   Replace the getSDKPath() function with the version that reads from local.properties")
        sys.exit(1)
else:
    print("⚠️  getSDKPath() function not found. File may have changed.")
    sys.exit(1)
PYTHON_SCRIPT

if [ $? -eq 0 ]; then
    echo "✅ SDK path fix applied successfully"
else
    echo "⚠️  Automatic SDK path fix failed. Please apply manually:"
    echo "   Edit: $RN_BUILD_FILE"
    echo "   See SETUP_SUMMARY.md for the required changes"
    exit 1
fi

# Fix Gradle wrapper version
if [ -f "$RN_GRADLE_WRAPPER" ]; then
    if ! grep -q "gradle-8.13-bin.zip" "$RN_GRADLE_WRAPPER"; then
        echo "Updating React Native Gradle wrapper to 8.13..."
        sed -i.bak 's|distributionUrl=.*|distributionUrl=https\\://services.gradle.org/distributions/gradle-8.13-bin.zip|' "$RN_GRADLE_WRAPPER"
        rm -f "$RN_GRADLE_WRAPPER.bak" 2>/dev/null || true
        echo "✅ Gradle wrapper updated to 8.13"
    else
        echo "✅ Gradle wrapper already at 8.13"
    fi
else
    echo "⚠️  Gradle wrapper file not found: $RN_GRADLE_WRAPPER"
fi
