// android/build.gradle.kts (Kotlin DSL)
buildscript {
    // Kotlin DSL uses 'val' not 'ext'
    val kotlinVersion = "1.9.22"
    
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Kotlin DSL uses parentheses and quotes
        classpath("com.android.tools.build:gradle:8.2.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

// Your custom build directory setup (Kotlin DSL)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}