package com.dummyapp.nativeandroid

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.dummyapp.nativeandroid.ui.CartActivity
import com.dummyapp.nativeandroid.ui.HomeActivity
import com.dummyapp.nativeandroid.ui.PdpActivity
import com.dummyapp.nativeandroid.ui.ProductsActivity
import com.dummyapp.nativeandroid.ui.ProfileActivity
import com.dummyapp.nativeandroid.ui.SettingsActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val recyclerView: RecyclerView = findViewById(R.id.menuRecyclerView)
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = MenuAdapter(provideMenuItems()) { menuItem ->
            Log.d("MainActivity", "Selected: ${menuItem.title}")
            runCatching {
                startActivity(Intent(this, menuItem.destination))
            }.onFailure { throwable ->
                Log.e("MainActivity", "Unable to open ${menuItem.title}", throwable)
                Toast.makeText(this, getString(R.string.launch_error_message, menuItem.title), Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun provideMenuItems(): List<MenuItem> = listOf(
        MenuItem(
            title = getString(R.string.title_home),
            subtitle = getString(R.string.subtitle_home),
            destination = HomeActivity::class.java
        ),
        MenuItem(
            title = getString(R.string.title_profile),
            subtitle = getString(R.string.subtitle_profile),
            destination = ProfileActivity::class.java
        ),
        MenuItem(
            title = getString(R.string.title_settings),
            subtitle = getString(R.string.subtitle_settings),
            destination = SettingsActivity::class.java
        ),
        MenuItem(
            title = getString(R.string.title_products_rn),
            subtitle = getString(R.string.subtitle_products_rn),
            destination = ProductsActivity::class.java
        ),
        MenuItem(
            title = getString(R.string.title_cart_rn),
            subtitle = getString(R.string.subtitle_cart_rn),
            destination = CartActivity::class.java
        ),
        MenuItem(
            title = getString(R.string.title_pdp_rn),
            subtitle = getString(R.string.subtitle_pdp_rn),
            destination = PdpActivity::class.java
        )
    )
}

