import org.gradle.jvm.tasks.Jar

plugins {
    java
    application
}

group = "org.example"
version = "1.0-SNAPSHOT"

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("io.javalin:javalin-bundle:5.6.1")
    implementation("com.fasterxml.jackson.core:jackson-databind:2.15.2")
    implementation("org.xerial:sqlite-jdbc:3.41.2.1")
    implementation("org.slf4j:slf4j-simple:2.0.7")

    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
    testImplementation("org.assertj:assertj-core:3.24.2")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher:1.10.0")
}

application {
    mainClass.set("org.example.joke.App")
}

tasks.test {
    useJUnitPlatform()
}

// Produce a fat JAR by unpacking runtime dependencies
tasks.register<Jar>("fatJar") {
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
    archiveBaseName.set("javalin-joke-all")
    archiveClassifier.set("")
    archiveVersion.set("")
    manifest {
        attributes("Main-Class" to "org.example.joke.api.App")
    }
    from(sourceSets.main.get().output)
    dependsOn(configurations.runtimeClasspath)
    from({
        configurations.runtimeClasspath.get().filter { it.name.endsWith(".jar") }.map { zipTree(it) }
    }) {
        exclude("META-INF/*.SF", "META-INF/*.DSA", "META-INF/*.RSA", "META-INF/*.SF*", "META-INF/LICENSE*")
    }
}

tasks.named("build") {
    dependsOn(tasks.named("fatJar"))
}
