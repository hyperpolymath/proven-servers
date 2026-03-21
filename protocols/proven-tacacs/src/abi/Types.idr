-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TACACSABI Types: C-ABI-compatible numeric representations of TACACS+ types.
--
-- Maps every constructor of the core TACACS+ sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/tacacs.zig) exactly.
--
-- Types covered:
--   PacketType    (3 constructors, tags 0-2)
--   AuthenType    (5 constructors, tags 0-4)
--   AuthenAction  (3 constructors, tags 0-2)
--   AuthenStatus  (8 constructors, tags 0-7)
--   AuthorStatus  (5 constructors, tags 0-4)
--   AcctStatus    (3 constructors, tags 0-2)
--   AcctFlag      (3 constructors, tags 0-2)
--   SessionState  (5 constructors, tags 0-4)

module TACACSABI.Types

import TACACS.Types

%default total

---------------------------------------------------------------------------
-- PacketType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
packetTypeSize : Nat
packetTypeSize = 1

||| Encode a PacketType to its ABI tag value.
public export
packetTypeToTag : PacketType -> Bits8
packetTypeToTag Authentication = 0
packetTypeToTag Authorization  = 1
packetTypeToTag Accounting     = 2

||| Decode an ABI tag to a PacketType.
public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 0 = Just Authentication
tagToPacketType 1 = Just Authorization
tagToPacketType 2 = Just Accounting
tagToPacketType _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all PacketType values.
public export
packetTypeRoundtrip : (p : PacketType) -> tagToPacketType (packetTypeToTag p) = Just p
packetTypeRoundtrip Authentication = Refl
packetTypeRoundtrip Authorization  = Refl
packetTypeRoundtrip Accounting     = Refl

---------------------------------------------------------------------------
-- AuthenType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
authenTypeSize : Nat
authenTypeSize = 1

||| Encode an AuthenType to its ABI tag value.
public export
authenTypeToTag : AuthenType -> Bits8
authenTypeToTag ASCII    = 0
authenTypeToTag PAP      = 1
authenTypeToTag CHAP     = 2
authenTypeToTag MSCHAPv1 = 3
authenTypeToTag MSCHAPv2 = 4

||| Decode an ABI tag to an AuthenType.
public export
tagToAuthenType : Bits8 -> Maybe AuthenType
tagToAuthenType 0 = Just ASCII
tagToAuthenType 1 = Just PAP
tagToAuthenType 2 = Just CHAP
tagToAuthenType 3 = Just MSCHAPv1
tagToAuthenType 4 = Just MSCHAPv2
tagToAuthenType _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all AuthenType values.
public export
authenTypeRoundtrip : (a : AuthenType) -> tagToAuthenType (authenTypeToTag a) = Just a
authenTypeRoundtrip ASCII    = Refl
authenTypeRoundtrip PAP      = Refl
authenTypeRoundtrip CHAP     = Refl
authenTypeRoundtrip MSCHAPv1 = Refl
authenTypeRoundtrip MSCHAPv2 = Refl

