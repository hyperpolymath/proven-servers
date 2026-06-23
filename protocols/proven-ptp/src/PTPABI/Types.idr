-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- PTPABI.Types: C-ABI-compatible numeric representations of PTP types.
--
-- Maps every constructor of the PTP domain types (MessageType, ClockClass,
-- PortState, DelayMechanism) to fixed Bits8 values for C interop.
-- Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/ptp.zig) exactly.

module PTPABI.Types

import PTP.Types

%default total

---------------------------------------------------------------------------
-- MessageType (10 constructors, tags 0-9)
---------------------------------------------------------------------------

||| C-ABI representation size for MessageType (1 byte).
public export
messageTypeSize : Nat
messageTypeSize = 1

||| Map MessageType to its C-ABI byte value.
|||
||| Tag assignments:
|||   Sync               = 0    DelayReq            = 1
|||   PdelayReq          = 2    PdelayResp           = 3
|||   FollowUp           = 4    DelayResp            = 5
|||   PdelayRespFollowUp = 6    Announce             = 7
|||   Signaling          = 8    Management           = 9
public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag Sync               = 0
messageTypeToTag DelayReq           = 1
messageTypeToTag PdelayReq          = 2
messageTypeToTag PdelayResp         = 3
messageTypeToTag FollowUp           = 4
messageTypeToTag DelayResp          = 5
messageTypeToTag PdelayRespFollowUp = 6
messageTypeToTag Announce           = 7
messageTypeToTag Signaling          = 8
messageTypeToTag Management         = 9

||| Recover MessageType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-9.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just Sync
tagToMessageType 1 = Just DelayReq
tagToMessageType 2 = Just PdelayReq
tagToMessageType 3 = Just PdelayResp
tagToMessageType 4 = Just FollowUp
tagToMessageType 5 = Just DelayResp
tagToMessageType 6 = Just PdelayRespFollowUp
tagToMessageType 7 = Just Announce
tagToMessageType 8 = Just Signaling
tagToMessageType 9 = Just Management
tagToMessageType _ = Nothing

||| Proof: encoding then decoding MessageType is the identity.
public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip Sync               = Refl
messageTypeRoundtrip DelayReq           = Refl
messageTypeRoundtrip PdelayReq          = Refl
messageTypeRoundtrip PdelayResp         = Refl
messageTypeRoundtrip FollowUp           = Refl
messageTypeRoundtrip DelayResp          = Refl
messageTypeRoundtrip PdelayRespFollowUp = Refl
messageTypeRoundtrip Announce           = Refl
messageTypeRoundtrip Signaling          = Refl
messageTypeRoundtrip Management         = Refl

