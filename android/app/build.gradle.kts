plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hivelog_bee"
    // نرفع compileSdk يدوياً لضمان توافق مكتبات أندرويد الحديثة
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.hivelog_bee"
        // مكتبة file_picker والإشعارات تتطلب 21 كحد أدنى
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // إضافة هذه السطور تساعد في تقليص حجم التطبيق وحل مشاكل الـ Dex
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // هذه المكتبة ضرورية جداً لحل خطأ desugaring الذي واجهته
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
