plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePasswordStr = System.getenv("KEYSTORE_PASSWORD") ?: ""
val keystoreAliasStr = System.getenv("KEY_ALIAS") ?: ""
val keyPasswordStr = System.getenv("KEY_PASSWORD") ?: ""

android {
    namespace = "com.flake.sentence" 
    compileSdk = 36

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.flake.sentence"
        minSdk = 21
        targetSdk = 36
        versionCode = 2
        versionName = "1.0.1"
    }

    signingConfigs {
        create("release") {
            storeFile = file("f-sentence.jks")
            storePassword = keystorePasswordStr
            keyAlias = keystoreAliasStr
            keyPassword = keyPasswordStr
        }
    }

    buildTypes {
        release {
            // Ovde smo rekli Gradle-u da koristi gornji "release" potpis
            signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.17.0")
}
