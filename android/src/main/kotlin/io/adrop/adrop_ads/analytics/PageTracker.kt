package io.adrop.adrop_ads.analytics

import android.app.Activity
import android.app.Application
import android.os.Bundle
import io.adrop.ads.analytics.AdropPageTracker
import io.flutter.embedding.android.FlutterActivity


class PageTracker(application: Application): Application.ActivityLifecycleCallbacks {

    private var sizeOfRoutes = 0
    private var pivotIdxOfPrevSession = 0
    private var currentPage = ""

    private var backgroundAt = 0L
    private var started = 0

    init {
        application.registerActivityLifecycleCallbacks(this)
    }

    fun track(page: String, sizeOfRoutes: Int) {
        val pushed = sizeOfRoutes >= this.sizeOfRoutes
        this.sizeOfRoutes = sizeOfRoutes
        currentPage = page

        val isTrackable = pushed || isTrackablePopPageIfSessionRestarted()
        if (!isTrackable) return
        track(page)
    }

    private fun track(page: String) {
        AdropPageTracker.track(PAGE_TRACK_KEY, page)
    }

    private fun isTrackablePopPageIfSessionRestarted(): Boolean {
        if (sizeOfRoutes >= pivotIdxOfPrevSession) return false

        pivotIdxOfPrevSession = sizeOfRoutes
        return true
    }

    fun attach(unitId: String, page: String) {
        AdropPageTracker.attach(PAGE_TRACK_KEY, unitId, page)
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}

    override fun onActivityStarted(activity: Activity) { started++ }

    override fun onActivityResumed(activity: Activity) {
        if (started > 2) return

        if (activity is FlutterActivity && System.currentTimeMillis() - backgroundAt > 30_000L) {
            track(currentPage)
            pivotIdxOfPrevSession = sizeOfRoutes
        }
    }

    override fun onActivityPaused(activity: Activity) {}

    override fun onActivityStopped(activity: Activity) {
        if (started-- > 1) return

        backgroundAt = System.currentTimeMillis()
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

    override fun onActivityDestroyed(activity: Activity) {}

    private companion object {
        const val PAGE_TRACK_KEY = "adrop_external_key"
    }
}
