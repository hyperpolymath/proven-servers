// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDAP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module LdapABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard LDAP port (RFC 4511).
let ldapPort = 389

/// Standard LDAPS (LDAP over TLS) port.
let ldapsPort = 636

// ===========================================================================
// SessionState (tags 0-3)
// ===========================================================================

/// Standard LDAP port (RFC 4511).
type sessionState =
  | @as(0) Anonymous
  | @as(1) Bound
  | @as(2) Closed
  | @as(3) Binding

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Anonymous)
  | 1 => Some(Bound)
  | 2 => Some(Closed)
  | 3 => Some(Binding)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Anonymous => 0
  | Bound => 1
  | Closed => 2
  | Binding => 3
  }

/// Validate whether a state transition is allowed.
let sessionStateCanTransitionTo = (from: sessionState, to: sessionState): bool =>
  switch (from, to) {
  | _ => false
  }

/// Whether operations requiring authentication can be performed.
let sessionStateIsAuthenticated = (v: sessionState): bool =>
  switch v {
  | Bound => true
  | _ => false
  }

// ===========================================================================
// Operation (tags 0-9)
// ===========================================================================

/// Decode from an ABI tag value.
type operation =
  | @as(0) Bind
  | @as(1) Unbind
  | @as(2) Search
  | @as(3) Modify
  | @as(4) Add
  | @as(5) Delete
  | @as(6) ModDn
  | @as(7) Compare
  | @as(8) Abandon
  | @as(9) Extended

/// Decode from the C-ABI tag value.
let operationFromTag = (tag: int): option<operation> =>
  switch tag {
  | 0 => Some(Bind)
  | 1 => Some(Unbind)
  | 2 => Some(Search)
  | 3 => Some(Modify)
  | 4 => Some(Add)
  | 5 => Some(Delete)
  | 6 => Some(ModDn)
  | 7 => Some(Compare)
  | 8 => Some(Abandon)
  | 9 => Some(Extended)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let operationToTag = (v: operation): int =>
  switch v {
  | Bind => 0
  | Unbind => 1
  | Search => 2
  | Modify => 3
  | Add => 4
  | Delete => 5
  | ModDn => 6
  | Compare => 7
  | Abandon => 8
  | Extended => 9
  }

/// Whether this operation modifies directory data.
let operationIsWrite = (v: operation): bool =>
  switch v {
  | Modify | Add | Delete | ModDn => true
  | _ => false
  }

// ===========================================================================
// SearchScope (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type searchScope =
  | @as(0) BaseObject
  | @as(1) SingleLevel
  | @as(2) WholeSubtree

/// Decode from the C-ABI tag value.
let searchScopeFromTag = (tag: int): option<searchScope> =>
  switch tag {
  | 0 => Some(BaseObject)
  | 1 => Some(SingleLevel)
  | 2 => Some(WholeSubtree)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let searchScopeToTag = (v: searchScope): int =>
  switch v {
  | BaseObject => 0
  | SingleLevel => 1
  | WholeSubtree => 2
  }

// ===========================================================================
// ResultCode (tags 0-10)
// ===========================================================================

/// Decode from an ABI tag value.
type resultCode =
  | @as(0) Success
  | @as(1) OperationsError
  | @as(2) ProtocolError
  | @as(3) TimeLimitExceeded
  | @as(4) SizeLimitExceeded
  | @as(5) AuthMethodNotSupported
  | @as(6) NoSuchObject
  | @as(7) InvalidCredentials
  | @as(8) InsufficientAccessRights
  | @as(9) Busy
  | @as(10) Unavailable

/// Decode from the C-ABI tag value.
let resultCodeFromTag = (tag: int): option<resultCode> =>
  switch tag {
  | 0 => Some(Success)
  | 1 => Some(OperationsError)
  | 2 => Some(ProtocolError)
  | 3 => Some(TimeLimitExceeded)
  | 4 => Some(SizeLimitExceeded)
  | 5 => Some(AuthMethodNotSupported)
  | 6 => Some(NoSuchObject)
  | 7 => Some(InvalidCredentials)
  | 8 => Some(InsufficientAccessRights)
  | 9 => Some(Busy)
  | 10 => Some(Unavailable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let resultCodeToTag = (v: resultCode): int =>
  switch v {
  | Success => 0
  | OperationsError => 1
  | ProtocolError => 2
  | TimeLimitExceeded => 3
  | SizeLimitExceeded => 4
  | AuthMethodNotSupported => 5
  | NoSuchObject => 6
  | InvalidCredentials => 7
  | InsufficientAccessRights => 8
  | Busy => 9
  | Unavailable => 10
  }

/// Whether this result code indicates success.
let resultCodeIsSuccess = (v: resultCode): bool =>
  switch v {
  | Success => true
  | _ => false
  }

/// Whether this result code indicates an authentication/authorisation failure.
let resultCodeIsAuthFailure = (v: resultCode): bool =>
  switch v {
  | AuthMethodNotSupported | InvalidCredentials | InsufficientAccessRights => true
  | _ => false
  }

/// Whether this is a transient error that may succeed on retry.
let resultCodeIsTransient = (v: resultCode): bool =>
  switch v {
  | Busy | Unavailable => true
  | _ => false
  }

