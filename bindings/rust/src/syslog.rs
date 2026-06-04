// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! Syslog protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `SyslogABI.Types` and its type definitions:
//! - `Severity`   — syslog severity levels (8 constructors, tags 0-7)
//! - `Facility`   — syslog facility codes (24 constructors, tags 0-23)
//! - `Transport`  — syslog transport mechanisms (3 constructors, tags 0-2)
//!
//! Severity and facility values match RFC 5424 numeric codes.
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Syslog Constants
// ===========================================================================

/// Standard syslog UDP port (RFC 5426).
pub const SYSLOG_UDP_PORT: u16 = 514;

/// Standard syslog TCP port (RFC 6587).
pub const SYSLOG_TCP_PORT: u16 = 514;

/// Syslog over TLS port (RFC 5425).
pub const SYSLOG_TLS_PORT: u16 = 6514;

// ===========================================================================
// Severity (tags 0-7, matching RFC 5424)
// ===========================================================================

/// Syslog severity levels (RFC 5424 Section 6.2.1).
///
/// Matches `Severity` in `SyslogABI.Types`.
/// Tag values match the standard syslog severity codes (0-7).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(u8)]
pub enum Severity {
    /// System is unusable (tag 0).
    Emergency = 0,
    /// Action must be taken immediately (tag 1).
    Alert = 1,
    /// Critical conditions (tag 2).
    Critical = 2,
    /// Error conditions (tag 3).
    Error = 3,
    /// Warning conditions (tag 4).
    Warning = 4,
    /// Normal but significant condition (tag 5).
    Notice = 5,
    /// Informational messages (tag 6).
    Informational = 6,
    /// Debug-level messages (tag 7).
    Debug = 7,
}

impl Severity {
    /// Decode from an ABI tag value (RFC 5424 severity code).
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Emergency),
            1 => Some(Self::Alert),
            2 => Some(Self::Critical),
            3 => Some(Self::Error),
            4 => Some(Self::Warning),
            5 => Some(Self::Notice),
            6 => Some(Self::Informational),
            7 => Some(Self::Debug),
            _ => None,
        }
    }

    /// Encode to the ABI tag value (RFC 5424 severity code).
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The short keyword name (e.g. "emerg", "alert", "crit").
    pub fn keyword(self) -> &'static str {
        match self {
            Self::Emergency => "emerg",
            Self::Alert => "alert",
            Self::Critical => "crit",
            Self::Error => "err",
            Self::Warning => "warning",
            Self::Notice => "notice",
            Self::Informational => "info",
            Self::Debug => "debug",
        }
    }

    /// Whether this severity level indicates an error or worse.
    ///
    /// Emergency, Alert, Critical, and Error are all error-level.
    /// Note: lower numeric value = higher severity.
    pub fn is_error_or_worse(self) -> bool {
        (self as u8) <= 3
    }

    /// All severity levels, ordered from most to least severe.
    pub const ALL: [Severity; 8] = [
        Self::Emergency, Self::Alert, Self::Critical, Self::Error,
        Self::Warning, Self::Notice, Self::Informational, Self::Debug,
    ];
}

impl fmt::Display for Severity {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.keyword())
    }
}

// ===========================================================================
// Facility (tags 0-23, matching RFC 5424)
// ===========================================================================

/// Syslog facility codes (RFC 5424 Section 6.2.1).
///
/// Matches `Facility` in `SyslogABI.Types`.
/// Tag values match the standard syslog facility codes (0-23).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Facility {
    /// Kernel messages (tag 0).
    Kern = 0,
    /// User-level messages (tag 1).
    User = 1,
    /// Mail system (tag 2).
    Mail = 2,
    /// System daemons (tag 3).
    Daemon = 3,
    /// Security/authorization (tag 4).
    Auth = 4,
    /// Syslog internal (tag 5).
    Syslog = 5,
    /// Line printer subsystem (tag 6).
    Lpr = 6,
    /// Network news subsystem (tag 7).
    News = 7,
    /// UUCP subsystem (tag 8).
    Uucp = 8,
    /// Clock daemon (tag 9).
    Cron = 9,
    /// Security/authorization (private) (tag 10).
    AuthPriv = 10,
    /// FTP daemon (tag 11).
    Ftp = 11,
    /// NTP subsystem (tag 12).
    Ntp = 12,
    /// Log audit (tag 13).
    Audit = 13,
    /// Log alert (tag 14).
    Alert = 14,
    /// Clock daemon (note 2) (tag 15).
    Clock = 15,
    /// Local use 0 (tag 16).
    Local0 = 16,
    /// Local use 1 (tag 17).
    Local1 = 17,
    /// Local use 2 (tag 18).
    Local2 = 18,
    /// Local use 3 (tag 19).
    Local3 = 19,
    /// Local use 4 (tag 20).
    Local4 = 20,
    /// Local use 5 (tag 21).
    Local5 = 21,
    /// Local use 6 (tag 22).
    Local6 = 22,
    /// Local use 7 (tag 23).
    Local7 = 23,
}

