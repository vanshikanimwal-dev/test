//buildscript {
//    ext {
//        // ADD/UPDATE THIS LINE
//        kotlin_version = '1.9.0' // Use a recent Kotlin version. 1.9.0 or 1.9.22 is common.
//        // Match this with what your Flutter project typically uses.
//        // Avoid too new versions if you encounter more issues.
//    }
//    repositories {
//        google()
//        mavenCentral()
//    }
//    dependencies {
//        classpath 'com.android.tools.build:gradle:8.1.0' // Your Android Gradle Plugin version
//        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
//        // Your Flutter Gradle plugin class path might also be here
//    }
//}
//
//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
//rootProject.layout.buildDirectory.value(newBuildDir)
//
//subprojects {
//    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//    project.layout.buildDirectory.value(newSubprojectBuildDir)
//}
//subprojects {
//    project.evaluationDependsOn(":app")
//}
//
//tasks.register<Delete>("clean") {
//    delete(rootProject.layout.buildDirectory)
//}
// android/build.gradle (Project-level - now with .gradle extension)

// android/build.gradle.kts (Corrected Kotlin DSL syntax)

//buildscript {
//    // Define properties using extra (Kotlin DSL equivalent of 'ext')
//    // This is the correct way to define variables for use in buildscript dependencies
//    val kotlin_version by extra("1.9.0") // Define kotlin_version here
//
//    repositories {
//        google()
//        mavenCentral()
//    }
//    dependencies {
//        // Use parentheses for function calls and double quotes for string literals
//        classpath("com.android.tools.build:gradle:8.7.3") // Your Android Gradle Plugin version from settings.gradle
//        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
//        // Your Flutter Gradle plugin class path might also be here if it's not handled by settings.gradle
//        // e.g., classpath("dev.flutter.flutter-gradle-plugin") if explicitly added here
//    }
//}
//
//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//// These blocks seem to be Kotlin DSL already, so they should be fine.
//val newBuildDir: org.gradle.api.file.Directory = rootProject.layout.buildDirectory.dir("../../build").get()
//rootProject.layout.buildDirectory.value(newBuildDir)
//
//subprojects {
//    val newSubprojectBuildDir: org.gradle.api.file.Directory = newBuildDir.dir(project.name)
//    project.layout.buildDirectory.value(newSubprojectBuildDir)
//}
//subprojects {
//    project.evaluationDependsOn(":app")
//}
//
//tasks.register<Delete>("clean") {
//    delete(rootProject.layout.buildDirectory)
//}
// android/build.gradle.kts (Project-level)

//buildscript {
//    repositories {
//        google()
//        mavenCentral()
//    }
//    dependencies {
//        // Define kotlin_version here
////        extra.set("kotlin_version", "1.9.0") // Define kotlin_version as an extra property
//        classpath("com.android.tools.build:gradle:8.7.3")
////        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${extra["kotlin_version"]}") // Access it here
//        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${project.properties["kotlin.version"]}")
//
//    }
//}
//
//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//// Ensure the kotlin_version is also available for subprojects (like 'app')
//// by defining it at the top-level 'extra' properties as well.
//// This allows subprojects to access it via `rootProject.extra["kotlin_version"]`
//// Set a default if not already set, or just directly set it.
////if (!extra.has("kotlin_version")) {
////    extra.set("kotlin_version", "1.9.0") // Or match your desired version
////}
//
//
//val newBuildDir: org.gradle.api.file.Directory = rootProject.layout.buildDirectory.dir("../../build").get()
//rootProject.layout.buildDirectory.value(newBuildDir)
//
//subprojects {
//    val newSubprojectBuildDir: org.gradle.api.file.Directory = newBuildDir.dir(project.name)
//    project.layout.buildDirectory.value(newSubprojectBuildDir)
//}
//subprojects {
//    project.evaluationDependsOn(":app")
//}
//
//tasks.register<Delete>("clean") {
//    delete(rootProject.layout.buildDirectory)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.3")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${project.properties["kotlin.version"]}")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: org.gradle.api.file.Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: org.gradle.api.file.Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}