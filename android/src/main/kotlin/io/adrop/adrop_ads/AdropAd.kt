package io.adrop.adrop_ads

import android.app.Activity

enum class AdType {Undefined, Interstitial, Rewarded}

abstract class AdropAd {

    abstract fun load()

    open fun show(activity: Activity){}

    abstract fun destroy()
}
