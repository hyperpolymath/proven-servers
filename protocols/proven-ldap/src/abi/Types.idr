-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LdapABI.Types: C-ABI-compatible numeric representations of Ldap types.
--
-- Maps every constructor of the core Ldap sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/ldap.zig) exactly.
--
-- Types covered:
--   SessionState              (4 constructors, tags 0-3)
--   Operation                 (10 constructors, tags 0-9)
--   SearchScope               (3 constructors, tags 0-2)
--   ResultCode                (11 constructors, tags 0-10)

module LdapABI.Types

%default total

---------------------------------------------------------------------------
-- SessionState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
session_stateSize : Nat
session_stateSize = 1

||| SessionState sum type for ABI encoding.
public export
data SessionState : Type where
  Anonymous : SessionState
  Bound : SessionState
  Closed : SessionState
  Binding : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Anonymous = 0
session_stateToTag Bound = 1
session_stateToTag Closed = 2
session_stateToTag Binding = 3

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Anonymous
tagToSessionState 1 = Just Bound
tagToSessionState 2 = Just Closed
tagToSessionState 3 = Just Binding
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Anonymous = Refl
session_stateRoundtrip Bound = Refl
session_stateRoundtrip Closed = Refl
session_stateRoundtrip Binding = Refl

---------------------------------------------------------------------------
-- Operation (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
operationSize : Nat
operationSize = 1

||| Operation sum type for ABI encoding.
public export
data Operation : Type where
  Bind : Operation
  Unbind : Operation
  Search : Operation
  Modify : Operation
  Add : Operation
  Delete : Operation
  ModDn : Operation
  Compare : Operation
  Abandon : Operation
  Extended : Operation

||| Encode a Operation to its ABI tag value.
public export
operationToTag : Operation -> Bits8
operationToTag Bind = 0
operationToTag Unbind = 1
operationToTag Search = 2
operationToTag Modify = 3
operationToTag Add = 4
operationToTag Delete = 5
operationToTag ModDn = 6
operationToTag Compare = 7
operationToTag Abandon = 8
operationToTag Extended = 9

||| Decode an ABI tag to a Operation.
public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0 = Just Bind
tagToOperation 1 = Just Unbind
tagToOperation 2 = Just Search
tagToOperation 3 = Just Modify
tagToOperation 4 = Just Add
tagToOperation 5 = Just Delete
tagToOperation 6 = Just ModDn
tagToOperation 7 = Just Compare
tagToOperation 8 = Just Abandon
tagToOperation 9 = Just Extended
tagToOperation _ = Nothing

||| Roundtrip proof: decoding an encoded Operation yields the original.
public export
operationRoundtrip : (x : Operation) -> tagToOperation (operationToTag x) = Just x
operationRoundtrip Bind = Refl
operationRoundtrip Unbind = Refl
operationRoundtrip Search = Refl
operationRoundtrip Modify = Refl
operationRoundtrip Add = Refl
operationRoundtrip Delete = Refl
operationRoundtrip ModDn = Refl
operationRoundtrip Compare = Refl
operationRoundtrip Abandon = Refl
operationRoundtrip Extended = Refl

---------------------------------------------------------------------------
-- SearchScope (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
search_scopeSize : Nat
search_scopeSize = 1

||| SearchScope sum type for ABI encoding.
public export
data SearchScope : Type where
  BaseObject : SearchScope
  SingleLevel : SearchScope
  WholeSubtree : SearchScope

||| Encode a SearchScope to its ABI tag value.
public export
search_scopeToTag : SearchScope -> Bits8
search_scopeToTag BaseObject = 0
search_scopeToTag SingleLevel = 1
search_scopeToTag WholeSubtree = 2

||| Decode an ABI tag to a SearchScope.
public export
tagToSearchScope : Bits8 -> Maybe SearchScope
tagToSearchScope 0 = Just BaseObject
tagToSearchScope 1 = Just SingleLevel
tagToSearchScope 2 = Just WholeSubtree
tagToSearchScope _ = Nothing

||| Roundtrip proof: decoding an encoded SearchScope yields the original.
public export
search_scopeRoundtrip : (x : SearchScope) -> tagToSearchScope (search_scopeToTag x) = Just x
search_scopeRoundtrip BaseObject = Refl
search_scopeRoundtrip SingleLevel = Refl
search_scopeRoundtrip WholeSubtree = Refl

---------------------------------------------------------------------------
-- ResultCode (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
result_codeSize : Nat
result_codeSize = 1

||| ResultCode sum type for ABI encoding.
public export
data ResultCode : Type where
  Success : ResultCode
  OperationsError : ResultCode
  ProtocolError : ResultCode
  TimeLimitExceeded : ResultCode
  SizeLimitExceeded : ResultCode
  AuthMethodNotSupported : ResultCode
  NoSuchObject : ResultCode
  InvalidCredentials : ResultCode
  InsufficientAccessRights : ResultCode
  Busy : ResultCode
  Unavailable : ResultCode

||| Encode a ResultCode to its ABI tag value.
public export
result_codeToTag : ResultCode -> Bits8
result_codeToTag Success = 0
result_codeToTag OperationsError = 1
result_codeToTag ProtocolError = 2
result_codeToTag TimeLimitExceeded = 3
result_codeToTag SizeLimitExceeded = 4
result_codeToTag AuthMethodNotSupported = 5
result_codeToTag NoSuchObject = 6
result_codeToTag InvalidCredentials = 7
result_codeToTag InsufficientAccessRights = 8
result_codeToTag Busy = 9
result_codeToTag Unavailable = 10

||| Decode an ABI tag to a ResultCode.
public export
tagToResultCode : Bits8 -> Maybe ResultCode
tagToResultCode 0 = Just Success
tagToResultCode 1 = Just OperationsError
tagToResultCode 2 = Just ProtocolError
tagToResultCode 3 = Just TimeLimitExceeded
tagToResultCode 4 = Just SizeLimitExceeded
tagToResultCode 5 = Just AuthMethodNotSupported
tagToResultCode 6 = Just NoSuchObject
tagToResultCode 7 = Just InvalidCredentials
tagToResultCode 8 = Just InsufficientAccessRights
tagToResultCode 9 = Just Busy
tagToResultCode 10 = Just Unavailable
tagToResultCode _ = Nothing

||| Roundtrip proof: decoding an encoded ResultCode yields the original.
public export
result_codeRoundtrip : (x : ResultCode) -> tagToResultCode (result_codeToTag x) = Just x
result_codeRoundtrip Success = Refl
result_codeRoundtrip OperationsError = Refl
result_codeRoundtrip ProtocolError = Refl
result_codeRoundtrip TimeLimitExceeded = Refl
result_codeRoundtrip SizeLimitExceeded = Refl
result_codeRoundtrip AuthMethodNotSupported = Refl
result_codeRoundtrip NoSuchObject = Refl
result_codeRoundtrip InvalidCredentials = Refl
result_codeRoundtrip InsufficientAccessRights = Refl
result_codeRoundtrip Busy = Refl
result_codeRoundtrip Unavailable = Refl
