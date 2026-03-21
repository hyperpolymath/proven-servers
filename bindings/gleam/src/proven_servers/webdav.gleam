//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// WebDAV protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `WebdavABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// WebDAV Constants
// ===========================================================================

/// Webdav Default Port constant.
pub const webdav_default_port = 80

/// Webdav Tls Port constant.
pub const webdav_tls_port = 443

// ===========================================================================
// Method
// ===========================================================================

/// WebDAV HTTP extension methods (RFC 4918).
/// 
/// Matches `Method` in `WebDAVABI.Types`.
/// Note: standard HTTP methods (GET, PUT, DELETE, etc.) are handled by the
/// HTTP module; these are the WebDAV-specific extensions only.
pub type Method {
  /// Retrieve properties of a resource (tag 0).
  Propfind
  /// Set or remove properties on a resource (tag 1).
  Proppatch
  /// Create a new collection (directory) (tag 2).
  Mkcol
  /// Copy a resource (tag 3).
  Copy
  /// Move a resource (tag 4).
  Move
  /// Lock a resource (tag 5).
  Lock
  /// Unlock a resource (tag 6).
  Unlock
}

/// Convert a `Method` to its C-ABI tag value.
pub fn method_to_int(value: Method) -> Int {
  case value {
    Propfind -> 0
    Proppatch -> 1
    Mkcol -> 2
    Copy -> 3
    Move -> 4
    Lock -> 5
    Unlock -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn method_from_int(tag: Int) -> Result(Method, Nil) {
  case tag {
    0 -> Ok(Propfind)
    1 -> Ok(Proppatch)
    2 -> Ok(Mkcol)
    3 -> Ok(Copy)
    4 -> Ok(Move)
    5 -> Ok(Lock)
    6 -> Ok(Unlock)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// StatusCode
// ===========================================================================

/// WebDAV-specific HTTP status codes (RFC 4918).
/// 
/// Matches `StatusCode` in `WebDAVABI.Types`.
pub type StatusCode {
  /// 207 Multi-Status (tag 0).
  MultiStatus
  /// 422 Unprocessable Entity (tag 1).
  UnprocessableEntity
  /// 423 Locked (tag 2).
  Locked
  /// 424 Failed Dependency (tag 3).
  FailedDependency
  /// 507 Insufficient Storage (tag 4).
  InsufficientStorage
}

/// Convert a `StatusCode` to its C-ABI tag value.
pub fn status_code_to_int(value: StatusCode) -> Int {
  case value {
    MultiStatus -> 0
    UnprocessableEntity -> 1
    Locked -> 2
    FailedDependency -> 3
    InsufficientStorage -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn status_code_from_int(tag: Int) -> Result(StatusCode, Nil) {
  case tag {
    0 -> Ok(MultiStatus)
    1 -> Ok(UnprocessableEntity)
    2 -> Ok(Locked)
    3 -> Ok(FailedDependency)
    4 -> Ok(InsufficientStorage)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// LockScope
// ===========================================================================

/// WebDAV lock scope (RFC 4918 Section 14.13).
/// 
/// Matches `LockScope` in `WebDAVABI.Types`.
pub type LockScope {
  /// Exclusive lock — only the lock owner can modify (tag 0).
  Exclusive
  /// Shared lock — multiple users can hold the lock (tag 1).
  Shared
}

/// Convert a `LockScope` to its C-ABI tag value.
pub fn lock_scope_to_int(value: LockScope) -> Int {
  case value {
    Exclusive -> 0
    Shared -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn lock_scope_from_int(tag: Int) -> Result(LockScope, Nil) {
  case tag {
    0 -> Ok(Exclusive)
    1 -> Ok(Shared)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// LockType
// ===========================================================================

/// WebDAV lock type (RFC 4918 Section 14.15).
/// 
/// Matches `LockType` in `WebDAVABI.Types`.
/// Currently only write locks are defined in the RFC.
pub type LockType {
  /// Write lock — prevents modification by non-owners (tag 0).
  Write
}

/// Convert a `LockType` to its C-ABI tag value.
pub fn lock_type_to_int(value: LockType) -> Int {
  case value {
    Write -> 0
  }
}

/// Decode from a C-ABI tag value.
pub fn lock_type_from_int(tag: Int) -> Result(LockType, Nil) {
  case tag {
    0 -> Ok(Write)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Depth
// ===========================================================================

/// WebDAV Depth header values (RFC 4918 Section 10.2).
/// 
/// Matches `Depth` in `WebDAVABI.Types`.
pub type Depth {
  /// Depth 0 — resource only (tag 0).
  Zero
  /// Depth 1 — resource and immediate children (tag 1).
  One
  /// Depth infinity — resource and all descendants (tag 2).
  Infinity
}

/// Convert a `Depth` to its C-ABI tag value.
pub fn depth_to_int(value: Depth) -> Int {
  case value {
    Zero -> 0
    One -> 1
    Infinity -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn depth_from_int(tag: Int) -> Result(Depth, Nil) {
  case tag {
    0 -> Ok(Zero)
    1 -> Ok(One)
    2 -> Ok(Infinity)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PropertyOp
// ===========================================================================

/// WebDAV PROPPATCH operations (RFC 4918 Section 14.23/14.26).
/// 
/// Matches `PropertyOp` in `WebDAVABI.Types`.
pub type PropertyOp {
  /// Set (create or update) a property (tag 0).
  Set
  /// Remove a property (tag 1).
  Remove
}

/// Convert a `PropertyOp` to its C-ABI tag value.
pub fn property_op_to_int(value: PropertyOp) -> Int {
  case value {
    Set -> 0
    Remove -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn property_op_from_int(tag: Int) -> Result(PropertyOp, Nil) {
  case tag {
    0 -> Ok(Set)
    1 -> Ok(Remove)
    _ -> Error(Nil)
  }
}