---------------------------------------------------------------------------
-- ClockClass (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for ClockClass (1 byte).
public export
clockClassSize : Nat
clockClassSize = 1

||| Map ClockClass to its C-ABI byte value.
|||
||| Tag assignments:
|||   PrimaryClock        = 0
|||   ApplicationSpecific = 1
|||   SlaveOnly           = 2
|||   DefaultClass        = 3
public export
clockClassToTag : ClockClass -> Bits8
clockClassToTag PrimaryClock        = 0
clockClassToTag ApplicationSpecific = 1
clockClassToTag SlaveOnly           = 2
clockClassToTag DefaultClass        = 3

||| Recover ClockClass from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToClockClass : Bits8 -> Maybe ClockClass
tagToClockClass 0 = Just PrimaryClock
tagToClockClass 1 = Just ApplicationSpecific
tagToClockClass 2 = Just SlaveOnly
tagToClockClass 3 = Just DefaultClass
tagToClockClass _ = Nothing

||| Proof: encoding then decoding ClockClass is the identity.
public export
clockClassRoundtrip : (c : ClockClass) -> tagToClockClass (clockClassToTag c) = Just c
clockClassRoundtrip PrimaryClock        = Refl
clockClassRoundtrip ApplicationSpecific = Refl
clockClassRoundtrip SlaveOnly           = Refl
clockClassRoundtrip DefaultClass        = Refl

---------------------------------------------------------------------------
-- PortState (9 constructors, tags 0-8)
---------------------------------------------------------------------------

||| C-ABI representation size for PortState (1 byte).
public export
portStateSize : Nat
portStateSize = 1

||| Map PortState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Initializing = 0    Faulty       = 1    Disabled  = 2
|||   Listening    = 3    PreMaster    = 4    Master    = 5
|||   Passive      = 6    Uncalibrated = 7    Slave     = 8
public export
portStateToTag : PortState -> Bits8
portStateToTag Initializing = 0
portStateToTag Faulty       = 1
portStateToTag Disabled     = 2
portStateToTag Listening    = 3
portStateToTag PreMaster    = 4
portStateToTag Master       = 5
portStateToTag Passive      = 6
portStateToTag Uncalibrated = 7
portStateToTag Slave        = 8

||| Recover PortState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-8.
public export
tagToPortState : Bits8 -> Maybe PortState
tagToPortState 0 = Just Initializing
tagToPortState 1 = Just Faulty
tagToPortState 2 = Just Disabled
tagToPortState 3 = Just Listening
tagToPortState 4 = Just PreMaster
tagToPortState 5 = Just Master
tagToPortState 6 = Just Passive
tagToPortState 7 = Just Uncalibrated
tagToPortState 8 = Just Slave
tagToPortState _ = Nothing

||| Proof: encoding then decoding PortState is the identity.
public export
portStateRoundtrip : (p : PortState) -> tagToPortState (portStateToTag p) = Just p
portStateRoundtrip Initializing = Refl
portStateRoundtrip Faulty       = Refl
portStateRoundtrip Disabled     = Refl
portStateRoundtrip Listening    = Refl
portStateRoundtrip PreMaster    = Refl
portStateRoundtrip Master       = Refl
portStateRoundtrip Passive      = Refl
portStateRoundtrip Uncalibrated = Refl
portStateRoundtrip Slave        = Refl

---------------------------------------------------------------------------
-- DelayMechanism (3 constructors, tags 0-2)
---------------------------------------------------------------------------

||| C-ABI representation size for DelayMechanism (1 byte).
public export
delayMechanismSize : Nat
delayMechanismSize = 1

||| Map DelayMechanism to its C-ABI byte value.
|||
||| Tag assignments:
|||   E2E        = 0
|||   P2P        = 1
|||   DMDisabled = 2
public export
delayMechanismToTag : DelayMechanism -> Bits8
delayMechanismToTag E2E        = 0
delayMechanismToTag P2P        = 1
delayMechanismToTag DMDisabled = 2

||| Recover DelayMechanism from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-2.
public export
tagToDelayMechanism : Bits8 -> Maybe DelayMechanism
tagToDelayMechanism 0 = Just E2E
tagToDelayMechanism 1 = Just P2P
tagToDelayMechanism 2 = Just DMDisabled
tagToDelayMechanism _ = Nothing

||| Proof: encoding then decoding DelayMechanism is the identity.
public export
delayMechanismRoundtrip : (d : DelayMechanism) -> tagToDelayMechanism (delayMechanismToTag d) = Just d
delayMechanismRoundtrip E2E        = Refl
delayMechanismRoundtrip P2P        = Refl
delayMechanismRoundtrip DMDisabled = Refl

---------------------------------------------------------------------------
-- PTPError (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| Error codes for PTP FFI operations.
public export
data PTPError : Type where
  ||| No error.
  PtpOk               : PTPError
  ||| Invalid slot index.
  PtpInvalidSlot      : PTPError
  ||| Clock not active.
  PtpNotActive        : PTPError
  ||| Invalid port state transition.
  PtpInvalidTransition : PTPError
  ||| Invalid message type for current state.
  PtpInvalidMessage   : PTPError
  ||| Clock synchronisation error.
  PtpSyncError        : PTPError
  ||| Best Master Clock algorithm error.
  PtpBMCError         : PTPError

public export
Show PTPError where
  show PtpOk                = "Ok"
  show PtpInvalidSlot       = "InvalidSlot"
  show PtpNotActive         = "NotActive"
  show PtpInvalidTransition = "InvalidTransition"
  show PtpInvalidMessage    = "InvalidMessage"
  show PtpSyncError         = "SyncError"
  show PtpBMCError          = "BMCError"

||| C-ABI representation size for PTPError (1 byte).
public export
ptpErrorSize : Nat
ptpErrorSize = 1

||| Map PTPError to its C-ABI byte value.
public export
ptpErrorToTag : PTPError -> Bits8
ptpErrorToTag PtpOk                = 0
ptpErrorToTag PtpInvalidSlot       = 1
ptpErrorToTag PtpNotActive         = 2
ptpErrorToTag PtpInvalidTransition = 3
ptpErrorToTag PtpInvalidMessage    = 4
ptpErrorToTag PtpSyncError         = 5
ptpErrorToTag PtpBMCError          = 6

||| Recover PTPError from its C-ABI byte value.
public export
tagToPTPError : Bits8 -> Maybe PTPError
tagToPTPError 0 = Just PtpOk
tagToPTPError 1 = Just PtpInvalidSlot
tagToPTPError 2 = Just PtpNotActive
tagToPTPError 3 = Just PtpInvalidTransition
tagToPTPError 4 = Just PtpInvalidMessage
tagToPTPError 5 = Just PtpSyncError
tagToPTPError 6 = Just PtpBMCError
tagToPTPError _ = Nothing

||| Proof: encoding then decoding PTPError is the identity.
public export
ptpErrorRoundtrip : (e : PTPError) -> tagToPTPError (ptpErrorToTag e) = Just e
ptpErrorRoundtrip PtpOk                = Refl
ptpErrorRoundtrip PtpInvalidSlot       = Refl
ptpErrorRoundtrip PtpNotActive         = Refl
ptpErrorRoundtrip PtpInvalidTransition = Refl
ptpErrorRoundtrip PtpInvalidMessage    = Refl
ptpErrorRoundtrip PtpSyncError         = Refl
ptpErrorRoundtrip PtpBMCError          = Refl
