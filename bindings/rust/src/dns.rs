// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! DNS protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `DNS` and its submodules:
//! - `DNS`           — core constants (ports, size limits)
//! - `DNS.RecordType` — DNS record types
//!
//! All constants match the values in the Idris2 `DNS` module, which
//! are derived from RFC 1035, RFC 6891, and related RFCs.

use std::fmt;

// ===========================================================================
// DNS Constants (DNS module)
// ===========================================================================

/// Standard DNS port (RFC 1035).
///
/// Matches `dnsPort` in `DNS`.
pub const DNS_PORT: u16 = 53;

/// Maximum UDP message size without EDNS (RFC 1035 Section 4.2.1).
///
/// Matches `maxUdpSize` in `DNS`.
pub const MAX_UDP_SIZE: usize = 512;

/// Maximum TCP message size (RFC 1035 Section 4.2.2).
///
/// Matches `maxTcpSize` in `DNS`.
pub const MAX_TCP_SIZE: usize = 65535;

/// Maximum label length in bytes (RFC 1035 Section 2.3.4).
///
/// Matches `maxLabelLength` in `DNS`.
pub const MAX_LABEL_LENGTH: usize = 63;

/// Maximum total domain name length including dots (RFC 1035).
///
/// Matches `maxNameLength` in `DNS`.
pub const MAX_NAME_LENGTH: usize = 253;

/// EDNS(0) default UDP payload size (RFC 6891).
///
/// Matches `ednsUdpSize` in `DNS`.
pub const EDNS_UDP_SIZE: usize = 4096;

// ===========================================================================
// DNS Record Type
// ===========================================================================

/// DNS resource record types.
///
/// Covers the 9 record types defined in the proven-dns `RecordType` module.
/// Discriminant values match the standard DNS type codes from IANA.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u16)]
pub enum RecordType {
    /// A record: IPv4 address (RFC 1035).
    A = 1,
    /// AAAA record: IPv6 address (RFC 3596).
    Aaaa = 28,
    /// CNAME record: canonical name alias (RFC 1035).
    Cname = 5,
    /// MX record: mail exchange (RFC 1035).
    Mx = 15,
    /// NS record: authoritative name server (RFC 1035).
    Ns = 2,
    /// TXT record: text strings (RFC 1035).
    Txt = 16,
    /// SOA record: start of authority (RFC 1035).
    Soa = 6,
    /// SRV record: service locator (RFC 2782).
    Srv = 33,
    /// PTR record: pointer / reverse lookup (RFC 1035).
    Ptr = 12,
}

impl RecordType {
    /// Decode from a DNS type code (IANA registered value).
    pub fn from_type_code(code: u16) -> Option<Self> {
        match code {
            1 => Some(Self::A),
            2 => Some(Self::Ns),
            5 => Some(Self::Cname),
            6 => Some(Self::Soa),
            12 => Some(Self::Ptr),
            15 => Some(Self::Mx),
            16 => Some(Self::Txt),
            28 => Some(Self::Aaaa),
            33 => Some(Self::Srv),
            _ => None,
        }
    }

    /// Convert to the DNS type code (IANA registered value).
    pub fn to_type_code(self) -> u16 {
        self as u16
    }

    /// Mnemonic name (e.g. "A", "AAAA", "CNAME").
    pub fn mnemonic(self) -> &'static str {
        match self {
            Self::A => "A",
            Self::Aaaa => "AAAA",
            Self::Cname => "CNAME",
            Self::Mx => "MX",
            Self::Ns => "NS",
            Self::Txt => "TXT",
            Self::Soa => "SOA",
            Self::Srv => "SRV",
            Self::Ptr => "PTR",
        }
    }

    /// Whether this record type holds an address (A or AAAA).
    pub fn is_address(self) -> bool {
        matches!(self, Self::A | Self::Aaaa)
    }

    /// Whether this is an infrastructure record (NS, SOA).
    pub fn is_infrastructure(self) -> bool {
        matches!(self, Self::Ns | Self::Soa)
    }

    /// All supported record types.
    pub const ALL: [RecordType; 9] = [
        Self::A,
        Self::Ns,
        Self::Cname,
        Self::Soa,
        Self::Ptr,
        Self::Mx,
        Self::Txt,
        Self::Aaaa,
        Self::Srv,
    ];
}

impl fmt::Display for RecordType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.mnemonic())
    }
}

// ===========================================================================
// DNS Response Code
// ===========================================================================

/// DNS response codes (RCODE, RFC 1035 Section 4.1.1).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResponseCode {
    /// No error condition (0).
    NoError = 0,
    /// Format error: the server was unable to interpret the query (1).
    FormatError = 1,
    /// Server failure: internal problem (2).
    ServerFailure = 2,
    /// Name error: the domain name does not exist (NXDOMAIN) (3).
    NameError = 3,
    /// Not implemented: the server does not support the query type (4).
    NotImplemented = 4,
    /// Refused: the server refuses to perform the operation (5).
    Refused = 5,
}

impl ResponseCode {
    /// Decode from a 4-bit RCODE value.
    pub fn from_rcode(code: u8) -> Option<Self> {
        match code {
            0 => Some(Self::NoError),
            1 => Some(Self::FormatError),
            2 => Some(Self::ServerFailure),
            3 => Some(Self::NameError),
            4 => Some(Self::NotImplemented),
            5 => Some(Self::Refused),
            _ => None,
        }
    }

    /// Convert to the RCODE value.
    pub fn to_rcode(self) -> u8 {
        self as u8
    }

