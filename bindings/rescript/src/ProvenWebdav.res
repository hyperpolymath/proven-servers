// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebDAV protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module WebDAVABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// WebDAV uses standard HTTP/HTTPS ports.
let webdavDefaultPort = 80

/// WebDAV over TLS uses standard HTTPS port.
let webdavTlsPort = 443

// ===========================================================================
// Method (tags 0-6)
// ===========================================================================

/// WebDAV uses standard HTTP/HTTPS ports.
type method =
  | @as(0) Propfind
  | @as(1) Proppatch
  | @as(2) Mkcol
  | @as(3) Copy
  | @as(4) Move
  | @as(5) Lock
  | @as(6) Unlock

/// Decode from the C-ABI tag value.
let methodFromTag = (tag: int): option<method> =>
  switch tag {
  | 0 => Some(Propfind)
  | 1 => Some(Proppatch)
  | 2 => Some(Mkcol)
  | 3 => Some(Copy)
  | 4 => Some(Move)
  | 5 => Some(Lock)
  | 6 => Some(Unlock)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let methodToTag = (v: method): int =>
  switch v {
  | Propfind => 0
  | Proppatch => 1
  | Mkcol => 2
  | Copy => 3
  | Move => 4
  | Lock => 5
  | Unlock => 6
  }

/// Whether this method modifies server state.
let methodIsWrite = (v: method): bool =>
  switch v {
  | Proppatch | Mkcol | Copy | Move => true
  | _ => false
  }

/// Whether this method relates to locking.
let methodIsLockRelated = (v: method): bool =>
  switch v {
  | Lock | Unlock => true
  | _ => false
  }

// ===========================================================================
// StatusCode (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type statusCode =
  | @as(0) MultiStatus
  | @as(1) UnprocessableEntity
  | @as(2) Locked
  | @as(3) FailedDependency
  | @as(4) InsufficientStorage

/// Decode from the C-ABI tag value.
let statusCodeFromTag = (tag: int): option<statusCode> =>
  switch tag {
  | 0 => Some(MultiStatus)
  | 1 => Some(UnprocessableEntity)
  | 2 => Some(Locked)
  | 3 => Some(FailedDependency)
  | 4 => Some(InsufficientStorage)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let statusCodeToTag = (v: statusCode): int =>
  switch v {
  | MultiStatus => 0
  | UnprocessableEntity => 1
  | Locked => 2
  | FailedDependency => 3
  | InsufficientStorage => 4
  }

/// Whether this status is an error (4xx or 5xx).
let statusCodeIsError = (v: statusCode): bool =>
  switch v {
  | MultiStatus => false
  | _ => true
  }

// ===========================================================================
// LockScope (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type lockScope =
  | @as(0) Exclusive
  | @as(1) Shared

/// Decode from the C-ABI tag value.
let lockScopeFromTag = (tag: int): option<lockScope> =>
  switch tag {
  | 0 => Some(Exclusive)
  | 1 => Some(Shared)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let lockScopeToTag = (v: lockScope): int =>
  switch v {
  | Exclusive => 0
  | Shared => 1
  }

// ===========================================================================
// LockType (tags 0-0)
// ===========================================================================

/// Decode from an ABI tag value.
type lockType =
  | @as(0) Write

/// Decode from the C-ABI tag value.
let lockTypeFromTag = (tag: int): option<lockType> =>
  switch tag {
  | 0 => Some(Write)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let lockTypeToTag = (v: lockType): int =>
  switch v {
  | Write => 0
  }

// ===========================================================================
// Depth (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type depth =
  | @as(0) Zero
  | @as(1) One
  | @as(2) Infinity

/// Decode from the C-ABI tag value.
let depthFromTag = (tag: int): option<depth> =>
  switch tag {
  | 0 => Some(Zero)
  | 1 => Some(One)
  | 2 => Some(Infinity)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let depthToTag = (v: depth): int =>
  switch v {
  | Zero => 0
  | One => 1
  | Infinity => 2
  }

// ===========================================================================
// PropertyOp (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type propertyOp =
  | @as(0) Set
  | @as(1) Remove

/// Decode from the C-ABI tag value.
let propertyOpFromTag = (tag: int): option<propertyOp> =>
  switch tag {
  | 0 => Some(Set)
  | 1 => Some(Remove)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let propertyOpToTag = (v: propertyOp): int =>
  switch v {
  | Set => 0
  | Remove => 1
  }

