// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// dart:ffi DynamicLibrary loading for proven-servers.
///
/// Provides [ProvenFfi], the central entry point for loading the
/// `libproven_servers` shared library and accessing native function
/// pointers for all 10 core protocols.

import 'dart:ffi';
import 'dart:io' show Platform;

// ---------------------------------------------------------------------------
// Core library typedefs (src/abi/Foreign.idr -> ffi/zig/src/main.zig)
// ---------------------------------------------------------------------------

/// `void *proven_servers_init(void)`
typedef _InitC = Pointer<Void> Function();
typedef _InitDart = Pointer<Void> Function();

/// `void proven_servers_free(void *handle)`
typedef _FreeC = Void Function(Pointer<Void>);
typedef _FreeDart = void Function(Pointer<Void>);

/// `const char *proven_servers_version(void)`
typedef _VersionC = Pointer<Utf8> Function();
typedef _VersionDart = Pointer<Utf8> Function();

/// `uint32_t proven_servers_is_initialized(void *handle)`
typedef _IsInitC = Uint32 Function(Pointer<Void>);
typedef _IsInitDart = int Function(Pointer<Void>);

// ---------------------------------------------------------------------------
// Per-protocol context typedefs (shared pattern)
// ---------------------------------------------------------------------------

/// `int <proto>_create_context(void)` — slot-returning.
typedef CreateContextC = Int32 Function();
typedef CreateContextDart = int Function();

/// `void <proto>_destroy_context(int slot)`
typedef DestroyContextC = Void Function(Int32);
typedef DestroyContextDart = void Function(int);

/// `uint8_t <proto>_<op>(int slot, const uint8_t *data, uint32_t len)`
typedef ParseC = Uint8 Function(Int32, Pointer<Uint8>, Uint32);
typedef ParseDart = int Function(int, Pointer<Uint8>, int);

/// `uint8_t <proto>_get_<field>(int slot)` — single-byte getter.
typedef GetTagC = Uint8 Function(Int32);
typedef GetTagDart = int Function(int);

/// `uint8_t <proto>_set_<field>(int slot, uint8_t tag)` — single-byte setter.
typedef SetTagC = Uint8 Function(Int32, Uint8);
typedef SetTagDart = int Function(int, int);

/// `uint8_t <proto>_send(int slot)` — status-returning send.
typedef SendC = Uint8 Function(Int32);
typedef SendDart = int Function(int);

// ---------------------------------------------------------------------------
// ProvenFfi — shared library loader
// ---------------------------------------------------------------------------

/// Central FFI loader for the proven-servers shared library.
///
/// Usage:
/// ```dart
/// final ffi = ProvenFfi.load();
/// // or with explicit path:
/// final ffi = ProvenFfi.load('/usr/lib/libproven_servers.so');
/// ```
class ProvenFfi {
  /// The loaded [DynamicLibrary].
  final DynamicLibrary library;

  ProvenFfi._(this.library);

  /// Load the proven-servers shared library.
  ///
  /// If [path] is null, uses a platform-appropriate default name:
  /// - Linux: `libproven_servers.so`
  /// - macOS: `libproven_servers.dylib`
  /// - Windows: `proven_servers.dll`
  factory ProvenFfi.load([String? path]) {
    final libPath = path ?? _defaultLibraryPath();
    final lib = DynamicLibrary.open(libPath);
    return ProvenFfi._(lib);
  }

  static String _defaultLibraryPath() {
    if (Platform.isLinux) return 'libproven_servers.so';
    if (Platform.isMacOS) return 'libproven_servers.dylib';
    if (Platform.isWindows) return 'proven_servers.dll';
    throw UnsupportedError(
      'proven-servers: unsupported platform ${Platform.operatingSystem}',
    );
  }

  // -----------------------------------------------------------------------
  // Core lifecycle
  // -----------------------------------------------------------------------

  /// Initialise the library, returning an opaque handle.
  late final init = library.lookupFunction<_InitC, _InitDart>(
    'proven_servers_init',
  );

  /// Free the library handle.
  late final free = library.lookupFunction<_FreeC, _FreeDart>(
    'proven_servers_free',
  );

  /// Check whether a handle is initialised (returns 1 or 0).
  late final isInitialized = library.lookupFunction<_IsInitC, _IsInitDart>(
    'proven_servers_is_initialized',
  );

  // -----------------------------------------------------------------------
  // Lookup helpers for protocol modules
  // -----------------------------------------------------------------------

  /// Look up a C function returning `int` (slot-creating).
  CreateContextDart lookupCreateContext(String symbol) =>
      library.lookupFunction<CreateContextC, CreateContextDart>(symbol);

  /// Look up a C function accepting `(int slot)` returning `void`.
  DestroyContextDart lookupDestroyContext(String symbol) =>
      library.lookupFunction<DestroyContextC, DestroyContextDart>(symbol);

  /// Look up a parse function `(int slot, const uint8_t*, uint32_t) -> uint8_t`.
  ParseDart lookupParse(String symbol) =>
      library.lookupFunction<ParseC, ParseDart>(symbol);

  /// Look up a tag getter `(int slot) -> uint8_t`.
  GetTagDart lookupGetTag(String symbol) =>
      library.lookupFunction<GetTagC, GetTagDart>(symbol);

  /// Look up a tag setter `(int slot, uint8_t) -> uint8_t`.
  SetTagDart lookupSetTag(String symbol) =>
      library.lookupFunction<SetTagC, SetTagDart>(symbol);

  /// Look up a send function `(int slot) -> uint8_t`.
  SendDart lookupSend(String symbol) =>
      library.lookupFunction<SendC, SendDart>(symbol);
}
