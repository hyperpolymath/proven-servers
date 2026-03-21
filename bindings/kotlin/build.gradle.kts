// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gradle build script for proven-servers Kotlin/JNI bindings.
// Links against the Zig-compiled C-ABI shared library via JNI
// (shares the Java JNI .so from bindings/java/).

plugins {
    kotlin("jvm") version "2.1.0"
    `java-library`
}

group = "com.hyperpolymath"
version = "0.1.0"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

kotlin {
    jvmToolchain(21)
}

tasks.test {
    useJUnitPlatform()
    // Set java.library.path to find the JNI .so.
    systemProperty("java.library.path", project.findProperty("jniLibPath") ?: "../../ffi/zig/zig-out/lib")
}

java {
    withSourcesJar()
    withJavadocJar()
}
