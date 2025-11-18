# Building React Native from Source

This project is configured to build React Native from source to enable Hermes with the executor library.

## Why Build from Source?

React Native 0.81.5 pre-built AARs don't include `libhermes_executor.so`, which is required for Hermes to work. Building from source ensures:
- ✅ Hermes executor library is included
- ✅ Full control over React Native build
- ✅ Better long-term maintainability
- ✅ Works with future React Native versions

## Configuration

### Settings (`settings.gradle`)
- Includes React Native Gradle plugin from `js/node_modules/@react-native/gradle-plugin`
- Includes React Native from source via `includeBuild("js/node_modules/react-native")`

### App Build (`app/build.gradle`)
- Dependency substitution configured to use built React Native instead of AARs
- React Native plugin configured with correct paths

### Local Properties
The React Native build reads SDK location from:
- Environment variables: `ANDROID_HOME` or `ANDROID_SDK_ROOT`
- `js/node_modules/react-native/local.properties` - SDK location (if exists)
- `local.properties` (project root) - SDK location (if exists)
- Default: `~/Library/Android/sdk` (macOS) or `~/Android/Sdk` (Linux)

## Build Process

### First Build
The first build will take **10-30+ minutes** as it:
1. Downloads native dependencies (NDK, CMake, etc.)
2. Builds Hermes engine
3. Builds React Native native libraries
4. Builds the executor library
5. Compiles the app

### Subsequent Builds
Subsequent builds are much faster (1-5 minutes) as only changed components are rebuilt.

## Running Builds

### Build React Native from Source (First Time)
```bash
./scripts/build-react-native.sh
```

### Build the App
```bash
# Clean build (rebuilds everything)
./gradlew :app:clean :app:assembleDebug

# Incremental build
./gradlew :app:assembleDebug

# Install on device
./gradlew :app:installDebug
```

### Check Build Status
```bash
./scripts/check-build-status.sh
```

## Troubleshooting

### Build Fails with SDK Not Found
Ensure `local.properties` files exist with correct SDK path:
```properties
sdk.dir=/Users/yourusername/Library/Android/sdk
```

### Build Takes Too Long
- First build always takes long - this is normal
- Subsequent builds are incremental and faster
- Consider using `--no-daemon` if you have memory issues

### Out of Memory
Increase Gradle memory in `gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m
```

## What Gets Built

When building from source, the following are built:
- `libhermes.so` - Hermes JavaScript engine
- `libhermes_executor.so` - **Executor library (not in AARs)**
- `libreactnative.so` - React Native core
- Other React Native native libraries

## Benefits

1. **Complete Hermes Support** - Executor library included
2. **Future-Proof** - Works with React Native updates
3. **Debugging** - Can debug into React Native source
4. **Customization** - Can modify React Native if needed

## Alternative: Using Pre-built AARs

If you want to use pre-built AARs (faster builds, but no executor):
1. Remove `includeBuild("js/node_modules/react-native")` from `settings.gradle`
2. Remove dependency substitution from `app/build.gradle`
3. Use JSC instead of Hermes (change `hermes-android` to `android-jsc`)

However, this means:
- ❌ No Hermes executor (must use JSC)
- ❌ Less control over React Native
- ❌ May not work with future versions

## Maintenance

- Keep `local.properties` files in sync if SDK location changes
- Update React Native version in `js/package.json` and rebuild
- The autolinking config is auto-generated before each build

