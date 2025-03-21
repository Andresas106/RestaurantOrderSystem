// Plugins de Firebase y Google Services
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false // Firebase
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Corrige la estructura del build
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Tarea para limpiar el proyecto
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
