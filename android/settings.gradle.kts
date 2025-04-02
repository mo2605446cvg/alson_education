pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
    plugins {
        id("com.android.application") version "8.1.0"
        id("org.jetbrains.kotlin.android") version "1.9.0"
        id("dev.flutter.flutter-gradle-plugin") version "2.0.0"
    }
}

include(":app")
