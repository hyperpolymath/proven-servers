<?php

// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Top-level namespace and FFI library loader for the proven-servers PHP bindings.
//
// Usage:
//   use ProvenServers\ProvenServers;
//   $lib = ProvenServers::loadLibrary('httpd');

declare(strict_types=1);

namespace ProvenServers;

/**
 * Central FFI library loader for proven-servers.
 *
 * Loads Zig-compiled shared libraries (.so/.dylib/.dll) via the PHP FFI
 * extension. Each protocol module calls loadLibrary() to obtain a handle
 * for its Zig FFI functions.
 *
 * Library search order:
 *   1. PROVEN_LIB_DIR environment variable
 *   2. Relative paths for in-tree builds
 *   3. System library paths (dlopen default)
 */
final class ProvenServers
{
    /** @var string Binding version, tracking the proven-servers ABI. */
    public const VERSION = '0.1.0';

    /** @var array<string, \FFI> Cached loaded libraries by protocol name. */
    private static array $libraries = [];

    /**
     * Build the platform-specific shared library filename.
     *
     * @param string $protocol Protocol name without "proven-" prefix.
     * @return string The library filename, e.g. "libproven_httpd.so".
     */
    public static function libraryFilename(string $protocol): string
    {
        $base = 'proven_' . str_replace('-', '_', $protocol);
        if (PHP_OS_FAMILY === 'Darwin') {
            return "lib{$base}.dylib";
        }
        if (PHP_OS_FAMILY === 'Windows') {
            return "{$base}.dll";
        }
        return "lib{$base}.so";
    }

    /**
     * Search for the shared library file.
     *
     * @param string $protocol Protocol name.
     * @return string|null Absolute path to the library, or null for system search.
     */
    public static function findLibrary(string $protocol): ?string
    {
        $filename = self::libraryFilename($protocol);

        // Priority 1: PROVEN_LIB_DIR environment variable.
        $envDir = getenv('PROVEN_LIB_DIR');
        if ($envDir !== false) {
            $candidate = $envDir . DIRECTORY_SEPARATOR . $filename;
            if (file_exists($candidate)) {
                return $candidate;
            }
        }

        // Priority 2: relative to package root (in-tree builds).
        $pkgRoot = dirname(__DIR__, 3);
        $relativePaths = [
            "ffi/zig/zig-out/lib/{$filename}",
            "protocols/proven-{$protocol}/ffi/zig/zig-out/lib/{$filename}",
            "target/release/{$filename}",
            "build/{$filename}",
        ];
        foreach ($relativePaths as $rel) {
            $candidate = $pkgRoot . DIRECTORY_SEPARATOR . $rel;
            if (file_exists($candidate)) {
                return $candidate;
            }
        }

        return null;
    }

    /**
     * Load a Zig shared library for the given protocol.
     *
     * @param string $protocol Protocol name, e.g. "httpd", "dns".
     * @param string $cdef     C header declarations for FFI::cdef().
     * @return \FFI The loaded FFI instance.
     * @throws \RuntimeException If the library cannot be found or loaded.
     */
    public static function loadLibrary(string $protocol, string $cdef): \FFI
    {
        if (isset(self::$libraries[$protocol])) {
            return self::$libraries[$protocol];
        }

        $path = self::findLibrary($protocol);
        $libName = $path ?? self::libraryFilename($protocol);

        try {
            $ffi = \FFI::cdef($cdef, $libName);
        } catch (\FFI\Exception $e) {
            throw new \RuntimeException(
                "Cannot load proven-{$protocol} shared library ({$libName}). " .
                "Set PROVEN_LIB_DIR or ensure the library is on the search path. " .
                "Original: {$e->getMessage()}"
            );
        }

        self::$libraries[$protocol] = $ffi;
        return $ffi;
    }
}
