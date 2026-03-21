// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// DNS protocol bindings for proven-servers.
///
/// Mirrors the Idris2 `DNS` module and `DNS.RecordType`. Constants derive
/// from RFC 1035 and RFC 6891. Record type discriminants match IANA DNS
/// type codes.
///
/// See `protocols/proven-dns/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// DNS Constants
// ---------------------------------------------------------------------------

/// Standard DNS port (RFC 1035).
const int dnsPort = 53;

/// Maximum UDP message size without EDNS (RFC 1035 Section 4.2.1).
const int maxUdpSize = 512;

/// Maximum TCP message size (RFC 1035 Section 4.2.2).
const int maxTcpSize = 65535;

/// Maximum label length in bytes (RFC 1035 Section 2.3.4).
const int maxLabelLength = 63;

/// Maximum total domain name length including dots (RFC 1035).
const int maxNameLength = 253;

/// EDNS(0) default UDP payload size (RFC 6891).
const int ednsUdpSize = 4096;

// ---------------------------------------------------------------------------
// Record Type (IANA DNS type codes)
// ---------------------------------------------------------------------------

/// DNS resource record types.
///
/// Discriminant values are the standard IANA DNS type codes.
enum RecordType {
  /// A record: IPv4 address (RFC 1035).
  a(1),

  /// NS record: name server (RFC 1035).
  ns(2),

  /// CNAME record: canonical name (RFC 1035).
  cname(5),

  /// SOA record: start of authority (RFC 1035).
  soa(6),

  /// PTR record: pointer (RFC 1035).
  ptr(12),

  /// MX record: mail exchange (RFC 1035).
  mx(15),

  /// TXT record: text (RFC 1035).
  txt(16),

  /// AAAA record: IPv6 address (RFC 3596).
  aaaa(28),

  /// SRV record: service locator (RFC 2782).
  srv(33);

  /// The IANA type code.
  final int code;

  const RecordType(this.code);

  /// Decode from an IANA type code.
  static RecordType? fromCode(int code) {
    for (final rt in RecordType.values) {
      if (rt.code == code) return rt;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Response Code (RFC 1035 Section 4.1.1)
// ---------------------------------------------------------------------------

/// DNS response codes (RCODE).
enum DnsResponseCode {
  noError(0),
  formErr(1),
  servFail(2),
  nxDomain(3),
  notImp(4),
  refused(5);

  final int code;
  const DnsResponseCode(this.code);

  static DnsResponseCode? fromCode(int code) {
    for (final rc in DnsResponseCode.values) {
      if (rc.code == code) return rc;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// DnsContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// A DNS context slot in the Zig FFI pool.
///
/// Wraps the `dns_*` C functions with automatic resource cleanup.
class DnsContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('dns_destroy_context');
  late final _getQueryType = _ffi.lookupGetTag('dns_get_query_type');
  late final _setResponseCode = _ffi.lookupSetTag('dns_set_response_code');
  late final _sendResponse = _ffi.lookupSend('dns_send_response');

  DnsContext._(this._ffi, this._slot);

  /// Create a new DNS context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory DnsContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('dns_create_context');
    final slot = ProvenError.checkSlot(create());
    return DnsContext._(ffi, slot);
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

  /// Get the parsed query record type.
  RecordType? getQueryType() {
    _checkDisposed();
    return RecordType.fromCode(_getQueryType(_slot));
  }

  /// Set the response code.
  ///
  /// Throws [ProvenError] on failure.
  void setResponseCode(DnsResponseCode rcode) {
    _checkDisposed();
    ProvenError.checkStatus(_setResponseCode(_slot, rcode.code));
  }

  /// Send the constructed DNS response.
  ///
  /// Throws [ProvenError] on failure.
  void sendResponse() {
    _checkDisposed();
    ProvenError.checkStatus(_sendResponse(_slot));
  }
}
