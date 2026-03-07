pluginManagement {
    val flutterSdkPath = System.getProperty("flutter.sdk") 
        ?: file("../local.properties").let { f ->
            if (f.exists()) {
                val props = java.util.Properties()
                f.inputStream().use { props.load(it) }
                props.getProperty("flutter.sdk")
            } else null
        }
    
    if (flutterSdkPath != null) {
        includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
