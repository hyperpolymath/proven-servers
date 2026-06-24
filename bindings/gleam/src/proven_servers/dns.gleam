//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// DNS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DNS` and its submodules:
//// - `DNS`            -- core constants (ports, size limits)
//// - `DNS.RecordType` -- DNS record types
////
//// All constants match the values in the Idris2 `DNS` module, which
//// are derived from RFC 1035, RFC 6891, and related RFCs.

// ===========================================================================
// DNS Constants
// ===========================================================================

/// Standard DNS port (RFC 1035).
pub const dns_port = 53

/// Maximum UDP message size without EDNS (RFC 1035 Section 4.2.1).
pub const max_udp_size = 512

/// Maximum TCP message size (RFC 1035 Section 4.2.2).
pub const max_tcp_size = 65_535

/// Maximum label length in bytes (RFC 1035 Section 2.3.4).
pub const max_label_length = 63

/// Maximum total domain name length including dots (RFC 1035).
pub const max_name_length = 253

/// EDNS(0) default UDP payload size (RFC 6891).
pub const edns_udp_size = 4096

// ===========================================================================
// DNS Record Type
// ===========================================================================

/// DNS resource record types.
///
/// Discriminant values match the standard DNS type codes from IANA.
pub type RecordType {
  /// A record: IPv4 address (RFC 1035).
  A
  /// AAAA record: IPv6 address (RFC 3596).
  Aaaa
  /// CNAME record: canonical name alias (RFC 1035).
  Cname
  /// MX record: mail exchange (RFC 1035).
  Mx
  /// NS record: authoritative name server (RFC 1035).
  Ns
  /// TXT record: text strings (RFC 1035).
  Txt
  /// SOA record: start of authority (RFC 1035).
  Soa
  /// SRV record: service locator (RFC 2782).
  Srv
  /// PTR record: pointer / reverse lookup (RFC 1035).
  Ptr
}

/// Convert a `RecordType` to its DNS type code (IANA registered value).
pub fn record_type_to_int(rt: RecordType) -> Int {
  case rt {
    A -> 1
    Ns -> 2
    Cname -> 5
    Soa -> 6
    Ptr -> 12
    Mx -> 15
    Txt -> 16
    Aaaa -> 28
    Srv -> 33
  }
}

/// Decode from a DNS type code (IANA registered value).
pub fn record_type_from_int(code: Int) -> Result(RecordType, Nil) {
  case code {
    1 -> Ok(A)
    2 -> Ok(Ns)
    5 -> Ok(Cname)
    6 -> Ok(Soa)
    12 -> Ok(Ptr)
    15 -> Ok(Mx)
    16 -> Ok(Txt)
    28 -> Ok(Aaaa)
    33 -> Ok(Srv)
    _ -> Error(Nil)
  }
}

/// Mnemonic name (e.g. "A", "AAAA", "CNAME").
pub fn record_type_mnemonic(rt: RecordType) -> String {
  case rt {
    A -> "A"
    Aaaa -> "AAAA"
    Cname -> "CNAME"
    Mx -> "MX"
    Ns -> "NS"
    Txt -> "TXT"
    Soa -> "SOA"
    Srv -> "SRV"
    Ptr -> "PTR"
  }
}

/// Whether this record type holds an address (A or AAAA).
pub fn record_type_is_address(rt: RecordType) -> Bool {
  case rt {
    A | Aaaa -> True
    _ -> False
  }
}

/// Whether this is an infrastructure record (NS, SOA).
pub fn record_type_is_infrastructure(rt: RecordType) -> Bool {
  case rt {
    Ns | Soa -> True
    _ -> False
  }
}

// ===========================================================================
// DNS Response Code
// ===========================================================================

/// DNS response codes (RCODE, RFC 1035 Section 4.1.1).
pub type ResponseCode {
  /// No error condition (0).
  NoError
  /// Format error (1).
  FormatError
  /// Server failure (2).
  ServerFailure
  /// Name error / NXDOMAIN (3).
  NameError
  /// Not implemented (4).
  DnsNotImplemented
  /// Refused (5).
  Refused
}

/// Convert a `ResponseCode` to its RCODE value.
pub fn response_code_to_int(rc: ResponseCode) -> Int {
  case rc {
    NoError -> 0
    FormatError -> 1
    ServerFailure -> 2
    NameError -> 3
    DnsNotImplemented -> 4
    Refused -> 5
  }
}

/// Decode from a 4-bit RCODE value.
pub fn response_code_from_int(code: Int) -> Result(ResponseCode, Nil) {
  case code {
    0 -> Ok(NoError)
    1 -> Ok(FormatError)
    2 -> Ok(ServerFailure)
    3 -> Ok(NameError)
    4 -> Ok(DnsNotImplemented)
    5 -> Ok(Refused)
    _ -> Error(Nil)
  }
}

/// Whether this response indicates success.
pub fn response_code_is_success(rc: ResponseCode) -> Bool {
  rc == NoError
}

/// Whether this response indicates the domain does not exist.
pub fn response_code_is_nxdomain(rc: ResponseCode) -> Bool {
  rc == NameError
}

/// Display name for a response code.
pub fn response_code_to_string(rc: ResponseCode) -> String {
  case rc {
    NoError -> "NOERROR"
    FormatError -> "FORMERR"
    ServerFailure -> "SERVFAIL"
    NameError -> "NXDOMAIN"
    DnsNotImplemented -> "NOTIMP"
    Refused -> "REFUSED"
  }
}

// ===========================================================================
// Domain Name Validation
// ===========================================================================

/// Errors that can occur during domain name validation.
pub type DomainNameError {
  /// A label exceeds the 63-byte limit.
  LabelTooLong(label: String, length: Int)
  /// The total name exceeds the 253-byte limit.
  NameTooLong(name: String, length: Int)
  /// The name is empty.
  EmptyName
  /// A label is empty (e.g. from consecutive dots).
  EmptyLabel
}

// validate_domain_name (and its helper validate_labels) removed: unproven
// reimplementation. The verified check lives in the Idris2/Zig core; calling it
// needs @external FFI wiring not yet present here.
// Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md
