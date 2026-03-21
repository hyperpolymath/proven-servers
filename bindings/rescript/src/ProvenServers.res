// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Top-level module for proven-servers ReScript bindings.
//
// This module provides the entry point for the ReScript binding layer
// that wraps the Zig FFI via WASM or Node N-API.  It re-exports the
// shared types (ProvenCore, ProvenError) and exposes library lifecycle
// functions (init, free, version) as @module externals targeting the
// compiled WASM/N-API binary.
//
// Architecture:
//   Idris2 ABI  -->  Zig FFI  -->  WASM / N-API  -->  ReScript @module
//
// Each protocol module (ProvenHttpd, ProvenDns, etc.) imports ProvenCore
// for shared types and ProvenError for the unified error surface.
//
// Usage:
//   let handle = ProvenServers.init()
//   // ... use protocol modules ...
//   ProvenServers.free(handle)

// ===========================================================================
// FFI bindings to the proven-servers native module
// ===========================================================================

/// The native module is loaded from the WASM or N-API binary.
/// When targeting WASM, compile with: zig build -Dtarget=wasm32-wasi
/// When targeting Node N-API, compile with: zig build -Dtarget=native

/// Opaque pointer type representing the native library handle.
/// Wraps the C void* returned by proven_servers_init().
type nativeHandle

/// Initialise the proven-servers library.
/// Returns a native handle or null on failure.
/// Caller MUST call free() when done.
@module("proven_servers")
external nativeInit: unit => Js.Nullable.t<nativeHandle> = "proven_servers_init"

/// Free the native library handle and release all resources.
@module("proven_servers")
external nativeFree: nativeHandle => unit = "proven_servers_free"

/// Check whether a native handle is initialised.
/// Returns 1 if initialised, 0 otherwise.
@module("proven_servers")
external nativeIsInitialized: nativeHandle => int = "proven_servers_is_initialized"

/// Get the library version string.
@module("proven_servers")
external nativeVersion: unit => string = "proven_servers_version"

/// Get the library build information string.
@module("proven_servers")
external nativeBuildInfo: unit => string = "proven_servers_build_info"

/// Get the last error message from the FFI layer.
/// Returns null if no error has occurred.
@module("proven_servers")
external nativeLastError: unit => Js.Nullable.t<string> = "proven_servers_last_error"

// ===========================================================================
// Safe wrappers
// ===========================================================================

/// Initialise the library and return a result.
/// Returns Error(InitError) if the native init call returns null.
let init = (): result<nativeHandle, ProvenError.provenError> =>
  switch Js.Nullable.toOption(nativeInit()) {
  | Some(handle) => Ok(handle)
  | None => Error(ProvenError.InitError("proven_servers_init returned null"))
  }

/// Free a library handle.  Safe to call multiple times (idempotent on null).
let free = (handle: nativeHandle): unit => nativeFree(handle)

/// Check whether a handle is still valid and initialised.
let isInitialized = (handle: nativeHandle): bool => nativeIsInitialized(handle) != 0

/// Get the library version.
let version = (): string => nativeVersion()

/// Get the library build info.
let buildInfo = (): string => nativeBuildInfo()

/// Retrieve the last FFI error as an option.
let lastError = (): option<string> => Js.Nullable.toOption(nativeLastError())

// ===========================================================================
// Protocol registry
// ===========================================================================

/// All protocol identifiers known to this binding layer.
/// This list matches the 98 protocol directories under protocols/.
/// The first 10 have full ReScript bindings; the rest follow the same
/// pattern and can be generated mechanically.
let allProtocols: array<ProvenError.protocol> = [
  Httpd,
  Dns,
  Smtp,
  Ftp,
  SshBastion,
  Mqtt,
  Grpc,
  Graphql,
  Tls,
  Firewall,
  Websocket,
]

/// Number of protocols with full ReScript bindings.
let boundProtocolCount = 11

/// Total number of protocols in the proven-servers suite.
let totalProtocolCount = 98
