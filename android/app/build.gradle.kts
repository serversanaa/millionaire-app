//plugins {
//    id("com.android.application")
//    id("kotlin-android")
//    id("dev.flutter.flutter-gradle-plugin")
//    id("com.google.gms.google-services")
//}
//
//android {
//    namespace = "alrobiai.sys.example.millionaire_salon"
//    compileSdk = 36 // ✅ استخدم 34 لأن 36 غير متاح رسميًا
//
//    ndkVersion = "27.0.12077973"
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_17
//        targetCompatibility = JavaVersion.VERSION_17
//        isCoreLibraryDesugaringEnabled = true
//    }
//
//    kotlinOptions {
//        jvmTarget = "17"
//    }
//
//    defaultConfig {
//        applicationId = "alrobiai.sys.example.millionaire_salon"
//        minSdk = flutter.minSdkVersion
//        targetSdk = 35
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//        multiDexEnabled = true
//    }
//
//    // ✅ دعم جميع المعماريات (armeabi-v7a, arm64-v8a, x86_64)
//    splits {
//        abi {
//            isEnable = true
//            reset()
//            include("armeabi-v7a", "arm64-v8a", "x86_64")
//            isUniversalApk = true // 🔹 يبني APK واحد شامل كل المعماريات
//        }
//    }
//
//    buildTypes {
//        release {
//            isMinifyEnabled = true
//            isShrinkResources = true
//            isDebuggable = false
//
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
//
//            // 🔐 استخدم توقيع debug مؤقتاً (يمكنك تغييره لاحقًا)
//            signingConfig = signingConfigs.getByName("debug")
//        }
//
//        debug {
//            isMinifyEnabled = false
//            isShrinkResources = false
//        }
//    }
//
//    packaging {
//        resources {
//            excludes += listOf(
//                "META-INF/DEPENDENCIES",
//                "META-INF/LICENSE",
//                "META-INF/LICENSE.txt",
//                "META-INF/NOTICE",
//                "META-INF/NOTICE.txt"
//            )
//        }
//    }
//}
//
//flutter {
//    source = "../.."
//}
//
//dependencies {
//    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
//    implementation("com.google.firebase:firebase-analytics-ktx")
//    implementation("com.google.firebase:firebase-messaging-ktx")
//
//    implementation("androidx.multidex:multidex:2.0.1")
//    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
//}







///********************************************************************************///

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties
        import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "alrobiai.sys.millionaire_salon"
    compileSdk = 36  // ✅ استخدم 34 (مستقر)
    ndkVersion = "27.0.12077973"

    // ✅ حل مشكلة Java 8
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"

        // ✅ تجاهل تحذيرات Java 8
        freeCompilerArgs += listOf(
            "-Xjvm-default=all",
            "-opt-in=kotlin.RequiresOptIn"
        )
    }

//    defaultConfig {
//        applicationId = "alrobiai.sys.example.millionaire_salon"
//        minSdk = flutter.minSdkVersion
//        targetSdk = 34  // ✅ استخدم 34
//        versionCode = flutter.versionCode.toInt()
//        versionName = flutter.versionName
//        multiDexEnabled = true
//
//        // ✅ إضافة لدعم أفضل
//        ndk {
////            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
//            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
//
//        }
//    }

    defaultConfig {
        applicationId = "alrobiai.sys.millionaire_salon"
        minSdk = flutter.minSdkVersion
        targetSdk = 35  // ✅ استخدم 34\
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true

        // ✅ إضافة لدعم أفضل
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }
    // ✅ دعم جميع المعماريات
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a")
            isUniversalApk = true
        }
    }
    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
    }

//    buildTypes {
//        release {
//            isMinifyEnabled = true
//            isShrinkResources = true
//            isDebuggable = false
//
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
//
//            signingConfig = signingConfigs.getByName("debug")
//        }
//
//        debug {
//            isMinifyEnabled = false
//            isShrinkResources = false
//        }
//    }
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // ✅ هنا نربط بتوقيع release الحقيقي
            signingConfig = signingConfigs.getByName("release")
        }

        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packaging {
        resources {
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/*.kotlin_module"  // ✅ إضافة
            )
        }
    }

    // ✅ تجاهل تحذيرات الـ linting
    lint {
        disable += setOf("Instantiatable", "ObsoleteSdkInt")
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")

    // MultiDex
    implementation("androidx.multidex:multidex:2.0.1")

    // Desugaring لدعم Java 8 features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // ✅ إضافات لتحسين التوافق
    implementation("androidx.core:core-ktx:1.12.0")
}
