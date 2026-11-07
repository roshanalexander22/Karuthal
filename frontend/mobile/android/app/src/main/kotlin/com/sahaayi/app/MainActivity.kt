package com.sahaayi.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.sahaayi.app.channels.FlutterChannelBridge

class MainActivity: FlutterActivity() {
    private var channelBridge: FlutterChannelBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channelBridge = FlutterChannelBridge(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }
}
