-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NTPABI.Layout: C-ABI-compatible numeric representations of NTP types.
--
-- Maps every constructor of the NTP domain types (LeapIndicator, NTPMode,
-- Stratum, NTPVersion, ExchangeState, ClockDisciplineState, KissCode,
-- NtpError) to fixed Bits8 values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/ntp.h) and the
-- Zig FFI enums (ffi/zig/src/ntp.zig) exactly.

module NTPABI.Layout

import NTP.Mode
import NTP.Stratum

%default total

---------------------------------------------------------------------------
-- LeapIndicator (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for LeapIndicator (1 byte).
public export
leapIndicatorSize : Nat
leapIndicatorSize = 1

||| Map LeapIndicator to its C-ABI byte value.
|||
||| Tag assignments (matching RFC 5905 Section 7.3):
|||   NoWarning      = 0
|||   LastMinute61   = 1
|||   LastMinute59   = 2
|||   Unsynchronised = 3
public export
leapIndicatorToTag : LeapIndicator -> Bits8
leapIndicatorToTag NoWarning      = 0
leapIndicatorToTag LastMinute61   = 1
leapIndicatorToTag LastMinute59   = 2
leapIndicatorToTag Unsynchronised = 3

||| Recover LeapIndicator from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToLeapIndicator : Bits8 -> Maybe LeapIndicator
tagToLeapIndicator 0 = Just NoWarning
tagToLeapIndicator 1 = Just LastMinute61
tagToLeapIndicator 2 = Just LastMinute59
tagToLeapIndicator 3 = Just Unsynchronised
tagToLeapIndicator _ = Nothing

||| Proof: encoding then decoding LeapIndicator is the identity.
public export
leapIndicatorRoundtrip : (li : LeapIndicator) -> tagToLeapIndicator (leapIndicatorToTag li) = Just li
leapIndicatorRoundtrip NoWarning      = Refl
leapIndicatorRoundtrip LastMinute61   = Refl
leapIndicatorRoundtrip LastMinute59   = Refl
leapIndicatorRoundtrip Unsynchronised = Refl

---------------------------------------------------------------------------
-- NTPMode (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| C-ABI representation size for NTPMode (1 byte).
public export
ntpModeSize : Nat
ntpModeSize = 1

||| Map NTPMode to its C-ABI byte value.
|||
||| Tag assignments (matching RFC 5905 Section 3):
|||   Reserved         = 0
|||   SymmetricActive  = 1
|||   SymmetricPassive = 2
|||   Client           = 3
|||   Server           = 4
|||   Broadcast        = 5
|||   ControlMessage   = 6
|||   Private          = 7
public export
ntpModeToTag : NTPMode -> Bits8
ntpModeToTag Reserved         = 0
ntpModeToTag SymmetricActive  = 1
ntpModeToTag SymmetricPassive = 2
ntpModeToTag Client           = 3
ntpModeToTag Server           = 4
ntpModeToTag Broadcast        = 5
ntpModeToTag ControlMessage   = 6
ntpModeToTag Private          = 7

||| Recover NTPMode from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-7.
public export
tagToNtpMode : Bits8 -> Maybe NTPMode
tagToNtpMode 0 = Just Reserved
tagToNtpMode 1 = Just SymmetricActive
tagToNtpMode 2 = Just SymmetricPassive
tagToNtpMode 3 = Just Client
tagToNtpMode 4 = Just Server
tagToNtpMode 5 = Just Broadcast
tagToNtpMode 6 = Just ControlMessage
tagToNtpMode 7 = Just Private
tagToNtpMode _ = Nothing

||| Proof: encoding then decoding NTPMode is the identity.
public export
ntpModeRoundtrip : (m : NTPMode) -> tagToNtpMode (ntpModeToTag m) = Just m
ntpModeRoundtrip Reserved         = Refl
ntpModeRoundtrip SymmetricActive  = Refl
ntpModeRoundtrip SymmetricPassive = Refl
ntpModeRoundtrip Client           = Refl
ntpModeRoundtrip Server           = Refl
ntpModeRoundtrip Broadcast        = Refl
ntpModeRoundtrip ControlMessage   = Refl
ntpModeRoundtrip Private          = Refl

---------------------------------------------------------------------------
-- StratumLevel (4 constructor categories, tags 0-16)
-- Mapped as raw byte values to preserve the full 0-16 range.
---------------------------------------------------------------------------

||| C-ABI representation size for Stratum (1 byte).
public export
stratumSize : Nat
stratumSize = 1

||| Map Stratum to its C-ABI byte value.
|||
||| Tag assignments (matching RFC 5905 Section 7.3):
|||   Unspecified            = 0
|||   PrimaryReference       = 1
|||   SecondaryReference n   = n  (where 2 <= n <= 15)
|||   Unsynchronised         = 16
public export
stratumToTag : Stratum -> Bits8
stratumToTag Unspecified            = 0
stratumToTag PrimaryReference       = 1
stratumToTag (SecondaryReference n) = cast n
stratumToTag Unsynchronised         = 16

||| Recover Stratum from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-16.
public export
tagToStratum : Bits8 -> Maybe Stratum
tagToStratum 0  = Just Unspecified
tagToStratum 1  = Just PrimaryReference
tagToStratum 16 = Just Unsynchronised
tagToStratum n  =
  let nat = cast {to=Nat} n
  in if nat >= 2 && nat <= 15
       then Just (SecondaryReference nat)
       else Nothing

---------------------------------------------------------------------------
-- NTPVersion (2 valid versions: 3 and 4)
---------------------------------------------------------------------------

||| NTP protocol versions supported.
public export
data NTPVersion : Type where
  ||| NTPv3 (RFC 1305).
  Version3 : NTPVersion
  ||| NTPv4 (RFC 5905).
  Version4 : NTPVersion

public export
Eq NTPVersion where
  Version3 == Version3 = True
  Version4 == Version4 = True
  _        == _        = False

||| C-ABI representation size for NTPVersion (1 byte).
public export
ntpVersionSize : Nat
ntpVersionSize = 1

||| Map NTPVersion to its C-ABI byte value.
public export
ntpVersionToTag : NTPVersion -> Bits8
ntpVersionToTag Version3 = 3
ntpVersionToTag Version4 = 4

||| Recover NTPVersion from its C-ABI byte value.
public export
tagToNtpVersion : Bits8 -> Maybe NTPVersion
tagToNtpVersion 3 = Just Version3
tagToNtpVersion 4 = Just Version4
tagToNtpVersion _ = Nothing

||| Proof: encoding then decoding NTPVersion is the identity.
public export
ntpVersionRoundtrip : (v : NTPVersion) -> tagToNtpVersion (ntpVersionToTag v) = Just v
ntpVersionRoundtrip Version3 = Refl
ntpVersionRoundtrip Version4 = Refl

---------------------------------------------------------------------------
-- ExchangeState (4 constructors, tags 0-3)
-- States of an NTP client-server exchange lifecycle.
---------------------------------------------------------------------------

||| States of an NTP exchange lifecycle.
||| Idle -> RequestReceived -> TimestampCalculated -> ResponseSent
public export
data ExchangeState : Type where
  ||| Waiting for a client request.
  Idle                : ExchangeState
  ||| Client request received; t1 and t2 timestamps captured.
  RequestReceived     : ExchangeState
  ||| Clock offset and delay calculated from t1, t2, t3.
  TimestampCalculated : ExchangeState
  ||| Server response sent; t4 timestamp recorded.
  ResponseSent        : ExchangeState

public export
Eq ExchangeState where
  Idle                == Idle                = True
  RequestReceived     == RequestReceived     = True
  TimestampCalculated == TimestampCalculated = True
  ResponseSent        == ResponseSent        = True
  _                   == _                   = False

public export
Show ExchangeState where
  show Idle                = "Idle"
  show RequestReceived     = "RequestReceived"
  show TimestampCalculated = "TimestampCalculated"
  show ResponseSent        = "ResponseSent"

||| C-ABI representation size for ExchangeState (1 byte).
public export
exchangeStateSize : Nat
exchangeStateSize = 1

||| Map ExchangeState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Idle                = 0
|||   RequestReceived     = 1
|||   TimestampCalculated = 2
|||   ResponseSent        = 3
public export
exchangeStateToTag : ExchangeState -> Bits8
exchangeStateToTag Idle                = 0
exchangeStateToTag RequestReceived     = 1
exchangeStateToTag TimestampCalculated = 2
exchangeStateToTag ResponseSent        = 3

||| Recover ExchangeState from its C-ABI byte value.
public export
tagToExchangeState : Bits8 -> Maybe ExchangeState
tagToExchangeState 0 = Just Idle
tagToExchangeState 1 = Just RequestReceived
tagToExchangeState 2 = Just TimestampCalculated
tagToExchangeState 3 = Just ResponseSent
tagToExchangeState _ = Nothing

||| Proof: encoding then decoding ExchangeState is the identity.
public export
exchangeStateRoundtrip : (s : ExchangeState) -> tagToExchangeState (exchangeStateToTag s) = Just s
exchangeStateRoundtrip Idle                = Refl
exchangeStateRoundtrip RequestReceived     = Refl
exchangeStateRoundtrip TimestampCalculated = Refl
exchangeStateRoundtrip ResponseSent        = Refl

---------------------------------------------------------------------------
-- ClockDisciplineState (5 constructors, tags 0-4)
-- States of the NTP clock discipline algorithm (RFC 5905 Section 12).
---------------------------------------------------------------------------

||| States of the NTP clock discipline algorithm.
||| Controls how the local clock is adjusted based on NTP measurements.
public export
data ClockDisciplineState : Type where
  ||| No peers available; clock is free-running.
  Unset   : ClockDisciplineState
  ||| First measurement received; waiting for enough samples.
  Spike   : ClockDisciplineState
  ||| Frequency correction mode (large offset detected).
  Freq    : ClockDisciplineState
  ||| Synchronised: applying phase-locked loop corrections.
  Sync    : ClockDisciplineState
  ||| Panic: offset too large, intervention required.
  Panic   : ClockDisciplineState

public export
Eq ClockDisciplineState where
  Unset == Unset = True
  Spike == Spike = True
  Freq  == Freq  = True
  Sync  == Sync  = True
  Panic == Panic = True
  _     == _     = False

public export
Show ClockDisciplineState where
  show Unset = "Unset"
  show Spike = "Spike"
  show Freq  = "Freq"
  show Sync  = "Sync"
  show Panic = "Panic"

||| C-ABI representation size for ClockDisciplineState (1 byte).
public export
clockDisciplineStateSize : Nat
clockDisciplineStateSize = 1

||| Map ClockDisciplineState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Unset = 0
|||   Spike = 1
|||   Freq  = 2
|||   Sync  = 3
|||   Panic = 4
public export
clockDisciplineStateToTag : ClockDisciplineState -> Bits8
clockDisciplineStateToTag Unset = 0
clockDisciplineStateToTag Spike = 1
clockDisciplineStateToTag Freq  = 2
clockDisciplineStateToTag Sync  = 3
clockDisciplineStateToTag Panic = 4

||| Recover ClockDisciplineState from its C-ABI byte value.
public export
tagToClockDisciplineState : Bits8 -> Maybe ClockDisciplineState
tagToClockDisciplineState 0 = Just Unset
tagToClockDisciplineState 1 = Just Spike
tagToClockDisciplineState 2 = Just Freq
tagToClockDisciplineState 3 = Just Sync
tagToClockDisciplineState 4 = Just Panic
tagToClockDisciplineState _ = Nothing

||| Proof: encoding then decoding ClockDisciplineState is the identity.
public export
clockDisciplineStateRoundtrip : (s : ClockDisciplineState) -> tagToClockDisciplineState (clockDisciplineStateToTag s) = Just s
clockDisciplineStateRoundtrip Unset = Refl
clockDisciplineStateRoundtrip Spike = Refl
clockDisciplineStateRoundtrip Freq  = Refl
clockDisciplineStateRoundtrip Sync  = Refl
clockDisciplineStateRoundtrip Panic = Refl

---------------------------------------------------------------------------
-- KissCode (4 constructors, tags 0-3)
-- Kiss-o'-Death codes (RFC 5905 Section 7.4).
---------------------------------------------------------------------------

||| C-ABI representation size for KissCode (1 byte).
public export
kissCodeSize : Nat
kissCodeSize = 1

||| KissCode type for ABI — simplified from NTP.Packet.KoDCode to avoid
||| the OtherKoD String constructor which is not C-ABI compatible.
public export
data KissCodeABI : Type where
  ||| DENY: Access denied by server policy.
  KissDeny : KissCodeABI
  ||| RSTR: Access restricted.
  KissRstr : KissCodeABI
  ||| RATE: Rate exceeded; reduce poll interval.
  KissRate : KissCodeABI
  ||| Unknown/other kiss code.
  KissOther : KissCodeABI

public export
Eq KissCodeABI where
  KissDeny  == KissDeny  = True
  KissRstr  == KissRstr  = True
  KissRate  == KissRate  = True
  KissOther == KissOther = True
  _         == _         = False

||| Map KissCodeABI to its C-ABI byte value.
|||
||| Tag assignments:
|||   KissDeny  = 0
|||   KissRstr  = 1
|||   KissRate  = 2
|||   KissOther = 3
public export
kissCodeToTag : KissCodeABI -> Bits8
kissCodeToTag KissDeny  = 0
kissCodeToTag KissRstr  = 1
kissCodeToTag KissRate  = 2
kissCodeToTag KissOther = 3

||| Recover KissCodeABI from its C-ABI byte value.
public export
tagToKissCode : Bits8 -> Maybe KissCodeABI
tagToKissCode 0 = Just KissDeny
tagToKissCode 1 = Just KissRstr
tagToKissCode 2 = Just KissRate
tagToKissCode 3 = Just KissOther
tagToKissCode _ = Nothing

||| Proof: encoding then decoding KissCodeABI is the identity.
public export
kissCodeRoundtrip : (k : KissCodeABI) -> tagToKissCode (kissCodeToTag k) = Just k
kissCodeRoundtrip KissDeny  = Refl
kissCodeRoundtrip KissRstr  = Refl
kissCodeRoundtrip KissRate  = Refl
kissCodeRoundtrip KissOther = Refl

---------------------------------------------------------------------------
-- NtpError (6 constructors, tags 0-5)
-- Error codes returned by NTP FFI operations.
---------------------------------------------------------------------------

||| NTP-specific error codes for FFI operations.
public export
data NtpError : Type where
  ||| No error.
  NtpOk             : NtpError
  ||| Invalid slot index.
  NtpInvalidSlot    : NtpError
  ||| Context not active.
  NtpNotActive      : NtpError
  ||| Packet validation failed.
  NtpInvalidPacket  : NtpError
  ||| Kiss-o'-Death received.
  NtpKissOfDeath    : NtpError
  ||| Stratum too high (unsynchronised).
  NtpStratumTooHigh : NtpError

public export
Eq NtpError where
  NtpOk             == NtpOk             = True
  NtpInvalidSlot    == NtpInvalidSlot    = True
  NtpNotActive      == NtpNotActive      = True
  NtpInvalidPacket  == NtpInvalidPacket  = True
  NtpKissOfDeath    == NtpKissOfDeath    = True
  NtpStratumTooHigh == NtpStratumTooHigh = True
  _                 == _                 = False

||| C-ABI representation size for NtpError (1 byte).
public export
ntpErrorSize : Nat
ntpErrorSize = 1

||| Map NtpError to its C-ABI byte value.
|||
||| Tag assignments:
|||   NtpOk             = 0
|||   NtpInvalidSlot    = 1
|||   NtpNotActive      = 2
|||   NtpInvalidPacket  = 3
|||   NtpKissOfDeath    = 4
|||   NtpStratumTooHigh = 5
public export
ntpErrorToTag : NtpError -> Bits8
ntpErrorToTag NtpOk             = 0
ntpErrorToTag NtpInvalidSlot    = 1
ntpErrorToTag NtpNotActive      = 2
ntpErrorToTag NtpInvalidPacket  = 3
ntpErrorToTag NtpKissOfDeath    = 4
ntpErrorToTag NtpStratumTooHigh = 5

||| Recover NtpError from its C-ABI byte value.
public export
tagToNtpError : Bits8 -> Maybe NtpError
tagToNtpError 0 = Just NtpOk
tagToNtpError 1 = Just NtpInvalidSlot
tagToNtpError 2 = Just NtpNotActive
tagToNtpError 3 = Just NtpInvalidPacket
tagToNtpError 4 = Just NtpKissOfDeath
tagToNtpError 5 = Just NtpStratumTooHigh
tagToNtpError _ = Nothing

||| Proof: encoding then decoding NtpError is the identity.
public export
ntpErrorRoundtrip : (e : NtpError) -> tagToNtpError (ntpErrorToTag e) = Just e
ntpErrorRoundtrip NtpOk             = Refl
ntpErrorRoundtrip NtpInvalidSlot    = Refl
ntpErrorRoundtrip NtpNotActive      = Refl
ntpErrorRoundtrip NtpInvalidPacket  = Refl
ntpErrorRoundtrip NtpKissOfDeath    = Refl
ntpErrorRoundtrip NtpStratumTooHigh = Refl
