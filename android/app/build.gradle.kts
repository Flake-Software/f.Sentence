plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Čitamo tajne lozinke iz sistema (koje GitHub Actions postavi)
val keystorePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
val keystoreAlias = System.getenv("KEY_ALIAS") ?: ""
val keyPassword = System.getenv("KEY_PASSWORD") ?: ""

android {
    namespace = "com.flake.sentence" 
    compileSdk = 36 // Ostajemo na najnovijem

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        // Ovde unesi svoj stvarni applicationId ako je drugačiji
        applicationId = "com.example.f_sentence"
        minSdk = 21
        targetSdk = 36
        versionCode = 2 // Podigli smo na 2 da bi Android dozvolio update
        versionName = "0.1.1"
    }

    signingConfigs {
        create("release") {
            // Putanja do fajla koji GitHub Actions dekodira
            storeFile = file("f-sentence.jks")
            storePassword = keystorePassword
            keyAlias = keystoreAlias
            keyPassword = keyPassword
        }
    }

    buildTypes {
        release {
            // Ovde uključujemo tvoj novi digitalni potpis
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
