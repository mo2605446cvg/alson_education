plugins {
  // ...
  id("com.android.application") version "8.1.0" apply false
  id("org.jetbrains.kotlin.android") version "1.9.25" apply false

  // Add the dependency for the Google services Gradle plugin
  id("com.google.gms.google-services") version "4.4.3" apply false

}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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

