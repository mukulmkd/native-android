package com.dummyapp.nativeandroid

import android.app.Application
import com.facebook.react.ReactApplication
import com.facebook.react.ReactNativeHost
import com.facebook.react.ReactPackage
import com.facebook.react.defaults.DefaultReactNativeHost
import com.facebook.react.soloader.OpenSourceMergedSoMapping
import com.facebook.soloader.SoLoader
import com.dummyapp.nativeandroid.bridge.NavigationBridgePackage
import com.facebook.react.PackageList

class MainApplication : Application(), ReactApplication {

    override val reactNativeHost: ReactNativeHost = object : DefaultReactNativeHost(this) {
        override fun getPackages(): List<ReactPackage> {
            // Use autolinking PackageList (ExpoModulesPackage removed from autolinking)
            // Note: AsyncStorage is NOT included - it requires additional native dependencies
            // For now, persistence will not work until AsyncStorage is properly linked
            val packageList = PackageList(this)
            val autolinkedPackages = ArrayList(packageList.getPackages())
            // Add our custom navigation bridge
            autolinkedPackages.add(NavigationBridgePackage())
            return autolinkedPackages
        }
        override fun getUseDeveloperSupport(): Boolean = false
        override fun getJSMainModuleName(): String = "index"
        override fun getBundleAssetName(): String = "index.android.bundle"
    }

    override fun onCreate() {
        super.onCreate()
        System.setProperty("react_native_hermes_enabled", "true")
        // Initialize SoLoader with the merged library mapping
        // This allows hermes_executor to be mapped to hermestooling
        SoLoader.init(this, OpenSourceMergedSoMapping)
    }
}
