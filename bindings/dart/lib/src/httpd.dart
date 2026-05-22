// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// HTTP/1.1+ protocol bindings for proven-servers.
///
/// Mirrors the Idris2 modules `HTTP.Method`, `HTTP.Status`,
/// `HTTPABI.Layout`, and `HTTPABI.Transitions`. All tag values match
/// the `httpMethodToTag` and related functions in the ABI.
///
/// See `protocols/proven-httpd/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// HTTP Method (HTTPABI.Layout.HttpMethod, tags 0-8)
// ---------------------------------------------------------------------------

/// Standard HTTP request methods (RFC 7231, RFC 5789).
///
/// Tag values match `httpMethodToTag` in `HTTPABI.Layout`.
enum HttpMethod {
  /// Retrieve a representation of the target resource.
  get_(0, 'GET'),

  /// Perform resource-specific processing on the request payload.
  post(1, 'POST'),

  /// Replace all current representations of the target resource.
  put(2, 'PUT'),

  /// Remove all current representations of the target resource.
  delete_(3, 'DELETE'),

  /// Apply partial modifications to a resource (RFC 5789).
  patch(4, 'PATCH'),

  /// Same as GET but only transfer status line and headers.
  head(5, 'HEAD'),

  /// Describe the communication options for the target resource.
  options(6, 'OPTIONS'),

  /// Perform a message loop-back test along the path to the target.
  trace(7, 'TRACE'),

  /// Establish a tunnel to the server identified by the target resource.
  connect(8, 'CONNECT');

  /// The C-ABI tag value.
  final int tag;

  /// The canonical HTTP method string.
  final String httpName;

  const HttpMethod(this.tag, this.httpName);

  /// Decode from a C-ABI tag value. Returns `null` for unknown tags.
  static HttpMethod? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// HTTP Version (tags 0-2)
// ---------------------------------------------------------------------------

/// HTTP protocol versions.
enum HttpVersion {
  http1_0(0, 'HTTP/1.0'),
  http1_1(1, 'HTTP/1.1'),
  http2(2, 'HTTP/2');

  final int tag;
  final String label;
  const HttpVersion(this.tag, this.label);

  static HttpVersion? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// Request Phase (HTTPABI.Transitions, tags 0-5)
// ---------------------------------------------------------------------------

/// HTTP request lifecycle phases (typestate pattern).
enum RequestPhase {
  idle(0),
  parsing(1),
  parsed(2),
  handling(3),
  responded(4),
  closed(5);

  final int tag;
  const RequestPhase(this.tag);

  static RequestPhase? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// Content Type (HTTPABI.Layout, tags 0-6)
// ---------------------------------------------------------------------------

/// Common HTTP content types.
enum ContentType {
  textPlain(0),
  textHtml(1),
  applicationJson(2),
  applicationXml(3),
  multipartForm(4),
  urlencoded(5),
  octetStream(6);

  final int tag;
  const ContentType(this.tag);

  static ContentType? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// HttpContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// An HTTP context slot in the Zig FFI pool.
///
/// Wraps the `http_*` C functions with automatic resource cleanup.
/// Always call [dispose] when finished (or use in a try/finally block).
///
/// ```dart
/// final ctx = HttpContext.create(ffi);
/// try {
///   // use ctx...
/// } finally {
///   ctx.dispose();
/// }
/// ```
class HttpContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  // Cached native lookups
  late final _destroy = _ffi.lookupDestroyContext('http_destroy_context');
  late final _getMethod = _ffi.lookupGetTag('http_get_method');
  late final _getPhase = _ffi.lookupGetTag('http_get_phase');
  late final _getVersion = _ffi.lookupGetTag('http_get_version');
  late final _setStatus = _ffi.lookupSetTag('http_set_status');
  late final _sendResponse = _ffi.lookupSend('http_send_response');
  late final _keepAlive = _ffi.lookupSend('http_keep_alive_check');
  late final _reset = _ffi.lookupSend('http_reset_context');

  HttpContext._(this._ffi, this._slot);

  /// Create a new HTTP context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory HttpContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('http_create_context');
    final slot = ProvenError.checkSlot(create());
    return HttpContext._(ffi, slot);
  }

  /// Release the context slot back to the pool.
  void dispose() {
    if (!_disposed) {
      _destroy(_slot);
      _disposed = true;
    }
  }

  void _checkDisposed() {
    if (_disposed) throw const ProvenError('context already disposed');
  }

  /// Get the parsed HTTP method.
  HttpMethod? getMethod() {
    _checkDisposed();
    return HttpMethod.fromTag(_getMethod(_slot));
  }

  /// Get the current request phase.
  RequestPhase? getPhase() {
    _checkDisposed();
    return RequestPhase.fromTag(_getPhase(_slot));
  }

  /// Get the HTTP version.
  HttpVersion? getVersion() {
    _checkDisposed();
    return HttpVersion.fromTag(_getVersion(_slot));
  }

  /// Set the response status code tag.
  ///
  /// Throws [ProvenError] on invalid state.
  void setStatus(int statusTag) {
    _checkDisposed();
    ProvenError.checkStatus(_setStatus(_slot, statusTag));
  }

  /// Send the constructed response.
  ///
  /// Throws [ProvenError] on failure.
  void sendResponse() {
    _checkDisposed();
    ProvenError.checkStatus(_sendResponse(_slot));
  }

  /// Whether the connection supports keep-alive.
  bool get keepAlive {
    _checkDisposed();
    return _keepAlive(_slot) == 1;
  }

  /// Reset the context for a new request on the same connection.
  ///
  /// Throws [ProvenError] on failure.
  void reset() {
    _checkDisposed();
    ProvenError.checkStatus(_reset(_slot));
  }
}
