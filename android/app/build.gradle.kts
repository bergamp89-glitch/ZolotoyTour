import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing properties from key.properties file
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun hasValidKeystore(): Boolean {
    if (!keystorePropertiesFile.exists()) return false
    val storeFilePath = keystoreProperties["storeFile"] as? String ?: return false
    val storePassword = keystoreProperties["storePassword"] as? String ?: return false
    return file(storeFilePath).exists() && !storePassword.startsWith("YOUR_")
}

android {
    namespace = "com.zolotoytouruz.app"
    compileSdk = flutter.compileSdkVersion.coerceAtLeast(34)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.zolotoytouruz.app"
        // Ensure minimum SDK of 21 for webview_flutter compatibility
        minSdk = flutter.minSdkVersion.coerceAtLeast(21)
        targetSdk = flutter.targetSdkVersion.coerceAtLeast(34)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasValidKeystore()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (hasValidKeystore()) {
                signingConfigs.getByName("release")
            } else {
                // Fallback to debug signing when keystore is not yet configured
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