    /// Whether this response indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::NoError)
    }

    /// Whether this response indicates the domain does not exist.
    pub fn is_nxdomain(self) -> bool {
        matches!(self, Self::NameError)
    }
}

impl fmt::Display for ResponseCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::NoError => "NOERROR",
            Self::FormatError => "FORMERR",
            Self::ServerFailure => "SERVFAIL",
            Self::NameError => "NXDOMAIN",
            Self::NotImplemented => "NOTIMP",
            Self::Refused => "REFUSED",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// Domain Name Validation
// ===========================================================================

/// Errors that can occur during domain name validation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum NameError {
    /// A label exceeds the 63-byte limit.
    LabelTooLong { label: String, length: usize },
    /// The total name exceeds the 253-byte limit.
    NameTooLong { name: String, length: usize },
    /// The name is empty.
    EmptyName,
    /// A label is empty (e.g. from consecutive dots).
    EmptyLabel,
}

impl fmt::Display for NameError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::LabelTooLong { label, length } => {
                write!(
                    f,
                    "Label '{}' too long: {} bytes (max {})",
                    label, length, MAX_LABEL_LENGTH
                )
            }
            Self::NameTooLong { name, length } => {
                write!(
                    f,
                    "Name '{}' too long: {} bytes (max {})",
                    name, length, MAX_NAME_LENGTH
                )
            }
            Self::EmptyName => write!(f, "Domain name is empty"),
            Self::EmptyLabel => write!(f, "Domain name contains empty label"),
        }
    }
}

impl std::error::Error for NameError {}

/// Validate a domain name against RFC 1035 length constraints.
///
/// Checks that no label exceeds [`MAX_LABEL_LENGTH`] bytes and that
/// the total name does not exceed [`MAX_NAME_LENGTH`] bytes.
/// Mirrors the validation logic in the Idris2 `DNS.Name` module.
pub fn validate_domain_name(name: &str) -> Result<(), NameError> {
    if name.is_empty() {
        return Err(NameError::EmptyName);
    }
    if name.len() > MAX_NAME_LENGTH {
        return Err(NameError::NameTooLong {
            name: name.to_string(),
            length: name.len(),
        });
    }
    for label in name.split('.') {
        if label.is_empty() {
            return Err(NameError::EmptyLabel);
        }
        if label.len() > MAX_LABEL_LENGTH {
            return Err(NameError::LabelTooLong {
                label: label.to_string(),
                length: label.len(),
            });
        }
    }
    Ok(())
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn record_type_roundtrip() {
        for rt in RecordType::ALL {
            let code = rt.to_type_code();
            let decoded = RecordType::from_type_code(code).expect("valid code");
            assert_eq!(decoded, rt);
        }
    }

    #[test]
    fn record_type_unknown_rejected() {
        assert!(RecordType::from_type_code(0).is_none());
        assert!(RecordType::from_type_code(255).is_none());
    }

    #[test]
    fn record_type_classification() {
        assert!(RecordType::A.is_address());
        assert!(RecordType::Aaaa.is_address());
        assert!(!RecordType::Cname.is_address());
        assert!(RecordType::Ns.is_infrastructure());
        assert!(RecordType::Soa.is_infrastructure());
        assert!(!RecordType::Mx.is_infrastructure());
    }

    #[test]
    fn response_code_roundtrip() {
        for code in 0u8..=5 {
            let rc = ResponseCode::from_rcode(code).expect("valid code");
            assert_eq!(rc.to_rcode(), code);
        }
        assert!(ResponseCode::from_rcode(6).is_none());
    }

    #[test]
    fn response_code_classification() {
        assert!(ResponseCode::NoError.is_success());
        assert!(!ResponseCode::NameError.is_success());
        assert!(ResponseCode::NameError.is_nxdomain());
        assert!(!ResponseCode::NoError.is_nxdomain());
    }

    #[test]
    fn domain_name_valid() {
        assert!(validate_domain_name("example.com").is_ok());
        assert!(validate_domain_name("sub.example.com").is_ok());
        assert!(validate_domain_name("a").is_ok());
    }

    #[test]
    fn domain_name_empty() {
        assert!(matches!(
            validate_domain_name(""),
            Err(NameError::EmptyName)
        ));
    }

    #[test]
    fn domain_name_label_too_long() {
        let long_label = "a".repeat(64);
        let name = format!("{}.com", long_label);
        assert!(matches!(
            validate_domain_name(&name),
            Err(NameError::LabelTooLong { .. })
        ));
    }

    #[test]
    fn domain_name_too_long() {
        // Build a name just over 253 characters using valid labels.
        let label = "a".repeat(63);
        let name = format!("{}.{}.{}.{}.x", label, label, label, label);
        assert!(name.len() > MAX_NAME_LENGTH);
        assert!(matches!(
            validate_domain_name(&name),
            Err(NameError::NameTooLong { .. })
        ));
    }

    #[test]
    fn domain_name_empty_label() {
        assert!(matches!(
            validate_domain_name("example..com"),
            Err(NameError::EmptyLabel)
        ));
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(DNS_PORT, 53);
        assert_eq!(MAX_UDP_SIZE, 512);
        assert_eq!(MAX_TCP_SIZE, 65535);
        assert_eq!(MAX_LABEL_LENGTH, 63);
        assert_eq!(MAX_NAME_LENGTH, 253);
        assert_eq!(EDNS_UDP_SIZE, 4096);
    }
}
