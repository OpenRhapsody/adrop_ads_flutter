package io.adrop.adrop_ads.metrics

import io.adrop.ads.metrics.AdropMetrics
import org.json.JSONArray
import org.json.JSONObject

object FlutterAdropMetrics {

    fun setProperty(key: String, value: Any) {
        when(value) {
            is String -> AdropMetrics.setProperty(key, value)
            is Int -> AdropMetrics.setProperty(key, value)
            is Double -> AdropMetrics.setProperty(key, value)
            is Boolean -> AdropMetrics.setProperty(key, value)
            else -> {}
        }
    }

    fun properties(): Map<String, Any> {
        return AdropMetrics.properties.toMap()
    }

    fun JSONObject.toMap(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = this.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val value = this[key]
            map[key] = when (value) {
                is JSONObject -> value.toMap()  // Recursively convert nested JSONObject
                is JSONArray -> value.toList()  // Convert JSONArray to List
                else -> value  // For other types, directly add them
            }
        }
        return map
    }

    // Convert JSONArray to List<Any>
    fun JSONArray.toList(): List<Any> {
        val list = mutableListOf<Any>()
        for (i in 0 until length()) {
            val value = this[i]
            list.add(
                when (value) {
                    is JSONObject -> value.toMap()  // Recursively convert nested JSONObject
                    is JSONArray -> value.toList()  // Recursively convert nested JSONArray
                    else -> value  // For other types, directly add them
                }
            )
        }
        return list
    }
}