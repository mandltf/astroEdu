package com.example.astroedu

import io.flutter.embedding.android.FlutterFragmentActivity  // Ubah import ini
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterFragmentActivity() {  // Extends FlutterFragmentActivity, bukan FlutterActivity
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}