impl Facility {
    /// Decode from an ABI tag value (RFC 5424 facility code).
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Kern),
            1 => Some(Self::User),
            2 => Some(Self::Mail),
            3 => Some(Self::Daemon),
            4 => Some(Self::Auth),
            5 => Some(Self::Syslog),
            6 => Some(Self::Lpr),
            7 => Some(Self::News),
            8 => Some(Self::Uucp),
            9 => Some(Self::Cron),
            10 => Some(Self::AuthPriv),
            11 => Some(Self::Ftp),
            12 => Some(Self::Ntp),
            13 => Some(Self::Audit),
            14 => Some(Self::Alert),
            15 => Some(Self::Clock),
            16 => Some(Self::Local0),
            17 => Some(Self::Local1),
            18 => Some(Self::Local2),
            19 => Some(Self::Local3),
            20 => Some(Self::Local4),
            21 => Some(Self::Local5),
            22 => Some(Self::Local6),
            23 => Some(Self::Local7),
            _ => None,
        }
    }

    /// Encode to the ABI tag value (RFC 5424 facility code).
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a local-use facility (Local0-Local7).
    pub fn is_local(self) -> bool {
        (self as u8) >= 16
    }

    /// Whether this is a security-related facility.
    pub fn is_security(self) -> bool {
        matches!(self, Self::Auth | Self::AuthPriv | Self::Audit)
    }

    /// Compute the syslog priority value from facility and severity.
    ///
    /// PRI = facility * 8 + severity (RFC 5424 Section 6.2.1).
    pub fn priority(self, severity: Severity) -> u16 {
        (self as u16) * 8 + (severity as u16)
    }
}

impl fmt::Display for Facility {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Transport (tags 0-2)
// ===========================================================================

/// Syslog transport mechanisms.
///
/// Matches `Transport` in `SyslogABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Transport {
    /// UDP on port 514 (RFC 5426) (tag 0).
    Udp514 = 0,
    /// TCP on port 514 (RFC 6587) (tag 1).
    Tcp514 = 1,
    /// TLS on port 6514 (RFC 5425) (tag 2).
    Tls6514 = 2,
}

impl Transport {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Udp514),
            1 => Some(Self::Tcp514),
            2 => Some(Self::Tls6514),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The port number used by this transport.
    pub fn port(self) -> u16 {
        match self {
            Self::Udp514 | Self::Tcp514 => 514,
            Self::Tls6514 => 6514,
        }
    }

    /// Whether this transport provides encryption.
    pub fn is_encrypted(self) -> bool {
        matches!(self, Self::Tls6514)
    }

    /// Whether this transport provides reliable delivery.
    pub fn is_reliable(self) -> bool {
        matches!(self, Self::Tcp514 | Self::Tls6514)
    }
}

impl fmt::Display for Transport {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Udp514 => "UDP/514",
            Self::Tcp514 => "TCP/514",
            Self::Tls6514 => "TLS/6514",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn severity_roundtrip() {
        for sev in Severity::ALL {
            let tag = sev.to_tag();
            let decoded = Severity::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, sev);
        }
        assert!(Severity::from_tag(8).is_none());
    }

    #[test]
    fn severity_ordering() {
        // Lower numeric = higher severity.
        assert!(Severity::Emergency < Severity::Alert);
        assert!(Severity::Alert < Severity::Critical);
        assert!(Severity::Critical < Severity::Error);
        assert!(Severity::Error < Severity::Warning);
        assert!(Severity::Warning < Severity::Notice);
        assert!(Severity::Informational < Severity::Debug);
    }

    #[test]
    fn severity_error_classification() {
        assert!(Severity::Emergency.is_error_or_worse());
        assert!(Severity::Alert.is_error_or_worse());
        assert!(Severity::Critical.is_error_or_worse());
        assert!(Severity::Error.is_error_or_worse());
        assert!(!Severity::Warning.is_error_or_worse());
        assert!(!Severity::Notice.is_error_or_worse());
        assert!(!Severity::Debug.is_error_or_worse());
    }

    #[test]
    fn facility_roundtrip() {
        for tag in 0u8..=23 {
            let fac = Facility::from_tag(tag).expect("valid tag");
            assert_eq!(fac.to_tag(), tag);
        }
        assert!(Facility::from_tag(24).is_none());
    }

    #[test]
    fn facility_local() {
        assert!(!Facility::Kern.is_local());
        assert!(!Facility::Auth.is_local());
        assert!(Facility::Local0.is_local());
        assert!(Facility::Local7.is_local());
    }

    #[test]
    fn facility_security() {
        assert!(Facility::Auth.is_security());
        assert!(Facility::AuthPriv.is_security());
        assert!(Facility::Audit.is_security());
        assert!(!Facility::Kern.is_security());
        assert!(!Facility::User.is_security());
    }

    #[test]
    fn facility_priority_calculation() {
        // PRI = facility * 8 + severity.
        assert_eq!(Facility::Kern.priority(Severity::Emergency), 0);
        assert_eq!(Facility::User.priority(Severity::Notice), 13);
        assert_eq!(Facility::Local7.priority(Severity::Debug), 191);
        assert_eq!(Facility::Auth.priority(Severity::Warning), 36);
    }

    #[test]
    fn transport_roundtrip() {
        for tag in 0u8..=2 {
            let tr = Transport::from_tag(tag).expect("valid tag");
            assert_eq!(tr.to_tag(), tag);
        }
        assert!(Transport::from_tag(3).is_none());
    }

    #[test]
    fn transport_properties() {
        assert!(!Transport::Udp514.is_encrypted());
        assert!(!Transport::Tcp514.is_encrypted());
        assert!(Transport::Tls6514.is_encrypted());

        assert!(!Transport::Udp514.is_reliable());
        assert!(Transport::Tcp514.is_reliable());
        assert!(Transport::Tls6514.is_reliable());

        assert_eq!(Transport::Udp514.port(), 514);
        assert_eq!(Transport::Tcp514.port(), 514);
        assert_eq!(Transport::Tls6514.port(), 6514);
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(SYSLOG_UDP_PORT, 514);
        assert_eq!(SYSLOG_TCP_PORT, 514);
        assert_eq!(SYSLOG_TLS_PORT, 6514);
    }
}
