// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! WebDAV protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `WebDAVABI.Types` and its type definitions:
//! - `Method`     — WebDAV HTTP extension methods (7 constructors, tags 0-6)
//! - `StatusCode` — WebDAV-specific HTTP status codes (5 constructors, tags 0-4)
//! - `LockScope`  — Lock scope types (2 constructors, tags 0-1)
//! - `LockType`   — Lock types (1 constructor, tag 0)
//! - `Depth`      — Request depth header values (3 constructors, tags 0-2)
//! - `PropertyOp` — PROPPATCH operations (2 constructors, tags 0-1)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// WebDAV Constants
// ===========================================================================

/// WebDAV uses standard HTTP/HTTPS ports.
pub const WEBDAV_DEFAULT_PORT: u16 = 80;

/// WebDAV over TLS uses standard HTTPS port.
pub const WEBDAV_TLS_PORT: u16 = 443;

// ===========================================================================
// Method (tags 0-6)
// ===========================================================================

/// WebDAV HTTP extension methods (RFC 4918).
///
/// Matches `Method` in `WebDAVABI.Types`.
/// Note: standard HTTP methods (GET, PUT, DELETE, etc.) are handled by the
/// HTTP module; these are the WebDAV-specific extensions only.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Method {
    /// Retrieve properties of a resource (tag 0).
    Propfind = 0,
    /// Set or remove properties on a resource (tag 1).
    Proppatch = 1,
    /// Create a new collection (directory) (tag 2).
    Mkcol = 2,
    /// Copy a resource (tag 3).
    Copy = 3,
    /// Move a resource (tag 4).
    Move = 4,
    /// Lock a resource (tag 5).
    Lock = 5,
    /// Unlock a resource (tag 6).
    Unlock = 6,
}

impl Method {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Propfind),
            1 => Some(Self::Proppatch),
            2 => Some(Self::Mkcol),
            3 => Some(Self::Copy),
            4 => Some(Self::Move),
            5 => Some(Self::Lock),
            6 => Some(Self::Unlock),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The HTTP method name string.
    pub fn name(self) -> &'static str {
        match self {
            Self::Propfind => "PROPFIND",
            Self::Proppatch => "PROPPATCH",
            Self::Mkcol => "MKCOL",
            Self::Copy => "COPY",
            Self::Move => "MOVE",
            Self::Lock => "LOCK",
            Self::Unlock => "UNLOCK",
        }
    }

    /// Whether this method modifies server state.
    pub fn is_write(self) -> bool {
        matches!(self, Self::Proppatch | Self::Mkcol | Self::Copy | Self::Move)
    }

    /// Whether this method relates to locking.
    pub fn is_lock_related(self) -> bool {
        matches!(self, Self::Lock | Self::Unlock)
    }

    /// All supported methods.
    pub const ALL: [Method; 7] = [
        Self::Propfind, Self::Proppatch, Self::Mkcol, Self::Copy,
        Self::Move, Self::Lock, Self::Unlock,
    ];
}

impl fmt::Display for Method {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.name())
    }
}

// ===========================================================================
// StatusCode (tags 0-4)
// ===========================================================================

/// WebDAV-specific HTTP status codes (RFC 4918).
///
/// Matches `StatusCode` in `WebDAVABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StatusCode {
    /// 207 Multi-Status (tag 0).
    MultiStatus = 0,
    /// 422 Unprocessable Entity (tag 1).
    UnprocessableEntity = 1,
    /// 423 Locked (tag 2).
    Locked = 2,
    /// 424 Failed Dependency (tag 3).
    FailedDependency = 3,
    /// 507 Insufficient Storage (tag 4).
    InsufficientStorage = 4,
}

impl StatusCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::MultiStatus),
            1 => Some(Self::UnprocessableEntity),
            2 => Some(Self::Locked),
            3 => Some(Self::FailedDependency),
            4 => Some(Self::InsufficientStorage),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this status is an error (4xx or 5xx).
    pub fn is_error(self) -> bool {
        !matches!(self, Self::MultiStatus)
    }

    /// The numeric HTTP status code.
    pub fn http_code(self) -> u16 {
        match self {
            Self::MultiStatus => 207,
            Self::UnprocessableEntity => 422,
            Self::Locked => 423,
            Self::FailedDependency => 424,
            Self::InsufficientStorage => 507,
        }
    }

    /// All supported status codes.
    pub const ALL: [StatusCode; 5] = [
        Self::MultiStatus, Self::UnprocessableEntity, Self::Locked,
        Self::FailedDependency, Self::InsufficientStorage,
    ];
}

