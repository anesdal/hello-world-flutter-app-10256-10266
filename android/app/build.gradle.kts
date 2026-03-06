apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    // تعريف الـ namespace ضروري جداً للإصدارات الحديثة
    namespace "com.anes.tv" 

    compileSdkVersion 34 // تحديث لضمان التوافق مع المتطلبات الجديدة
    
    defaultConfig {
        applicationId "com.anes.tv"
        minSdkVersion 21 // ضروري لتشغيل مكتبات الفيديو
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }
}
