pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.2.1" apply false
    id("com.android.built-in-kotlin") version "9.2.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.5.0") apply false
    // END: FlutterFire Configuration
    // START: FlutterFire Configuration
    // id("com.google.gms.google-services") version "4.3.15" apply false // TODO: Uncomment after updating google-services.json with package com.nungu.codestore
    // END: FlutterFire Configuration
    // Kotlin plugin is now provided by AGP via android.builtInKotlin=true (AGP 9+).
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

include(":app")
