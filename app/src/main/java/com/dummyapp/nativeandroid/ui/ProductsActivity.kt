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

class ProductsActivity : AppCompatActivity(), DefaultHardwareBackBtnHandler {
    private var reactRootView: ReactRootView? = null
    private val reactInstanceManager: ReactInstanceManager?
        get() = (application as? ReactApplication)?.reactNativeHost?.reactInstanceManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val instanceManager = reactInstanceManager
        if (instanceManager == null) {
            Toast.makeText(
                this,
                getString(R.string.launch_error_message, getString(R.string.title_products_rn)),
                Toast.LENGTH_LONG
            ).show()
            finish()
            return
        }

        reactRootView = ReactRootView(this).also { view ->
            view.startReactApplication(instanceManager, MODULE_NAME, null)
            setContentView(view)
            title = getString(R.string.title_products_rn)
        }
    }

    override fun onResume() {
        super.onResume()
        reactInstanceManager?.onHostResume(this, this)
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
        private const val MODULE_NAME = "ModuleProducts"
    }
}

