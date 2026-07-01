import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val alignedLibCppDir = layout.buildDirectory.dir("16k-libcpp")

val copy16KAlignedLibCpp by tasks.registering {
    description = "Copy 16KB-aligned libc++_shared.so from the NDK for Play Store compliance"
    outputs.dir(alignedLibCppDir)

    doLast {
        val ndkDir = android.ndkDirectory
        val prebuiltDir = ndkDir.resolve("toolchains/llvm/prebuilt")
            .listFiles()
            ?.firstOrNull { it.isDirectory && it.resolve("sysroot").exists() }
            ?: error("NDK prebuilt directory not found in $ndkDir")

        val sysrootLib = prebuiltDir.resolve("sysroot/usr/lib")
        mapOf(
            "arm64-v8a" to "aarch64-linux-android",
            "x86_64" to "x86_64-linux-android",
        ).forEach { (androidAbi, ndkAbi) ->
            val source = sysrootLib.resolve("$ndkAbi/libc++_shared.so")
            if (!source.exists()) {
                error("Missing NDK libc++_shared.so for $ndkAbi at $source")
            }
            val destDir = alignedLibCppDir.get().asFile.resolve(androidAbi)
            destDir.mkdirs()
            source.copyTo(destDir.resolve("libc++_shared.so"), overwrite = true)
        }
    }
}

tasks.named("preBuild").configure {
    dependsOn(copy16KAlignedLibCpp)
}

// OpenCV ships a 4KB-aligned libc++_shared.so; replace it after native libs merge.
afterEvaluate {
    tasks.matching { it.name.startsWith("merge") && it.name.endsWith("NativeLibs") }.configureEach {
        dependsOn(copy16KAlignedLibCpp)
        doLast {
            val variant = name.removePrefix("merge").removeSuffix("NativeLibs")
            val mergedLibDir = layout.buildDirectory
                .dir("intermediates/merged_native_libs/${variant.lowercase()}/merge${variant}NativeLibs/out/lib")
                .get()
                .asFile

            alignedLibCppDir.get().asFile.listFiles()?.forEach { abiDir ->
                if (!abiDir.isDirectory) return@forEach
                val source = abiDir.resolve("libc++_shared.so")
                if (!source.exists()) return@forEach
                val targetDir = mergedLibDir.resolve(abiDir.name)
                targetDir.mkdirs()
                source.copyTo(targetDir.resolve("libc++_shared.so"), overwrite = true)
            }
        }
    }
}

android {
    namespace = "com.uksolutions.docsnap"
    compileSdk = flutter.compileSdkVersion
    // NDK r28+ builds 64-bit libc++ with 16KB ELF alignment required by Google Play.
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        applicationId = "com.uksolutions.docsnap"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
