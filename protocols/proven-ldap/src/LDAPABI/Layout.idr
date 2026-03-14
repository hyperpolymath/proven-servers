-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LDAPABI.Layout: C-ABI-compatible numeric representations of LDAP types.
--
-- Maps every constructor of the three core sum types (Operation,
-- SearchScope, ResultCode) and the session state (SessionState) to
-- fixed Bits8 values for C interop.  Each type gets a total encoder,
-- partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/ldap.h) and the
-- Zig FFI enums (ffi/zig/src/ldap.zig) exactly.

module LDAPABI.Layout

import LDAP.Types

%default total

---------------------------------------------------------------------------
-- SessionState (4 constructors, tags 0-3)
--
-- LDAP session lifecycle (RFC 4511):
--   Anonymous -> Bound (via Bind)
--   Any non-Closed -> Closed (via Unbind)
--   Bound -> Bound (re-Bind)
---------------------------------------------------------------------------

||| LDAP session states.
public export
data SessionState : Type where
  ||| Connection established, not yet authenticated.
  Anonymous : SessionState
  ||| Successfully bound (authenticated).
  Bound     : SessionState
  ||| Unbind received or connection terminated.
  Closed    : SessionState
  ||| Bind in progress (awaiting server response).
  Binding   : SessionState

public export
Eq SessionState where
  Anonymous == Anonymous = True
  Bound     == Bound     = True
  Closed    == Closed    = True
  Binding   == Binding   = True
  _         == _         = False

public export
Show SessionState where
  show Anonymous = "Anonymous"
  show Bound     = "Bound"
  show Closed    = "Closed"
  show Binding   = "Binding"

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag Anonymous = 0
sessionStateToTag Bound     = 1
sessionStateToTag Closed    = 2
sessionStateToTag Binding   = 3

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Anonymous
tagToSessionState 1 = Just Bound
tagToSessionState 2 = Just Closed
tagToSessionState 3 = Just Binding
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Anonymous = Refl
sessionStateRoundtrip Bound     = Refl
sessionStateRoundtrip Closed    = Refl
sessionStateRoundtrip Binding   = Refl

---------------------------------------------------------------------------
-- Operation (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
operationSize : Nat
operationSize = 1

public export
operationToTag : Operation -> Bits8
operationToTag Bind     = 0
operationToTag Unbind   = 1
operationToTag Search   = 2
operationToTag Modify   = 3
operationToTag Add      = 4
operationToTag Delete   = 5
operationToTag ModDN    = 6
operationToTag Compare  = 7
operationToTag Abandon  = 8
operationToTag Extended = 9

public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0 = Just Bind
tagToOperation 1 = Just Unbind
tagToOperation 2 = Just Search
tagToOperation 3 = Just Modify
tagToOperation 4 = Just Add
tagToOperation 5 = Just Delete
tagToOperation 6 = Just ModDN
tagToOperation 7 = Just Compare
tagToOperation 8 = Just Abandon
tagToOperation 9 = Just Extended
tagToOperation _ = Nothing

public export
operationRoundtrip : (op : Operation) -> tagToOperation (operationToTag op) = Just op
operationRoundtrip Bind     = Refl
operationRoundtrip Unbind   = Refl
operationRoundtrip Search   = Refl
operationRoundtrip Modify   = Refl
operationRoundtrip Add      = Refl
operationRoundtrip Delete   = Refl
operationRoundtrip ModDN    = Refl
operationRoundtrip Compare  = Refl
operationRoundtrip Abandon  = Refl
operationRoundtrip Extended = Refl

---------------------------------------------------------------------------
-- SearchScope (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
searchScopeSize : Nat
searchScopeSize = 1

public export
searchScopeToTag : SearchScope -> Bits8
searchScopeToTag BaseObject   = 0
searchScopeToTag SingleLevel  = 1
searchScopeToTag WholeSubtree = 2

public export
tagToSearchScope : Bits8 -> Maybe SearchScope
tagToSearchScope 0 = Just BaseObject
tagToSearchScope 1 = Just SingleLevel
tagToSearchScope 2 = Just WholeSubtree
tagToSearchScope _ = Nothing

public export
searchScopeRoundtrip : (s : SearchScope) -> tagToSearchScope (searchScopeToTag s) = Just s
searchScopeRoundtrip BaseObject   = Refl
searchScopeRoundtrip SingleLevel  = Refl
searchScopeRoundtrip WholeSubtree = Refl

---------------------------------------------------------------------------
-- ResultCode (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
resultCodeSize : Nat
resultCodeSize = 1

public export
resultCodeToTag : ResultCode -> Bits8
resultCodeToTag Success                  = 0
resultCodeToTag OperationsError          = 1
resultCodeToTag ProtocolError            = 2
resultCodeToTag TimeLimitExceeded        = 3
resultCodeToTag SizeLimitExceeded        = 4
resultCodeToTag AuthMethodNotSupported   = 5
resultCodeToTag NoSuchObject             = 6
resultCodeToTag InvalidCredentials       = 7
resultCodeToTag InsufficientAccessRights = 8
resultCodeToTag Busy                     = 9
resultCodeToTag Unavailable              = 10

public export
tagToResultCode : Bits8 -> Maybe ResultCode
tagToResultCode 0  = Just Success
tagToResultCode 1  = Just OperationsError
tagToResultCode 2  = Just ProtocolError
tagToResultCode 3  = Just TimeLimitExceeded
tagToResultCode 4  = Just SizeLimitExceeded
tagToResultCode 5  = Just AuthMethodNotSupported
tagToResultCode 6  = Just NoSuchObject
tagToResultCode 7  = Just InvalidCredentials
tagToResultCode 8  = Just InsufficientAccessRights
tagToResultCode 9  = Just Busy
tagToResultCode 10 = Just Unavailable
tagToResultCode _  = Nothing

public export
resultCodeRoundtrip : (r : ResultCode) -> tagToResultCode (resultCodeToTag r) = Just r
resultCodeRoundtrip Success                  = Refl
resultCodeRoundtrip OperationsError          = Refl
resultCodeRoundtrip ProtocolError            = Refl
resultCodeRoundtrip TimeLimitExceeded        = Refl
resultCodeRoundtrip SizeLimitExceeded        = Refl
resultCodeRoundtrip AuthMethodNotSupported   = Refl
resultCodeRoundtrip NoSuchObject             = Refl
resultCodeRoundtrip InvalidCredentials       = Refl
resultCodeRoundtrip InsufficientAccessRights = Refl
resultCodeRoundtrip Busy                     = Refl
resultCodeRoundtrip Unavailable              = Refl
