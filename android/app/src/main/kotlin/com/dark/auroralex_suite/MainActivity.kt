package com.dark.auroralex_suite

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.isVisible
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener

class MainActivity : FlutterActivity() {
    private var splashView: View? = null
    private val handler = Handler(Looper.getMainLooper())
    private var splashDisplayedAt = 0L
    private val minSplashDuration = 150L
    private val splashTimeout = 4000L
    private val splashTimeoutRunnable = Runnable { removeSplashOverlay() }

    private var isFlutterReady = false

    private val flutterUiListener = object : FlutterUiDisplayListener {
        override fun onFlutterUiDisplayed() {
            isFlutterReady = true
            ensureMinDurationThenRemove()
        }

        override fun onFlutterUiNoLongerDisplayed() = Unit
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        splashScreen.setKeepOnScreenCondition { !isFlutterReady }
        super.onCreate(savedInstanceState)
        flutterEngine?.renderer?.addIsDisplayingFlutterUiListener(flutterUiListener)
    }

    override fun onPostCreate(savedInstanceState: Bundle?) {
        super.onPostCreate(savedInstanceState)
        addSplashOverlay()
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        isFlutterReady = true
        ensureMinDurationThenRemove()
    }

    private fun ensureMinDurationThenRemove() {
        if (splashView == null) return
        val elapsed = SystemClock.uptimeMillis() - splashDisplayedAt
        if (elapsed >= minSplashDuration) {
            removeSplashOverlay()
        } else {
            handler.postDelayed(
                { removeSplashOverlay() },
                minSplashDuration - elapsed,
            )
        }
    }

    private fun addSplashOverlay() {
        if (splashView?.isVisible == true) return
        window.decorView.post {
            if (splashView?.isVisible == true || isFinishing || isDestroyed) return@post
            val content = findViewById<ViewGroup>(android.R.id.content) ?: return@post
            val view = layoutInflater.inflate(R.layout.native_flutter_splash, content, false)
            content.addView(
                view,
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                ),
            )
            splashView = view
            splashDisplayedAt = SystemClock.uptimeMillis()
            handler.postDelayed(splashTimeoutRunnable, splashTimeout)
        }
    }

    private fun removeSplashOverlay() {
        handler.removeCallbacks(splashTimeoutRunnable)
        if (splashView == null) return
        splashView?.let { view ->
            val parent = view.parent as? ViewGroup
            parent?.removeView(view)
        }
        splashView = null
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        flutterEngine?.renderer?.removeIsDisplayingFlutterUiListener(flutterUiListener)
        removeSplashOverlay()
        super.onDestroy()
    }
}
