package com.flake.sentence

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Build
import android.view.View
import android.view.WindowInsets

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Forsiranje Edge-to-Edge na nivou sistema
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.navigationBarColor = 0 // Transparentna
            window.statusBarColor = 0 // Transparentna
        }
    }
}