allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            val sdk = ext.javaClass.methods.find { it.name == "getCompileSdk" }?.invoke(ext)
            if (sdk == 37) {
                ext.javaClass.methods
                    .find { it.name == "setCompileSdkMinor" && it.parameterCount == 1 }
                    ?.invoke(ext, Integer.valueOf(0))
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
