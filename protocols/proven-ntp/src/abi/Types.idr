-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NtpABI.Types: C-ABI-compatible numeric representations of Ntp types.
--
-- Maps every constructor of the core Ntp sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/ntp.zig) exactly.
--
-- Types covered:
--   LeapIndicator             (4 constructors, tags 0-3)
--   NTPMode                   (8 constructors, tags 0-7)
--   ExchangeState             (4 constructors, tags 0-3)
--   ClockDisciplineState      (5 constructors, tags 0-4)
--   KissCode                  (4 constructors, tags 0-3)
--   NtpError                  (6 constructors, tags 0-5)

module NtpABI.Types

%default total

---------------------------------------------------------------------------
-- LeapIndicator (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
leap_indicatorSize : Nat
leap_indicatorSize = 1

||| LeapIndicator sum type for ABI encoding.
public export
data LeapIndicator : Type where
  NoWarning : LeapIndicator
  LastMinute61 : LeapIndicator
  LastMinute59 : LeapIndicator
  Unsynchronised : LeapIndicator

||| Encode a LeapIndicator to its ABI tag value.
public export
leap_indicatorToTag : LeapIndicator -> Bits8
leap_indicatorToTag NoWarning = 0
leap_indicatorToTag LastMinute61 = 1
leap_indicatorToTag LastMinute59 = 2
leap_indicatorToTag Unsynchronised = 3

||| Decode an ABI tag to a LeapIndicator.
public export
tagToLeapIndicator : Bits8 -> Maybe LeapIndicator
tagToLeapIndicator 0 = Just NoWarning
tagToLeapIndicator 1 = Just LastMinute61
tagToLeapIndicator 2 = Just LastMinute59
tagToLeapIndicator 3 = Just Unsynchronised
tagToLeapIndicator _ = Nothing

||| Roundtrip proof: decoding an encoded LeapIndicator yields the original.
public export
leap_indicatorRoundtrip : (x : LeapIndicator) -> tagToLeapIndicator (leap_indicatorToTag x) = Just x
leap_indicatorRoundtrip NoWarning = Refl
leap_indicatorRoundtrip LastMinute61 = Refl
leap_indicatorRoundtrip LastMinute59 = Refl
leap_indicatorRoundtrip Unsynchronised = Refl

---------------------------------------------------------------------------
-- NTPMode (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
n_t_p_modeSize : Nat
n_t_p_modeSize = 1

||| NTPMode sum type for ABI encoding.
public export
data NTPMode : Type where
  Reserved : NTPMode
  SymmetricActive : NTPMode
  SymmetricPassive : NTPMode
  Client : NTPMode
  Server : NTPMode
  Broadcast : NTPMode
  ControlMessage : NTPMode
  Private : NTPMode

||| Encode a NTPMode to its ABI tag value.
public export
n_t_p_modeToTag : NTPMode -> Bits8
n_t_p_modeToTag Reserved = 0
n_t_p_modeToTag SymmetricActive = 1
n_t_p_modeToTag SymmetricPassive = 2
n_t_p_modeToTag Client = 3
n_t_p_modeToTag Server = 4
n_t_p_modeToTag Broadcast = 5
n_t_p_modeToTag ControlMessage = 6
n_t_p_modeToTag Private = 7

||| Decode an ABI tag to a NTPMode.
public export
tagToNTPMode : Bits8 -> Maybe NTPMode
tagToNTPMode 0 = Just Reserved
tagToNTPMode 1 = Just SymmetricActive
tagToNTPMode 2 = Just SymmetricPassive
tagToNTPMode 3 = Just Client
tagToNTPMode 4 = Just Server
tagToNTPMode 5 = Just Broadcast
tagToNTPMode 6 = Just ControlMessage
tagToNTPMode 7 = Just Private
tagToNTPMode _ = Nothing

||| Roundtrip proof: decoding an encoded NTPMode yields the original.
public export
n_t_p_modeRoundtrip : (x : NTPMode) -> tagToNTPMode (n_t_p_modeToTag x) = Just x
n_t_p_modeRoundtrip Reserved = Refl
n_t_p_modeRoundtrip SymmetricActive = Refl
n_t_p_modeRoundtrip SymmetricPassive = Refl
n_t_p_modeRoundtrip Client = Refl
n_t_p_modeRoundtrip Server = Refl
n_t_p_modeRoundtrip Broadcast = Refl
n_t_p_modeRoundtrip ControlMessage = Refl
n_t_p_modeRoundtrip Private = Refl

---------------------------------------------------------------------------
-- ExchangeState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
exchange_stateSize : Nat
exchange_stateSize = 1

||| ExchangeState sum type for ABI encoding.
public export
data ExchangeState : Type where
  Idle : ExchangeState
  RequestReceived : ExchangeState
  TimestampCalculated : ExchangeState
  ResponseSent : ExchangeState

||| Encode a ExchangeState to its ABI tag value.
public export
exchange_stateToTag : ExchangeState -> Bits8
exchange_stateToTag Idle = 0
exchange_stateToTag RequestReceived = 1
exchange_stateToTag TimestampCalculated = 2
exchange_stateToTag ResponseSent = 3

||| Decode an ABI tag to a ExchangeState.
public export
tagToExchangeState : Bits8 -> Maybe ExchangeState
tagToExchangeState 0 = Just Idle
tagToExchangeState 1 = Just RequestReceived
tagToExchangeState 2 = Just TimestampCalculated
tagToExchangeState 3 = Just ResponseSent
tagToExchangeState _ = Nothing

||| Roundtrip proof: decoding an encoded ExchangeState yields the original.
public export
exchange_stateRoundtrip : (x : ExchangeState) -> tagToExchangeState (exchange_stateToTag x) = Just x
exchange_stateRoundtrip Idle = Refl
exchange_stateRoundtrip RequestReceived = Refl
exchange_stateRoundtrip TimestampCalculated = Refl
exchange_stateRoundtrip ResponseSent = Refl

---------------------------------------------------------------------------
-- ClockDisciplineState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
clock_discipline_stateSize : Nat
clock_discipline_stateSize = 1

||| ClockDisciplineState sum type for ABI encoding.
public export
data ClockDisciplineState : Type where
  Unset : ClockDisciplineState
  Spike : ClockDisciplineState
  Freq : ClockDisciplineState
  Sync : ClockDisciplineState
  Panic : ClockDisciplineState

||| Encode a ClockDisciplineState to its ABI tag value.
public export
clock_discipline_stateToTag : ClockDisciplineState -> Bits8
clock_discipline_stateToTag Unset = 0
clock_discipline_stateToTag Spike = 1
clock_discipline_stateToTag Freq = 2
clock_discipline_stateToTag Sync = 3
clock_discipline_stateToTag Panic = 4

||| Decode an ABI tag to a ClockDisciplineState.
public export
tagToClockDisciplineState : Bits8 -> Maybe ClockDisciplineState
tagToClockDisciplineState 0 = Just Unset
tagToClockDisciplineState 1 = Just Spike
tagToClockDisciplineState 2 = Just Freq
tagToClockDisciplineState 3 = Just Sync
tagToClockDisciplineState 4 = Just Panic
tagToClockDisciplineState _ = Nothing

||| Roundtrip proof: decoding an encoded ClockDisciplineState yields the original.
public export
clock_discipline_stateRoundtrip : (x : ClockDisciplineState) -> tagToClockDisciplineState (clock_discipline_stateToTag x) = Just x
clock_discipline_stateRoundtrip Unset = Refl
clock_discipline_stateRoundtrip Spike = Refl
clock_discipline_stateRoundtrip Freq = Refl
clock_discipline_stateRoundtrip Sync = Refl
clock_discipline_stateRoundtrip Panic = Refl

---------------------------------------------------------------------------
-- KissCode (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
kiss_codeSize : Nat
kiss_codeSize = 1

||| KissCode sum type for ABI encoding.
public export
data KissCode : Type where
  Deny : KissCode
  Rstr : KissCode
  Rate : KissCode
  Other : KissCode

||| Encode a KissCode to its ABI tag value.
public export
kiss_codeToTag : KissCode -> Bits8
kiss_codeToTag Deny = 0
kiss_codeToTag Rstr = 1
kiss_codeToTag Rate = 2
kiss_codeToTag Other = 3

||| Decode an ABI tag to a KissCode.
public export
tagToKissCode : Bits8 -> Maybe KissCode
tagToKissCode 0 = Just Deny
tagToKissCode 1 = Just Rstr
tagToKissCode 2 = Just Rate
tagToKissCode 3 = Just Other
tagToKissCode _ = Nothing

||| Roundtrip proof: decoding an encoded KissCode yields the original.
public export
kiss_codeRoundtrip : (x : KissCode) -> tagToKissCode (kiss_codeToTag x) = Just x
kiss_codeRoundtrip Deny = Refl
kiss_codeRoundtrip Rstr = Refl
kiss_codeRoundtrip Rate = Refl
kiss_codeRoundtrip Other = Refl

---------------------------------------------------------------------------
-- NtpError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
ntp_errorSize : Nat
ntp_errorSize = 1

||| NtpError sum type for ABI encoding.
public export
data NtpError : Type where
  Ok : NtpError
  InvalidSlot : NtpError
  NotActive : NtpError
  InvalidPacket : NtpError
  KissOfDeath : NtpError
  StratumTooHigh : NtpError

||| Encode a NtpError to its ABI tag value.
public export
ntp_errorToTag : NtpError -> Bits8
ntp_errorToTag Ok = 0
ntp_errorToTag InvalidSlot = 1
ntp_errorToTag NotActive = 2
ntp_errorToTag InvalidPacket = 3
ntp_errorToTag KissOfDeath = 4
ntp_errorToTag StratumTooHigh = 5

||| Decode an ABI tag to a NtpError.
public export
tagToNtpError : Bits8 -> Maybe NtpError
tagToNtpError 0 = Just Ok
tagToNtpError 1 = Just InvalidSlot
tagToNtpError 2 = Just NotActive
tagToNtpError 3 = Just InvalidPacket
tagToNtpError 4 = Just KissOfDeath
tagToNtpError 5 = Just StratumTooHigh
tagToNtpError _ = Nothing

||| Roundtrip proof: decoding an encoded NtpError yields the original.
public export
ntp_errorRoundtrip : (x : NtpError) -> tagToNtpError (ntp_errorToTag x) = Just x
ntp_errorRoundtrip Ok = Refl
ntp_errorRoundtrip InvalidSlot = Refl
ntp_errorRoundtrip NotActive = Refl
ntp_errorRoundtrip InvalidPacket = Refl
ntp_errorRoundtrip KissOfDeath = Refl
ntp_errorRoundtrip StratumTooHigh = Refl
