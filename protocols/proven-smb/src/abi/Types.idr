-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SMBABI.Types: C-ABI-compatible numeric representations of SMB2/3 types.
--
-- Maps every constructor of the core SMB sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/smb.zig) exactly.
--
-- Types covered:
--   Command    (16 constructors, tags 0-15)
--   Dialect    (5 constructors, tags 0-4)
--   ShareType  (3 constructors, tags 0-2)
--   SessionState (6 constructors, tags 0-5) -- FFI composite lifecycle

module SMBABI.Types

import SMB.Types

%default total

---------------------------------------------------------------------------
-- Command (16 constructors, tags 0-15)
---------------------------------------------------------------------------

public export
commandSize : Nat
commandSize = 1

||| Encode a Command to its ABI tag value.
public export
commandToTag : Command -> Bits8
commandToTag Negotiate      = 0
commandToTag SessionSetup   = 1
commandToTag Logoff         = 2
commandToTag TreeConnect    = 3
commandToTag TreeDisconnect = 4
commandToTag Create         = 5
commandToTag Close          = 6
commandToTag Read           = 7
commandToTag Write          = 8
commandToTag Lock           = 9
commandToTag Ioctl          = 10
commandToTag Cancel         = 11
commandToTag QueryDirectory = 12
commandToTag ChangeNotify   = 13
commandToTag QueryInfo      = 14
commandToTag SetInfo        = 15

||| Decode an ABI tag value to a Command.
public export
tagToCommand : Bits8 -> Maybe Command
tagToCommand 0  = Just Negotiate
tagToCommand 1  = Just SessionSetup
tagToCommand 2  = Just Logoff
tagToCommand 3  = Just TreeConnect
tagToCommand 4  = Just TreeDisconnect
tagToCommand 5  = Just Create
tagToCommand 6  = Just Close
tagToCommand 7  = Just Read
tagToCommand 8  = Just Write
tagToCommand 9  = Just Lock
tagToCommand 10 = Just Ioctl
tagToCommand 11 = Just Cancel
tagToCommand 12 = Just QueryDirectory
tagToCommand 13 = Just ChangeNotify
tagToCommand 14 = Just QueryInfo
tagToCommand 15 = Just SetInfo
tagToCommand _  = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
commandRoundtrip : (c : Command) -> tagToCommand (commandToTag c) = Just c
commandRoundtrip Negotiate      = Refl
commandRoundtrip SessionSetup   = Refl
commandRoundtrip Logoff         = Refl
commandRoundtrip TreeConnect    = Refl
commandRoundtrip TreeDisconnect = Refl
commandRoundtrip Create         = Refl
commandRoundtrip Close          = Refl
commandRoundtrip Read           = Refl
commandRoundtrip Write          = Refl
commandRoundtrip Lock           = Refl
commandRoundtrip Ioctl          = Refl
commandRoundtrip Cancel         = Refl
commandRoundtrip QueryDirectory = Refl
commandRoundtrip ChangeNotify   = Refl
commandRoundtrip QueryInfo      = Refl
commandRoundtrip SetInfo        = Refl

---------------------------------------------------------------------------
-- Dialect (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
dialectSize : Nat
dialectSize = 1

||| Encode a Dialect to its ABI tag value.
public export
dialectToTag : Dialect -> Bits8
dialectToTag SMB2_0_2 = 0
dialectToTag SMB2_1   = 1
dialectToTag SMB3_0   = 2
dialectToTag SMB3_0_2 = 3
dialectToTag SMB3_1_1 = 4

||| Decode an ABI tag value to a Dialect.
public export
tagToDialect : Bits8 -> Maybe Dialect
tagToDialect 0 = Just SMB2_0_2
tagToDialect 1 = Just SMB2_1
tagToDialect 2 = Just SMB3_0
tagToDialect 3 = Just SMB3_0_2
tagToDialect 4 = Just SMB3_1_1
tagToDialect _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
dialectRoundtrip : (d : Dialect) -> tagToDialect (dialectToTag d) = Just d
dialectRoundtrip SMB2_0_2 = Refl
dialectRoundtrip SMB2_1   = Refl
dialectRoundtrip SMB3_0   = Refl
dialectRoundtrip SMB3_0_2 = Refl
dialectRoundtrip SMB3_1_1 = Refl

---------------------------------------------------------------------------
-- ShareType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
shareTypeSize : Nat
shareTypeSize = 1

||| Encode a ShareType to its ABI tag value.
public export
shareTypeToTag : ShareType -> Bits8
shareTypeToTag Disk  = 0
shareTypeToTag Pipe  = 1
shareTypeToTag Print = 2

||| Decode an ABI tag value to a ShareType.
public export
tagToShareType : Bits8 -> Maybe ShareType
tagToShareType 0 = Just Disk
tagToShareType 1 = Just Pipe
tagToShareType 2 = Just Print
tagToShareType _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
shareTypeRoundtrip : (s : ShareType) -> tagToShareType (shareTypeToTag s) = Just s
shareTypeRoundtrip Disk  = Refl
shareTypeRoundtrip Pipe  = Refl
shareTypeRoundtrip Print = Refl

---------------------------------------------------------------------------
-- SessionState (6 constructors, tags 0-5)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| SMB session lifecycle states for the FFI layer.
||| Combines connection + tree + file handle states into a single enum
||| for the C ABI.
public export
data SessionState : Type where
  ||| No connection established.
  SSIdle           : SessionState
  ||| Dialect negotiated, session not yet authenticated.
  SSNegotiated     : SessionState
  ||| Session authenticated, no tree connections.
  SSAuthenticated  : SessionState
  ||| At least one tree connection is active.
  SSTreeConnected  : SessionState
  ||| At least one file handle is open.
  SSFileOpen       : SessionState
  ||| Connection closing (logoff in progress).
  SSDisconnecting  : SessionState

public export
Eq SessionState where
  SSIdle          == SSIdle          = True
  SSNegotiated    == SSNegotiated    = True
  SSAuthenticated == SSAuthenticated = True
  SSTreeConnected == SSTreeConnected = True
  SSFileOpen      == SSFileOpen      = True
  SSDisconnecting == SSDisconnecting = True
  _               == _               = False

public export
Show SessionState where
  show SSIdle          = "Idle"
  show SSNegotiated    = "Negotiated"
  show SSAuthenticated = "Authenticated"
  show SSTreeConnected = "TreeConnected"
  show SSFileOpen      = "FileOpen"
  show SSDisconnecting = "Disconnecting"

public export
sessionStateSize : Nat
sessionStateSize = 1

||| Encode a SessionState to its ABI tag value.
public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle          = 0
sessionStateToTag SSNegotiated    = 1
sessionStateToTag SSAuthenticated = 2
sessionStateToTag SSTreeConnected = 3
sessionStateToTag SSFileOpen      = 4
sessionStateToTag SSDisconnecting = 5

||| Decode an ABI tag value to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSNegotiated
tagToSessionState 2 = Just SSAuthenticated
tagToSessionState 3 = Just SSTreeConnected
tagToSessionState 4 = Just SSFileOpen
tagToSessionState 5 = Just SSDisconnecting
tagToSessionState _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle          = Refl
sessionStateRoundtrip SSNegotiated    = Refl
sessionStateRoundtrip SSAuthenticated = Refl
sessionStateRoundtrip SSTreeConnected = Refl
sessionStateRoundtrip SSFileOpen      = Refl
sessionStateRoundtrip SSDisconnecting = Refl
