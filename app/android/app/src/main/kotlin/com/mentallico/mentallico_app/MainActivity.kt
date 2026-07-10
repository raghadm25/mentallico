package com.mentallico.mentallico_app

import android.util.Log
import com.learntoflutter.flutter_embed_unity_android.unity.FakeUnityPlayerActivity

class MainActivity : FakeUnityPlayerActivity() {
    // Known Flutter engine issue (e.g. flutter/flutter#144219 and related):
    // VirtualDisplayController.resetSurface() can throw "specified child already
    // has a parent" when this Activity resumes while the Unity platform view
    // (hosted via a SurfaceView, which forces Flutter into Virtual Display mode)
    // is still attached from before a pause — e.g. screen lock/unlock or the app
    // being backgrounded during a VR session. The view recovers on its own; this
    // narrow catch just stops that one known race from crashing the whole app.
    override fun onPostResume() {
        try {
            super.onPostResume()
        } catch (e: IllegalStateException) {
            if (e.message?.contains("already has a parent") == true) {
                Log.w("MainActivity", "Recovered from known platform-view resume race", e)
            } else {
                throw e
            }
        }
    }
}
