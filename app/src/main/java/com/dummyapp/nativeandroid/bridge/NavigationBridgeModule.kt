package com.dummyapp.nativeandroid.bridge

import android.app.Activity
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.dummyapp.nativeandroid.ui.PdpActivity
import com.dummyapp.nativeandroid.ui.CartActivity
import com.dummyapp.nativeandroid.ui.ProductsActivity

class NavigationBridgeModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "NavigationBridge"
    }

    @ReactMethod
    fun navigateToPDP(productId: String) {
        val activity = reactApplicationContext.currentActivity
        if (activity != null) {
            activity.runOnUiThread {
                val intent = PdpActivity.createIntent(activity, productId)
                activity.startActivity(intent)
            }
        }
    }

    @ReactMethod
    fun navigateToCart() {
        val activity = reactApplicationContext.currentActivity
        if (activity != null) {
            activity.runOnUiThread {
                val intent = android.content.Intent(activity, CartActivity::class.java)
                activity.startActivity(intent)
            }
        }
    }

    @ReactMethod
    fun navigateToProducts() {
        val activity = reactApplicationContext.currentActivity
        if (activity != null) {
            activity.runOnUiThread {
                val intent = android.content.Intent(activity, ProductsActivity::class.java)
                activity.startActivity(intent)
            }
        }
    }
}
