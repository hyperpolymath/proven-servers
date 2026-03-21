// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Top-level entry point for the proven-servers Java bindings.
// Loads the native shared library and exposes core lifecycle operations
// defined in the Idris2 ABI (ProvenServers.ABI.Foreign).

package com.hyperpolymath.proven;

/**
 * Top-level class for the proven-servers Java bindings.
 *
 * <p>Loads the native {@code proven_servers} shared library and provides
 * core lifecycle operations (init, free, version, error handling). Each
 * protocol module (HTTP, DNS, Firewall, etc.) is in its own class under
 * this package.</p>
 *
 * <p>The native library is a Zig-compiled shared object whose C-ABI
 * is formally specified in Idris2 dependent types.</p>
 *
 * @author Jonathan D.A. Jewell
 * @see ProvenError
 */
public final class ProvenServers {

    /** Native library name (loaded without platform prefix/suffix). */
    private static final String NATIVE_LIB = "proven_servers";

    static {
        System.loadLibrary(NATIVE_LIB);
    }

    /** Prevent instantiation -- this is a static utility class. */
    private ProvenServers() {
        throw new AssertionError("ProvenServers is not instantiable");
    }

    // -----------------------------------------------------------------------
    // JNI native method declarations (from ProvenServers.ABI.Foreign)
    // -----------------------------------------------------------------------

    /**
     * Initialise the native library. Returns an opaque handle (pointer)
     * as a long, or 0 on failure.
     *
     * @return opaque handle to the library instance, or 0 on failure
     */
    private static native long nativeInit();

    /**
     * Release all resources associated with the given library handle.
     *
     * @param handle opaque library handle from {@link #nativeInit()}
     */
    private static native void nativeFree(long handle);

    /**
     * Get the library version string.
     *
     * @return version string (e.g. "0.1.0")
     */
    private static native String nativeVersion();

    /**
     * Get library build information.
     *
     * @return build info string
     */
    private static native String nativeBuildInfo();

    /**
     * Get the last error message from the native library, or null if none.
     *
     * @return last error message, or null
     */
    private static native String nativeLastError();

    /**
     * Check whether the library instance is initialised.
     *
     * @param handle opaque library handle
     * @return 1 if initialised, 0 otherwise
     */
    private static native int nativeIsInitialized(long handle);

    // -----------------------------------------------------------------------
    // Safe wrapper methods
    // -----------------------------------------------------------------------

    /**
     * Initialise the proven-servers native library.
     *
     * @return an opaque handle for use with other API calls
     * @throws ProvenError if the library fails to initialise
     */
    public static long init() throws ProvenError {
        long handle = nativeInit();
        if (handle == 0) {
            throw new ProvenError("Failed to initialise proven-servers native library");
        }
        return handle;
    }

    /**
     * Release all resources held by the native library instance.
     *
     * @param handle the handle returned by {@link #init()}
     */
    public static void free(long handle) {
        nativeFree(handle);
    }

    /**
     * Get the library version string.
     *
     * @return version string (e.g. "0.1.0")
     */
    public static String version() {
        return nativeVersion();
    }

    /**
     * Get the library build information string.
     *
     * @return build info string
     */
    public static String buildInfo() {
        return nativeBuildInfo();
    }

    /**
     * Retrieve the last error message from the native library.
     *
     * @return the last error message, or {@code null} if no error
     */
    public static String lastError() {
        return nativeLastError();
    }

    /**
     * Check whether a library instance is currently initialised.
     *
     * @param handle opaque library handle
     * @return {@code true} if the instance is initialised
     */
    public static boolean isInitialized(long handle) {
        return nativeIsInitialized(handle) != 0;
    }
}
