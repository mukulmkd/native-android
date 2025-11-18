package com.dummyapp.nativeandroid

import androidx.appcompat.app.AppCompatActivity

data class MenuItem(
    val title: String,
    val subtitle: String,
    val destination: Class<out AppCompatActivity>
)

