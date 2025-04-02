// في ملف android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.alsoneducation.alson_education"
    compileSdk = 34 // <-- التحديث هنا (كان flutter.compileSdkVersion)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.alsoneducation.alson_education"
        minSdk = flutter.minSdkVersion
        targetSdk = 34 // <-- التحديث هنا (كان flutter.targetSdkVersion)
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
