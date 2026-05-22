//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Syslog protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SyslogABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Syslog Constants
// ===========================================================================

/// Syslog Udp Port constant.
pub const syslog_udp_port = 514

/// Syslog Tcp Port constant.
pub const syslog_tcp_port = 514

/// Syslog Tls Port constant.
pub const syslog_tls_port = 6514

// ===========================================================================
// Severity
// ===========================================================================

/// Syslog severity levels (RFC 5424 Section 6.2.1).
/// 
/// Matches `Severity` in `SyslogABI.Types`.
/// Tag values match the standard syslog severity codes (0-7).
pub type Severity {
  /// System is unusable (tag 0).
  Emergency
  /// Action must be taken immediately (tag 1).
  SeverityAlert
  /// Critical conditions (tag 2).
  Critical
  /// Error conditions (tag 3).
  SeverityError
  /// Warning conditions (tag 4).
  Warning
  /// Normal but significant condition (tag 5).
  Notice
  /// Informational messages (tag 6).
  Informational
  /// Debug-level messages (tag 7).
  Debug
}

/// Convert a `Severity` to its C-ABI tag value.
pub fn severity_to_int(value: Severity) -> Int {
  case value {
    Emergency -> 0
    SeverityAlert -> 1
    Critical -> 2
    SeverityError -> 3
    Warning -> 4
    Notice -> 5
    Informational -> 6
    Debug -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn severity_from_int(tag: Int) -> Result(Severity, Nil) {
  case tag {
    0 -> Ok(Emergency)
    1 -> Ok(SeverityAlert)
    2 -> Ok(Critical)
    3 -> Ok(SeverityError)
    4 -> Ok(Warning)
    5 -> Ok(Notice)
    6 -> Ok(Informational)
    7 -> Ok(Debug)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Facility
// ===========================================================================

/// Syslog facility codes (RFC 5424 Section 6.2.1).
/// 
/// Matches `Facility` in `SyslogABI.Types`.
/// Tag values match the standard syslog facility codes (0-23).
pub type Facility {
  /// Kernel messages (tag 0).
  Kern
  /// User-level messages (tag 1).
  User
  /// Mail system (tag 2).
  Mail
  /// System daemons (tag 3).
  Daemon
  /// Security/authorization (tag 4).
  Auth
  /// Syslog internal (tag 5).
  Syslog
  /// Line printer subsystem (tag 6).
  Lpr
  /// Network news subsystem (tag 7).
  News
  /// UUCP subsystem (tag 8).
  Uucp
  /// Clock daemon (tag 9).
  Cron
  /// Security/authorization (private) (tag 10).
  AuthPriv
  /// FTP daemon (tag 11).
  Ftp
  /// NTP subsystem (tag 12).
  Ntp
  /// Log audit (tag 13).
  Audit
  /// Log alert (tag 14).
  FacilityAlert
  /// Clock daemon (note 2) (tag 15).
  Clock
  /// Local use 0 (tag 16).
  Local0
  /// Local use 1 (tag 17).
  Local1
  /// Local use 2 (tag 18).
  Local2
  /// Local use 3 (tag 19).
  Local3
  /// Local use 4 (tag 20).
  Local4
  /// Local use 5 (tag 21).
  Local5
  /// Local use 6 (tag 22).
  Local6
  /// Local use 7 (tag 23).
  Local7
}

/// Convert a `Facility` to its C-ABI tag value.
pub fn facility_to_int(value: Facility) -> Int {
  case value {
    Kern -> 0
    User -> 1
    Mail -> 2
    Daemon -> 3
    Auth -> 4
    Syslog -> 5
    Lpr -> 6
    News -> 7
    Uucp -> 8
    Cron -> 9
    AuthPriv -> 10
    Ftp -> 11
    Ntp -> 12
    Audit -> 13
    FacilityAlert -> 14
    Clock -> 15
    Local0 -> 16
    Local1 -> 17
    Local2 -> 18
    Local3 -> 19
    Local4 -> 20
    Local5 -> 21
    Local6 -> 22
    Local7 -> 23
  }
}

/// Decode from a C-ABI tag value.
pub fn facility_from_int(tag: Int) -> Result(Facility, Nil) {
  case tag {
    0 -> Ok(Kern)
    1 -> Ok(User)
    2 -> Ok(Mail)
    3 -> Ok(Daemon)
    4 -> Ok(Auth)
    5 -> Ok(Syslog)
    6 -> Ok(Lpr)
    7 -> Ok(News)
    8 -> Ok(Uucp)
    9 -> Ok(Cron)
    10 -> Ok(AuthPriv)
    11 -> Ok(Ftp)
    12 -> Ok(Ntp)
    13 -> Ok(Audit)
    14 -> Ok(FacilityAlert)
    15 -> Ok(Clock)
    16 -> Ok(Local0)
    17 -> Ok(Local1)
    18 -> Ok(Local2)
    19 -> Ok(Local3)
    20 -> Ok(Local4)
    21 -> Ok(Local5)
    22 -> Ok(Local6)
    23 -> Ok(Local7)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Transport
// ===========================================================================

/// Syslog transport mechanisms.
/// 
/// Matches `Transport` in `SyslogABI.Types`.
pub type Transport {
  /// UDP on port 514 (RFC 5426) (tag 0).
  Udp514
  /// TCP on port 514 (RFC 6587) (tag 1).
  Tcp514
  /// TLS on port 6514 (RFC 5425) (tag 2).
  Tls6514
}

/// Convert a `Transport` to its C-ABI tag value.
pub fn transport_to_int(value: Transport) -> Int {
  case value {
    Udp514 -> 0
    Tcp514 -> 1
    Tls6514 -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn transport_from_int(tag: Int) -> Result(Transport, Nil) {
  case tag {
    0 -> Ok(Udp514)
    1 -> Ok(Tcp514)
    2 -> Ok(Tls6514)
    _ -> Error(Nil)
  }
}

