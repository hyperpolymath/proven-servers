// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DNS protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module DNS and its submodules:
// - DNS           -- core constants (ports, size limits)
// - DNS.RecordType -- DNS record types
//
// All constants match the values in the Idris2 DNS module, which
// are derived from RFC 1035, RFC 6891, and related RFCs.

// ===========================================================================
// DNS Constants (DNS module)
// ===========================================================================

/// Standard DNS port (RFC 1035). Matches dnsPort in DNS.
let dnsPort = 53

/// Maximum UDP message size without EDNS (RFC 1035 Section 4.2.1).
/// Matches maxUdpSize in DNS.
let maxUdpSize = 512

/// Maximum TCP message size (RFC 1035 Section 4.2.2).
/// Matches maxTcpSize in DNS.
let maxTcpSize = 65535

/// Maximum label length in bytes (RFC 1035 Section 2.3.4).
/// Matches maxLabelLength in DNS.
let maxLabelLength = 63

/// Maximum total domain name length including dots (RFC 1035).
/// Matches maxNameLength in DNS.
let maxNameLength = 253

/// EDNS(0) default UDP payload size (RFC 6891).
/// Matches ednsUdpSize in DNS.
let ednsUdpSize = 4096

// ===========================================================================
// DNS Record Type
// ===========================================================================

/// DNS resource record types.
/// Covers the 9 record types defined in the proven-dns RecordType module.
/// Discriminant values match the standard DNS type codes from IANA.
type recordType =
  | @as(1) A
  | @as(2) Ns
  | @as(5) Cname
  | @as(6) Soa
  | @as(12) Ptr
  | @as(15) Mx
  | @as(16) Txt
  | @as(28) Aaaa
  | @as(33) Srv

/// All supported record types in IANA type code order.
let allRecordTypes: array<recordType> = [A, Ns, Cname, Soa, Ptr, Mx, Txt, Aaaa, Srv]

/// Decode from a DNS type code (IANA registered value).
let recordTypeFromTypeCode = (code: int): option<recordType> =>
  switch code {
  | 1 => Some(A)
  | 2 => Some(Ns)
  | 5 => Some(Cname)
  | 6 => Some(Soa)
  | 12 => Some(Ptr)
  | 15 => Some(Mx)
  | 16 => Some(Txt)
  | 28 => Some(Aaaa)
  | 33 => Some(Srv)
  | _ => None
  }

/// Convert to the DNS type code (IANA registered value).
let recordTypeToTypeCode = (rt: recordType): int =>
  switch rt {
  | A => 1
  | Ns => 2
  | Cname => 5
  | Soa => 6
  | Ptr => 12
  | Mx => 15
  | Txt => 16
  | Aaaa => 28
  | Srv => 33
  }

/// Mnemonic name (e.g. "A", "AAAA", "CNAME").
let recordTypeMnemonic = (rt: recordType): string =>
  switch rt {
  | A => "A"
  | Aaaa => "AAAA"
  | Cname => "CNAME"
  | Mx => "MX"
  | Ns => "NS"
  | Txt => "TXT"
  | Soa => "SOA"
  | Srv => "SRV"
  | Ptr => "PTR"
  }

/// Whether this record type holds an address (A or AAAA).
let recordTypeIsAddress = (rt: recordType): bool =>
  switch rt {
  | A | Aaaa => true
  | Ns | Cname | Soa | Ptr | Mx | Txt | Srv => false
  }

/// Whether this is an infrastructure record (NS, SOA).
let recordTypeIsInfrastructure = (rt: recordType): bool =>
  switch rt {
  | Ns | Soa => true
  | A | Cname | Ptr | Mx | Txt | Aaaa | Srv => false
  }

// ===========================================================================
// DNS Response Code
// ===========================================================================

/// DNS response codes (RCODE, RFC 1035 Section 4.1.1).
type responseCode =
  | @as(0) NoError
  | @as(1) FormatError
  | @as(2) ServerFailure
  | @as(3) NameError
  | @as(4) DnsNotImplemented
  | @as(5) Refused

/// Decode from a 4-bit RCODE value.
let responseCodeFromRcode = (code: int): option<responseCode> =>
  switch code {
  | 0 => Some(NoError)
  | 1 => Some(FormatError)
  | 2 => Some(ServerFailure)
  | 3 => Some(NameError)
  | 4 => Some(DnsNotImplemented)
  | 5 => Some(Refused)
  | _ => None
  }

/// Convert to the RCODE value.
let responseCodeToRcode = (rc: responseCode): int =>
  switch rc {
  | NoError => 0
  | FormatError => 1
  | ServerFailure => 2
  | NameError => 3
  | DnsNotImplemented => 4
  | Refused => 5
  }

/// Whether this response indicates success.
let responseCodeIsSuccess = (rc: responseCode): bool =>
  switch rc {
  | NoError => true
  | FormatError | ServerFailure | NameError | DnsNotImplemented | Refused => false
  }

/// Whether this response indicates the domain does not exist.
let responseCodeIsNxdomain = (rc: responseCode): bool =>
  switch rc {
  | NameError => true
  | NoError | FormatError | ServerFailure | DnsNotImplemented | Refused => false
  }

/// Display name for the response code.
let responseCodeAsStr = (rc: responseCode): string =>
  switch rc {
  | NoError => "NOERROR"
  | FormatError => "FORMERR"
  | ServerFailure => "SERVFAIL"
  | NameError => "NXDOMAIN"
  | DnsNotImplemented => "NOTIMP"
  | Refused => "REFUSED"
  }

// ===========================================================================
// Domain Name Validation
// ===========================================================================

/// Errors that can occur during domain name validation.
type nameError =
  | LabelTooLong({label: string, length: int})
  | NameTooLong({name: string, length: int})
  | EmptyName
  | EmptyLabel

// validateDomainName removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @module FFI wiring not yet present for this
// protocol. Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md