impl fmt::Display for StatusCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} {:?}", self.http_code(), self)
    }
}

// ===========================================================================
// LockScope (tags 0-1)
// ===========================================================================

/// WebDAV lock scope (RFC 4918 Section 14.13).
///
/// Matches `LockScope` in `WebDAVABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LockScope {
    /// Exclusive lock — only the lock owner can modify (tag 0).
    Exclusive = 0,
    /// Shared lock — multiple users can hold the lock (tag 1).
    Shared = 1,
}

impl LockScope {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Exclusive),
            1 => Some(Self::Shared),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for LockScope {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// LockType (tag 0)
// ===========================================================================

/// WebDAV lock type (RFC 4918 Section 14.15).
///
/// Matches `LockType` in `WebDAVABI.Types`.
/// Currently only write locks are defined in the RFC.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LockType {
    /// Write lock — prevents modification by non-owners (tag 0).
    Write = 0,
}

impl LockType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Write),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for LockType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Depth (tags 0-2)
// ===========================================================================

/// WebDAV Depth header values (RFC 4918 Section 10.2).
///
/// Matches `Depth` in `WebDAVABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Depth {
    /// Depth 0 — resource only (tag 0).
    Zero = 0,
    /// Depth 1 — resource and immediate children (tag 1).
    One = 1,
    /// Depth infinity — resource and all descendants (tag 2).
    Infinity = 2,
}

impl Depth {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Zero),
            1 => Some(Self::One),
            2 => Some(Self::Infinity),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The HTTP header string for this depth value.
    pub fn header_value(self) -> &'static str {
        match self {
            Self::Zero => "0",
            Self::One => "1",
            Self::Infinity => "infinity",
        }
    }
}

impl fmt::Display for Depth {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.header_value())
    }
}

// ===========================================================================
// PropertyOp (tags 0-1)
// ===========================================================================

/// WebDAV PROPPATCH operations (RFC 4918 Section 14.23/14.26).
///
/// Matches `PropertyOp` in `WebDAVABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PropertyOp {
    /// Set (create or update) a property (tag 0).
    Set = 0,
    /// Remove a property (tag 1).
    Remove = 1,
}

impl PropertyOp {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Set),
            1 => Some(Self::Remove),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

impl fmt::Display for PropertyOp {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn method_roundtrip() {
        for m in Method::ALL {
            let tag = m.to_tag();
            let decoded = Method::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, m);
        }
        assert!(Method::from_tag(7).is_none());
    }

    #[test]
    fn method_classification() {
        assert!(!Method::Propfind.is_write());
        assert!(Method::Proppatch.is_write());
        assert!(Method::Mkcol.is_write());
        assert!(Method::Lock.is_lock_related());
        assert!(Method::Unlock.is_lock_related());
        assert!(!Method::Propfind.is_lock_related());
    }

    #[test]
    fn status_code_roundtrip() {
        for sc in StatusCode::ALL {
            let tag = sc.to_tag();
            let decoded = StatusCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, sc);
        }
        assert!(StatusCode::from_tag(5).is_none());
    }

    #[test]
    fn status_code_http_codes() {
        assert_eq!(StatusCode::MultiStatus.http_code(), 207);
        assert_eq!(StatusCode::Locked.http_code(), 423);
        assert_eq!(StatusCode::InsufficientStorage.http_code(), 507);
    }

    #[test]
    fn lock_scope_roundtrip() {
        for tag in 0u8..=1 {
            let ls = LockScope::from_tag(tag).expect("valid tag");
            assert_eq!(ls.to_tag(), tag);
        }
        assert!(LockScope::from_tag(2).is_none());
    }

    #[test]
    fn lock_type_roundtrip() {
        let lt = LockType::from_tag(0).expect("valid tag");
        assert_eq!(lt.to_tag(), 0);
        assert!(LockType::from_tag(1).is_none());
    }

    #[test]
    fn depth_roundtrip() {
        for tag in 0u8..=2 {
            let d = Depth::from_tag(tag).expect("valid tag");
            assert_eq!(d.to_tag(), tag);
        }
        assert!(Depth::from_tag(3).is_none());
    }

    #[test]
    fn depth_header_values() {
        assert_eq!(Depth::Zero.header_value(), "0");
        assert_eq!(Depth::One.header_value(), "1");
        assert_eq!(Depth::Infinity.header_value(), "infinity");
    }

    #[test]
    fn property_op_roundtrip() {
        for tag in 0u8..=1 {
            let po = PropertyOp::from_tag(tag).expect("valid tag");
            assert_eq!(po.to_tag(), tag);
        }
        assert!(PropertyOp::from_tag(2).is_none());
    }
}
