package com.openrhapsody.adrop_ads_flutter.bridge

import com.openrhapsody.ads.model.AdropErrorCode


class AdropError(private val _code: AdropErrorCode) : Exception(_code.name) {
    val code: String
        get() {
            return _code.name
        }
}