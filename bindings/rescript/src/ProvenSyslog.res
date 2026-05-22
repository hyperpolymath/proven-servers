// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Syslog protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module SyslogABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard syslog UDP port (RFC 5426).
let syslogUdpPort = 514

/// Standard syslog TCP port (RFC 6587).
let syslogTcpPort = 514

/// Syslog over TLS port (RFC 5425).
let syslogTlsPort = 6514

// ===========================================================================
// Severity (tags 0-7)
// ===========================================================================

/// Standard syslog UDP port (RFC 5426).
type severity =
  | @as(0) Emergency
  | @as(1) Alert
  | @as(2) Critical
  | @as(3) Error
  | @as(4) Warning
  | @as(5) Notice
  | @as(6) Informational
  | @as(7) Debug

/// Decode from the C-ABI tag value.
let severityFromTag = (tag: int): option<severity> =>
  switch tag {
  | 0 => Some(Emergency)
  | 1 => Some(Alert)
  | 2 => Some(Critical)
  | 3 => Some(Error)
  | 4 => Some(Warning)
  | 5 => Some(Notice)
  | 6 => Some(Informational)
  | 7 => Some(Debug)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let severityToTag = (v: severity): int =>
  switch v {
  | Emergency => 0
  | Alert => 1
  | Critical => 2
  | Error => 3
  | Warning => 4
  | Notice => 5
  | Informational => 6
  | Debug => 7
  }

// ===========================================================================
// Facility (tags 0-23)
// ===========================================================================

/// Decode from an ABI tag value (RFC 5424 severity code).
type facility =
  | @as(0) Kern
  | @as(1) User
  | @as(2) Mail
  | @as(3) Daemon
  | @as(4) Auth
  | @as(5) Syslog
  | @as(6) Lpr
  | @as(7) News
  | @as(8) Uucp
  | @as(9) Cron
  | @as(10) AuthPriv
  | @as(11) Ftp
  | @as(12) Ntp
  | @as(13) Audit
  | @as(14) Alert
  | @as(15) Clock
  | @as(16) Local0
  | @as(17) Local1
  | @as(18) Local2
  | @as(19) Local3
  | @as(20) Local4
  | @as(21) Local5
  | @as(22) Local6
  | @as(23) Local7

/// Decode from the C-ABI tag value.
let facilityFromTag = (tag: int): option<facility> =>
  switch tag {
  | 0 => Some(Kern)
  | 1 => Some(User)
  | 2 => Some(Mail)
  | 3 => Some(Daemon)
  | 4 => Some(Auth)
  | 5 => Some(Syslog)
  | 6 => Some(Lpr)
  | 7 => Some(News)
  | 8 => Some(Uucp)
  | 9 => Some(Cron)
  | 10 => Some(AuthPriv)
  | 11 => Some(Ftp)
  | 12 => Some(Ntp)
  | 13 => Some(Audit)
  | 14 => Some(Alert)
  | 15 => Some(Clock)
  | 16 => Some(Local0)
  | 17 => Some(Local1)
  | 18 => Some(Local2)
  | 19 => Some(Local3)
  | 20 => Some(Local4)
  | 21 => Some(Local5)
  | 22 => Some(Local6)
  | 23 => Some(Local7)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let facilityToTag = (v: facility): int =>
  switch v {
  | Kern => 0
  | User => 1
  | Mail => 2
  | Daemon => 3
  | Auth => 4
  | Syslog => 5
  | Lpr => 6
  | News => 7
  | Uucp => 8
  | Cron => 9
  | AuthPriv => 10
  | Ftp => 11
  | Ntp => 12
  | Audit => 13
  | Alert => 14
  | Clock => 15
  | Local0 => 16
  | Local1 => 17
  | Local2 => 18
  | Local3 => 19
  | Local4 => 20
  | Local5 => 21
  | Local6 => 22
  | Local7 => 23
  }

/// Whether this is a security-related facility.
let facilityIsSecurity = (v: facility): bool =>
  switch v {
  | Auth | AuthPriv | Audit => true
  | _ => false
  }

// ===========================================================================
// Transport (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value (RFC 5424 facility code).
type transport =
  | @as(0) Udp514
  | @as(1) Tcp514
  | @as(2) Tls6514

/// Decode from the C-ABI tag value.
let transportFromTag = (tag: int): option<transport> =>
  switch tag {
  | 0 => Some(Udp514)
  | 1 => Some(Tcp514)
  | 2 => Some(Tls6514)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transportToTag = (v: transport): int =>
  switch v {
  | Udp514 => 0
  | Tcp514 => 1
  | Tls6514 => 2
  }

/// Whether this transport provides encryption.
let transportIsEncrypted = (v: transport): bool =>
  switch v {
  | Tls6514 => true
  | _ => false
  }

/// Whether this transport provides reliable delivery.
let transportIsReliable = (v: transport): bool =>
  switch v {
  | Tcp514 | Tls6514 => true
  | _ => false
  }

