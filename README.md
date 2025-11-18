# Native Android App

A standalone Android application that integrates React Native modules from a Verdaccio registry. This app demonstrates how to embed React Native modules into a native Android app using npm packages and local bundling.

## 📋 Setup Order (For New Team Members)

**Follow this order when setting up for the first time:**

1. **✅ Monorepo** (set up first) - Must have Verdaccio running
2. **✅ This Native Android App** (set up second) - You are here
3. **Native iOS App** (set up third) - Optional, can be done in parallel

> **⚠️ Important**: You must set up the monorepo first and have Verdaccio running before setting up this app.

## 🚀 First-Time Setup (For New Team Members)

> **⚠️ IMPORTANT**: You must set up the **monorepo first** and have Verdaccio running before setting up this native Android app. See the monorepo README for setup instructions.

### Prerequisites

- **JDK 17+** - [Download](https://adoptium.net/)
- **Android Studio** - [Download](https://developer.android.com/studio)
- **Android SDK** (installed via Android Studio)
- **Node.js** >= 20 - [Download](https://nodejs.org/)
- **npm** (comes with Node.js)
- **Monorepo set up** with Verdaccio running (see monorepo README)

### Step-by-Step Setup

Follow these steps **in order**:

#### Step 1: Verify Monorepo is Ready

**Before starting**, ensure:

- ✅ Monorepo is cloned and dependencies installed
- ✅ Verdaccio is running on `http://localhost:4873`
- ✅ Packages are published to Verdaccio (`npm run verdaccio:publish-all` in monorepo)
- ✅ You're logged into Verdaccio (`npm adduser --registry http://localhost:4873`)

**Test Verdaccio is accessible:**

```bash
curl http://localhost:4873
```

If you see HTML output, Verdaccio is running. If not, go back to monorepo setup.

#### Step 2: Clone and Navigate

```bash
# Clone the repository
git clone <repository-url>
cd native-android
```

#### Step 3: Configure npm for Verdaccio

```bash
# Create .npmrc in the project root (if it doesn't exist)
cat > .npmrc << EOF
@app:registry=http://localhost:4873
@pkg:registry=http://localhost:4873
EOF

# Also configure in js/ directory
cd js
cat > .npmrc << EOF
@app:registry=http://localhost:4873
@pkg:registry=http://localhost:4873
EOF
cd ..
```

#### Step 4: Install JavaScript Dependencies

```bash
# Navigate to js directory
cd js

# Install dependencies (this will fetch packages from Verdaccio)
npm install --legacy-peer-deps
```

**Expected output**: Packages like `@app/module-products` should be installed from Verdaccio.

**⚠️ If you see errors about packages not found:**

- Verify Verdaccio is running: `curl http://localhost:4873`
- Verify packages are published: `npm view @app/module-products --registry http://localhost:4873`
- Check `.npmrc` files exist and are correct

#### Step 5: Build React Native from Source (First Time Only)

**⚠️ This step takes 20-30+ minutes** but is required only once:

```bash
# Return to project root
cd ..

# Build React Native from source
./scripts/build-react-native.sh
```

**Expected output**: You'll see React Native and Hermes being compiled. This is a one-time infrastructure setup and will take some time (around 20-30 minutes).

**Why this is needed**: React Native 0.81.5 pre-built AARs don't include `libhermes_executor.so`, which is required for Hermes to work.

#### Step 6: Bundle React Native Modules

```bash
# Navigate to js directory
cd js

# Bundle all React Native modules
npm run bundle
```

**Expected output**: You should see Metro bundling the JavaScript:

```
Bundling index.js 100.0% (xxx/xxx), done.
```

**Verify bundle was created:**

```bash
ls -lh ../app/src/main/assets/index.android.bundle
```

The bundle file should exist and be several MB in size.

#### Step 7: Open in Android Studio

```bash
# Open Android Studio
# File → Open → Select the 'native-android' folder
```

**Or from command line:**

```bash
# macOS
open -a "Android Studio" .

# Linux
studio.sh .

# Windows
studio.exe .
```

#### Step 8: Sync Gradle and Build

1. **Sync Gradle**: Android Studio should prompt you to sync, or click "Sync Now"
2. **Wait for sync to complete** (may take a few minutes on first run)
3. **Select a device**: Choose an emulator or connected device
4. **Build and Run**: Click the green Play button (▶️) or press `Shift+F10`

**Expected result**: The app should build and launch on your device/emulator.

### ✅ Setup Complete!

Your native Android app is now ready for development.

**Next Steps:**

- See [Development](#development) section below for daily workflows
- See [Troubleshooting](#troubleshooting) if you encounter issues

## Project Structure

```
native-android/
├── app/                    # Android application module
│   ├── src/main/
│   │   ├── assets/         # React Native bundles (generated)
│   │   ├── java/           # Kotlin source code
│   │   └── res/            # Android resources
│   └── build.gradle
├── js/                     # JavaScript workspace
│   ├── index.js           # React Native entry point
│   ├── metro.config.js     # Metro bundler config
│   └── package.json        # JS dependencies
├── scripts/                # Build and setup scripts
├── docs/                   # Documentation
└── build.gradle           # Root Gradle config
```

## Features

- ✅ React Native modules from Verdaccio registry
- ✅ Hermes JavaScript engine (built from source)
- ✅ Native Android navigation
- ✅ Offline bundle support

## Documentation

- **[Setup Guide](docs/SETUP.md)** - Complete setup instructions and troubleshooting
- **[Building from Source](docs/BUILD_FROM_SOURCE.md)** - Why and how we build React Native from source
- **[Build Monitoring](docs/BUILD_MONITORING.md)** - How to monitor build progress

## Modules

- **Products** - React Native module (working ✅)
- **Cart** - React Native module (working ✅)
- **PDP** - React Native module (working ✅)
- **Home, Profile, Settings** - Native Android screens

## 🔄 Daily Development Workflow

### Making Changes to React Native Modules

1. **Make changes** in the monorepo
2. **Publish updated packages** in monorepo: `npm run verdaccio:publish-all`
3. **Update dependencies** in this project:
   ```bash
   cd js
   npm install @app/module-products@latest --legacy-peer-deps
   ```
4. **Rebundle**:
   ```bash
   npm run bundle
   ```
5. **Rebuild Android app** in Android Studio

### Adding a New React Native Module

1. **Publish module to Verdaccio** from the monorepo
2. **Install in `js/package.json`**:
   ```bash
   cd js
   npm install @app/module-name --legacy-peer-deps
   ```
3. **Import in `js/index.js`** to trigger AppRegistry registration
4. **Create Activity** to host the module (see `ProductsActivity.kt` or `CartActivity.kt`)
5. **Add Activity** to `AndroidManifest.xml`
6. **Bundle all modules**: `npm run bundle` (all modules are bundled together)

### Building

```bash
# Clean build
./gradlew :app:clean :app:assembleDebug

# Incremental build
./gradlew :app:assembleDebug

# Install on device
./gradlew :app:installDebug
```

## Troubleshooting

See [docs/SETUP.md](docs/SETUP.md) for common issues and solutions.

## Related Projects

- **Monorepo**: [monorepo-expo-rn-ssr-csr](../../) - Contains the React Native modules
- **Verdaccio Setup**: See [docs/LOCAL_REGISTRY.md](../../docs/LOCAL_REGISTRY.md)