---------------------------------------------------------------------------
-- AuthenAction (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
authenActionSize : Nat
authenActionSize = 1

||| Encode an AuthenAction to its ABI tag value.
public export
authenActionToTag : AuthenAction -> Bits8
authenActionToTag Login      = 0
authenActionToTag ChangePass = 1
authenActionToTag SendAuth   = 2

||| Decode an ABI tag to an AuthenAction.
public export
tagToAuthenAction : Bits8 -> Maybe AuthenAction
tagToAuthenAction 0 = Just Login
tagToAuthenAction 1 = Just ChangePass
tagToAuthenAction 2 = Just SendAuth
tagToAuthenAction _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all AuthenAction values.
public export
authenActionRoundtrip : (a : AuthenAction) -> tagToAuthenAction (authenActionToTag a) = Just a
authenActionRoundtrip Login      = Refl
authenActionRoundtrip ChangePass = Refl
authenActionRoundtrip SendAuth   = Refl

---------------------------------------------------------------------------
-- AuthenStatus (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
authenStatusSize : Nat
authenStatusSize = 1

||| Encode an AuthenStatus to its ABI tag value.
public export
authenStatusToTag : AuthenStatus -> Bits8
authenStatusToTag Pass       = 0
authenStatusToTag Fail       = 1
authenStatusToTag GetData    = 2
authenStatusToTag GetUser    = 3
authenStatusToTag GetPass    = 4
authenStatusToTag Restart    = 5
authenStatusToTag AuthenError = 6
authenStatusToTag Follow     = 7

||| Decode an ABI tag to an AuthenStatus.
public export
tagToAuthenStatus : Bits8 -> Maybe AuthenStatus
tagToAuthenStatus 0 = Just Pass
tagToAuthenStatus 1 = Just Fail
tagToAuthenStatus 2 = Just GetData
tagToAuthenStatus 3 = Just GetUser
tagToAuthenStatus 4 = Just GetPass
tagToAuthenStatus 5 = Just Restart
tagToAuthenStatus 6 = Just AuthenError
tagToAuthenStatus 7 = Just Follow
tagToAuthenStatus _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all AuthenStatus values.
public export
authenStatusRoundtrip : (s : AuthenStatus) -> tagToAuthenStatus (authenStatusToTag s) = Just s
authenStatusRoundtrip Pass       = Refl
authenStatusRoundtrip Fail       = Refl
authenStatusRoundtrip GetData    = Refl
authenStatusRoundtrip GetUser    = Refl
authenStatusRoundtrip GetPass    = Refl
authenStatusRoundtrip Restart    = Refl
authenStatusRoundtrip AuthenError = Refl
authenStatusRoundtrip Follow     = Refl

---------------------------------------------------------------------------
-- AuthorStatus (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
authorStatusSize : Nat
authorStatusSize = 1

||| Encode an AuthorStatus to its ABI tag value.
public export
authorStatusToTag : AuthorStatus -> Bits8
authorStatusToTag PassAdd     = 0
authorStatusToTag PassRepl    = 1
authorStatusToTag AuthorFail  = 2
authorStatusToTag AuthorError = 3
authorStatusToTag AuthorFollow = 4

||| Decode an ABI tag to an AuthorStatus.
public export
tagToAuthorStatus : Bits8 -> Maybe AuthorStatus
tagToAuthorStatus 0 = Just PassAdd
tagToAuthorStatus 1 = Just PassRepl
tagToAuthorStatus 2 = Just AuthorFail
tagToAuthorStatus 3 = Just AuthorError
tagToAuthorStatus 4 = Just AuthorFollow
tagToAuthorStatus _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all AuthorStatus values.
public export
authorStatusRoundtrip : (s : AuthorStatus) -> tagToAuthorStatus (authorStatusToTag s) = Just s
authorStatusRoundtrip PassAdd     = Refl
authorStatusRoundtrip PassRepl    = Refl
authorStatusRoundtrip AuthorFail  = Refl
authorStatusRoundtrip AuthorError = Refl
authorStatusRoundtrip AuthorFollow = Refl

---------------------------------------------------------------------------
-- AcctStatus (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
acctStatusSize : Nat
acctStatusSize = 1

||| Encode an AcctStatus to its ABI tag value.
public export
acctStatusToTag : AcctStatus -> Bits8
acctStatusToTag AcctSuccess = 0
acctStatusToTag AcctError   = 1
acctStatusToTag AcctFollow  = 2

||| Decode an ABI tag to an AcctStatus.
public export
tagToAcctStatus : Bits8 -> Maybe AcctStatus
tagToAcctStatus 0 = Just AcctSuccess
tagToAcctStatus 1 = Just AcctError
tagToAcctStatus 2 = Just AcctFollow
tagToAcctStatus _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all AcctStatus values.
public export
acctStatusRoundtrip : (s : AcctStatus) -> tagToAcctStatus (acctStatusToTag s) = Just s
acctStatusRoundtrip AcctSuccess = Refl
acctStatusRoundtrip AcctError   = Refl
acctStatusRoundtrip AcctFollow  = Refl

---------------------------------------------------------------------------
-- AcctFlag (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
acctFlagSize : Nat
acctFlagSize = 1

||| Encode an AcctFlag to its ABI tag value.
public export
acctFlagToTag : AcctFlag -> Bits8
acctFlagToTag Start    = 0
acctFlagToTag Stop     = 1
acctFlagToTag Watchdog = 2

||| Decode an ABI tag to an AcctFlag.
public export
tagToAcctFlag : Bits8 -> Maybe AcctFlag
tagToAcctFlag 0 = Just Start
tagToAcctFlag 1 = Just Stop
tagToAcctFlag 2 = Just Watchdog
tagToAcctFlag _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all AcctFlag values.
public export
acctFlagRoundtrip : (f : AcctFlag) -> tagToAcctFlag (acctFlagToTag f) = Just f
acctFlagRoundtrip Start    = Refl
acctFlagRoundtrip Stop     = Refl
acctFlagRoundtrip Watchdog = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| TACACS+ session lifecycle states for FFI management.
||| This is a simplified view combining AAA phases into a single enum.
public export
data SessionState : Type where
  ||| No session. Initial and terminal state.
  SSIdle           : SessionState
  ||| Session created, awaiting authentication.
  SSAuthenticating : SessionState
  ||| Authentication passed, authorization in progress.
  SSAuthorizing    : SessionState
  ||| Session active, accounting records may be generated.
  SSActive         : SessionState
  ||| Session ending, final accounting being sent.
  SSClosing        : SessionState

public export
Eq SessionState where
  SSIdle           == SSIdle           = True
  SSAuthenticating == SSAuthenticating = True
  SSAuthorizing    == SSAuthorizing    = True
  SSActive         == SSActive         = True
  SSClosing        == SSClosing        = True
  _                == _                = False

public export
Show SessionState where
  show SSIdle           = "Idle"
  show SSAuthenticating = "Authenticating"
  show SSAuthorizing    = "Authorizing"
  show SSActive         = "Active"
  show SSClosing        = "Closing"

public export
sessionStateSize : Nat
sessionStateSize = 1

||| Encode a SessionState to its ABI tag value.
public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle           = 0
sessionStateToTag SSAuthenticating = 1
sessionStateToTag SSAuthorizing    = 2
sessionStateToTag SSActive         = 3
sessionStateToTag SSClosing        = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSAuthenticating
tagToSessionState 2 = Just SSAuthorizing
tagToSessionState 3 = Just SSActive
tagToSessionState 4 = Just SSClosing
tagToSessionState _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all SessionState values.
public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle           = Refl
sessionStateRoundtrip SSAuthenticating = Refl
sessionStateRoundtrip SSAuthorizing    = Refl
sessionStateRoundtrip SSActive         = Refl
sessionStateRoundtrip SSClosing        = Refl
