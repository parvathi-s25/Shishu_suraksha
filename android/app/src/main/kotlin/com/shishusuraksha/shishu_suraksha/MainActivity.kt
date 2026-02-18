package com.shishusuraksha.shishu_suraksha

import android.content.Context
import android.content.ContextWrapper
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Build
import android.os.Bundle
import android.os.LocaleList
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.shishusuraksha/locale"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateLocale") {
                val languageCode = call.argument<String>("languageCode")
                if (languageCode != null) {
                    val locale = Locale(languageCode)
                    Locale.setDefault(locale)
                    val config = resources.configuration
                    config.setLocale(locale)
                    createConfigurationContext(config)
                    
                    // Save to SharedPrefs for persistence
                    val sharedPref = getPreferences(Context.MODE_PRIVATE)
                    with (sharedPref.edit()) {
                        putString("app_language", languageCode)
                        apply()
                    }
                    
                    result.success(true)
                } else {
                    result.error("INVALID_CODE", "Language code is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun attachBaseContext(newBase: Context) {
        // Load saved language or default to system
        // Note: verify if getPreferences is accessible here, if not use getSharedPreferences
        val sharedPref = newBase.getSharedPreferences("MainActivity", Context.MODE_PRIVATE)
        val languageCode = sharedPref.getString("app_language", "en")
        
        val locale = Locale(languageCode ?: "en")
        val context = LocaleContextWrapper.wrap(newBase, locale)
        super.attachBaseContext(context)
    }
}

object LocaleContextWrapper {
    fun wrap(context: Context, newLocale: Locale): Context {
        var res = context.resources
        val configuration = res.configuration

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            configuration.setLocale(newLocale)
            val localeList = LocaleList(newLocale)
            LocaleList.setDefault(localeList)
            configuration.setLocales(localeList)
            return context.createConfigurationContext(configuration)
        } else {
            configuration.locale = newLocale
            res.updateConfiguration(configuration, res.displayMetrics)
            return context
        }
    }
}
