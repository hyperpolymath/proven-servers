// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Top-level entry point for the proven-servers C# bindings.
// Loads the native shared library via P/Invoke and exposes core lifecycle
// operations defined in the Idris2 ABI (ProvenServers.ABI.Foreign).

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>
    /// Top-level class for the proven-servers C# bindings.
    /// Provides core lifecycle operations (init, free, version, error handling).
    /// Each protocol module is in its own class within this namespace.
    /// </summary>
    /// <remarks>
    /// The native library is a Zig-compiled shared object whose C-ABI
    /// is formally specified in Idris2 dependent types.
    /// </remarks>
    public static class ProvenLib
    {
        /// <summary>Native library name (resolved per platform).</summary>
        private const string NativeLib = "proven_servers";

        // -------------------------------------------------------------------
        // P/Invoke declarations (from ProvenServers.ABI.Foreign)
        // -------------------------------------------------------------------

        /// <summary>Initialise the native library. Returns an opaque handle, or 0 on failure.</summary>
        [DllImport(NativeLib, EntryPoint = "proven_servers_init")]
        private static extern ulong NativeInit();

        /// <summary>Release all resources for the given handle.</summary>
        [DllImport(NativeLib, EntryPoint = "proven_servers_free")]
        private static extern void NativeFree(ulong handle);

        /// <summary>Get the library version string pointer.</summary>
        [DllImport(NativeLib, EntryPoint = "proven_servers_version")]
        private static extern IntPtr NativeVersion();

        /// <summary>Get the library build info string pointer.</summary>
        [DllImport(NativeLib, EntryPoint = "proven_servers_build_info")]
        private static extern IntPtr NativeBuildInfo();

        /// <summary>Get the last error message pointer, or IntPtr.Zero if none.</summary>
        [DllImport(NativeLib, EntryPoint = "proven_servers_last_error")]
        private static extern IntPtr NativeLastError();

        /// <summary>Check whether the library instance is initialised.</summary>
        [DllImport(NativeLib, EntryPoint = "proven_servers_is_initialized")]
        private static extern uint NativeIsInitialized(ulong handle);

        // -------------------------------------------------------------------
        // Safe wrapper methods
        // -------------------------------------------------------------------

        /// <summary>
        /// Initialise the proven-servers native library.
        /// </summary>
        /// <returns>An opaque handle for use with other API calls.</returns>
        /// <exception cref="ProvenError">Thrown if the library fails to initialise.</exception>
        public static ulong Init()
        {
            ulong handle = NativeInit();
            if (handle == 0)
                throw new ProvenError("Failed to initialise proven-servers native library");
            return handle;
        }

        /// <summary>
        /// Release all resources held by the native library instance.
        /// </summary>
        /// <param name="handle">The handle returned by <see cref="Init"/>.</param>
        public static void Free(ulong handle) => NativeFree(handle);

        /// <summary>Get the library version string.</summary>
        public static string Version()
        {
            IntPtr ptr = NativeVersion();
            return Marshal.PtrToStringAnsi(ptr) ?? "";
        }

        /// <summary>Get the library build information string.</summary>
        public static string BuildInfo()
        {
            IntPtr ptr = NativeBuildInfo();
            return Marshal.PtrToStringAnsi(ptr) ?? "";
        }

        /// <summary>Retrieve the last error message, or null if none.</summary>
        public static string? LastError()
        {
            IntPtr ptr = NativeLastError();
            if (ptr == IntPtr.Zero) return null;
            return Marshal.PtrToStringAnsi(ptr);
        }

        /// <summary>Check whether a library instance is currently initialised.</summary>
        public static bool IsInitialized(ulong handle) => NativeIsInitialized(handle) != 0;
    }
}
