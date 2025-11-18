package com.dummyapp.nativeandroid.ui

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.dummyapp.nativeandroid.R
import com.facebook.react.ReactApplication
import com.facebook.react.ReactInstanceManager
import com.facebook.react.ReactRootView
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler
import com.facebook.react.modules.core.DeviceEventManagerModule

class PdpActivity : AppCompatActivity(), DefaultHardwareBackBtnHandler {
    private var reactRootView: ReactRootView? = null
    private val reactInstanceManager: ReactInstanceManager?
        get() = (application as? ReactApplication)?.reactNativeHost?.reactInstanceManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val instanceManager = reactInstanceManager
        if (instanceManager == null) {
            Toast.makeText(
                this,
                getString(R.string.launch_error_message, getString(R.string.title_pdp_rn)),
                Toast.LENGTH_LONG
            ).show()
            finish()
            return
        }

        // Extract productId from intent if provided
        val productId = intent.getStringExtra(EXTRA_PRODUCT_ID)

        // Prepare initial properties for the React Native module
        val initialProperties = Bundle().apply {
            if (productId != null) {
                putString("productId", productId)
            }
        }

        reactRootView = ReactRootView(this).also { view ->
            view.startReactApplication(instanceManager, MODULE_NAME, initialProperties)
            setContentView(view)
            title = getString(R.string.title_pdp_rn)
        }
    }

    override fun onResume() {
        super.onResume()
        reactInstanceManager?.onHostResume(this, this)
        // Reload persisted state when view appears to ensure cart count is up-to-date
        reloadPersistedState()
    }

    private fun reloadPersistedState() {
        val instanceManager = reactInstanceManager ?: return
        val reactContext = instanceManager.currentReactContext
        
        // React context might not be ready immediately, so post to handler
        if (reactContext != null) {
            // Use DeviceEventEmitter to send event to React Native
            reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                .emit("ReloadPersistedState", null)
        } else {
            // If context not ready, try again after a short delay
            reactRootView?.postDelayed({
                val context = reactInstanceManager?.currentReactContext
                context?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                    ?.emit("ReloadPersistedState", null)
            }, 100)
        }
    }

    override fun onPause() {
        reactInstanceManager?.onHostPause(this)
        super.onPause()
    }

    override fun onDestroy() {
        reactRootView?.unmountReactApplication()
        reactRootView = null
        super.onDestroy()
    }

    override fun onBackPressed() {
        reactInstanceManager?.onBackPressed() ?: super.onBackPressed()
    }

    override fun invokeDefaultOnBackPressed() {
        super.onBackPressed()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        reactInstanceManager?.onActivityResult(this, requestCode, resultCode, data)
    }

    companion object {
        private const val MODULE_NAME = "ModulePDP"
        const val EXTRA_PRODUCT_ID = "productId"

        fun createIntent(context: android.content.Context, productId: String? = null): Intent {
            return Intent(context, PdpActivity::class.java).apply {
                productId?.let { putExtra(EXTRA_PRODUCT_ID, it) }
            }
        }
    }
}
