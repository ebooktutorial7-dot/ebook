// bulid.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Firebase
}

android {
    namespace = "com.example.ebook_tutorial_app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.ebook_tutorial_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

dependencies {
    implementation("com.google.firebase:firebase-auth-ktx:22.3.0") // Firebase Auth
    implementation("com.google.android.gms:play-services-auth:21.1.0") // Google 로그인
}
