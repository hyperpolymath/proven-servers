// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Top-level module for proven-servers Kotlin/JNI bindings.
//
// Provides Kotlin-idiomatic wrappers around the formally-verified Zig FFI
// context pools for 9 core server protocols. Each protocol module exposes:
//   - Kotlin enum classes with Int values matching Idris2 ABI tags
//   - JNI native external declarations (sharing the Java JNI .so)
//   - Kotlin-idiomatic wrappers returning Result types
//
// Protocols:
//   ProvenHttp, ProvenDns, ProvenSmtp, ProvenSsh, ProvenFtp,
//   ProvenMqtt, ProvenGrpc, ProvenGraphql, ProvenFirewall

package com.hyperpolymath.proven

/**
 * Namespace for proven-servers library metadata and JNI initialization.
 *
 * Call [loadLibrary] before using any protocol bindings.
 */
public object ProvenServers {

    /** The library version string. */
    public const val VERSION: String = "0.1.0"

    /** Human-readable library description. */
    public const val DESCRIPTION: String = "Kotlin bindings for proven-servers (Idris2 ABI + Zig FFI)"

    /** Maximum context pool size shared by all protocol FFI implementations. */
    public const val MAX_POOL_SLOTS: Int = 64

    /** Whether the native library has been loaded. */
    @Volatile
    private var loaded: Boolean = false

    /**
     * Load the proven-servers JNI native library.
     *
     * This must be called once before using any protocol bindings.
     * Subsequent calls are no-ops.
     *
     * @param libraryName The native library name (default: "proven_servers_jni").
     */
    @JvmStatic
    public fun loadLibrary(libraryName: String = "proven_servers_jni") {
        if (!loaded) {
            System.loadLibrary(libraryName)
            loaded = true
        }
    }
}
