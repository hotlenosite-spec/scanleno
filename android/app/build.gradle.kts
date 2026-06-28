import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = listOf(
    rootProject.file("key.properties"),
    rootProject.file("android/key.properties"),
).firstOrNull { it.exists() } ?: rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun requireReleaseSigningProperty(name: String): String {
    val value = keystoreProperties.getProperty(name)?.trim()
    if (value.isNullOrEmpty()) {
        throw GradleException("Release signing is not configured. Create android/key.properties.")
    }
    return value
}

android {
    namespace = "com.hotleno.scanleno"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.hotleno.scanleno"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (gradle.startParameter.taskNames.any { it.lowercase().contains("release") }) {
                if (!keystorePropertiesFile.exists()) {
                    throw GradleException("Release signing is not configured. Create android/key.properties.")
                }
                keyAlias = requireReleaseSigningProperty("keyAlias")
                keyPassword = requireReleaseSigningProperty("keyPassword")
                storePassword = requireReleaseSigningProperty("storePassword")
                val configuredStoreFile = requireReleaseSigningProperty("storeFile")
                storeFile = rootProject.file(configuredStoreFile)
                if (!storeFile!!.exists()) {
                    throw GradleException("Release signing is not configured. Keystore file does not exist: $configuredStoreFile")
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
