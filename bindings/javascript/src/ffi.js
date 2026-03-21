// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Shared FFI loading utilities for the proven-servers JavaScript bindings.
//
// Supports two loading strategies:
//   1. N-API native addon (.node files) — for Node.js/Deno with native addons
//   2. WASM module (.wasm files) — for portable/sandboxed environments
//
// Each protocol module calls loadLibrary() with its protocol name to obtain
// a handle for calling FFI functions.

import { createRequire } from "node:module";
import { join, resolve } from "node:path";
import { existsSync } from "node:fs";
import { readFile } from "node:fs/promises";

/**
 * Build the platform-specific native addon filename.
 *
 * @param {string} protocol - Protocol name without the "proven-" prefix.
 * @returns {string} The filename, e.g. "proven_httpd.linux-x64.node".
 */
function nativeAddonFilename(protocol) {
    const base = `proven_${protocol.replace(/-/g, "_")}`;
    const platform = process.platform;
    const arch = process.arch;
    return `${base}.${platform}-${arch}.node`;
}

/**
 * Build the WASM module filename.
 *
 * @param {string} protocol - Protocol name without the "proven-" prefix.
 * @returns {string} The filename, e.g. "proven_httpd.wasm".
 */
function wasmFilename(protocol) {
    return `proven_${protocol.replace(/-/g, "_")}.wasm`;
}

/**
 * Search directories for the library file, in priority order:
 *   1. PROVEN_LIB_DIR environment variable
 *   2. Explicit searchDir argument
 *   3. Relative paths for in-tree builds
 *
 * @param {string} filename - The library filename to search for.
 * @param {string} [searchDir] - Optional directory to search first.
 * @param {string} protocol - Protocol name for in-tree path resolution.
 * @returns {string|null} Absolute path to the library file, or null if not found.
 */
function findLibrary(filename, searchDir, protocol) {
    // Priority 1: environment variable
    const envDir = process.env.PROVEN_LIB_DIR;
    if (envDir) {
        const candidate = join(envDir, filename);
        if (existsSync(candidate)) return candidate;
    }

    // Priority 2: explicit search directory
    if (searchDir) {
        const candidate = join(searchDir, filename);
        if (existsSync(candidate)) return candidate;
    }

    // Priority 3: relative to package root (in-tree builds)
    const pkgRoot = resolve(import.meta.dirname, "..", "..", "..");
    const relativePaths = [
        `ffi/zig/zig-out/lib/${filename}`,
        `protocols/proven-${protocol}/ffi/zig/zig-out/lib/${filename}`,
        `target/release/${filename}`,
        `build/${filename}`,
    ];
    for (const rel of relativePaths) {
        const candidate = join(pkgRoot, rel);
        if (existsSync(candidate)) return candidate;
    }

    return null;
}

/**
 * Load a native N-API addon for the given protocol.
 *
 * @param {string} protocol - Protocol name, e.g. "httpd", "dns", "firewall".
 * @param {string} [searchDir] - Optional directory to search first.
 * @returns {Promise<object>} The loaded native addon module.
 * @throws {Error} If the addon cannot be found or loaded.
 */
export async function loadNativeAddon(protocol, searchDir) {
    const filename = nativeAddonFilename(protocol);
    const libPath = findLibrary(filename, searchDir, protocol);
    if (!libPath) {
        throw new Error(
            `Cannot find proven-${protocol} native addon (${filename}). ` +
            `Set PROVEN_LIB_DIR or pass searchDir.`
        );
    }
    const require = createRequire(import.meta.url);
    return require(libPath);
}

/**
 * Load a WASM module for the given protocol.
 *
 * @param {string} protocol - Protocol name, e.g. "httpd", "dns", "firewall".
 * @param {string} [searchDir] - Optional directory to search first.
 * @returns {Promise<WebAssembly.Instance>} The instantiated WASM module.
 * @throws {Error} If the WASM file cannot be found or loaded.
 */
export async function loadWasmModule(protocol, searchDir) {
    const filename = wasmFilename(protocol);
    const libPath = findLibrary(filename, searchDir, protocol);
    if (!libPath) {
        throw new Error(
            `Cannot find proven-${protocol} WASM module (${filename}). ` +
            `Set PROVEN_LIB_DIR or pass searchDir.`
        );
    }
    const wasmBytes = await readFile(libPath);
    const { instance } = await WebAssembly.instantiate(wasmBytes, {});
    return instance;
}

/**
 * Load the FFI library for a given protocol, trying N-API first, then WASM.
 *
 * @param {string} protocol - Protocol name, e.g. "httpd", "dns", "firewall".
 * @param {object} [options] - Loading options.
 * @param {string} [options.searchDir] - Optional directory to search.
 * @param {"napi"|"wasm"|"auto"} [options.backend="auto"] - Force a specific backend.
 * @returns {Promise<object>} The loaded library handle with callable FFI functions.
 */
export async function loadLibrary(protocol, options = {}) {
    const { searchDir, backend = "auto" } = options;

    if (backend === "napi" || backend === "auto") {
        try {
            return await loadNativeAddon(protocol, searchDir);
        } catch (err) {
            if (backend === "napi") throw err;
            // Fall through to WASM on auto
        }
    }

    if (backend === "wasm" || backend === "auto") {
        const instance = await loadWasmModule(protocol, searchDir);
        return instance.exports;
    }

    throw new Error(`Unknown backend: ${backend}`);
}
