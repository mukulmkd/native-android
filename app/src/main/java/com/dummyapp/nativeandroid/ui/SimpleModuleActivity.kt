package com.dummyapp.nativeandroid.ui

import android.os.Bundle
import android.widget.TextView
import androidx.annotation.LayoutRes
import androidx.annotation.StringRes
import androidx.appcompat.app.AppCompatActivity
import com.dummyapp.nativeandroid.R

abstract class SimpleModuleActivity : AppCompatActivity() {

    @get:StringRes
    protected abstract val titleRes: Int

    @get:StringRes
    protected abstract val descriptionRes: Int

    @get:LayoutRes
    protected open val layoutRes: Int = R.layout.activity_module

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(layoutRes)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        findViewById<TextView>(R.id.moduleTitle).setText(titleRes)
        findViewById<TextView>(R.id.moduleDescription).setText(descriptionRes)
    }

    override fun onSupportNavigateUp(): Boolean {
        onBackPressedDispatcher.onBackPressed()
        return true
    }
}

