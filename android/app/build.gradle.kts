plugins {
    id 'com.android.application'
    id 'kotlin-android'
}

android {
    namespace "com.example.alson_education"
    compileSdk 34

    defaultConfig {
        applicationId "com.example.alson_education"
        minSdk 21
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            minifyEnabled false
            shrinkResources false
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
}
