-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TelnetABI Types: C-ABI-compatible numeric representations of Telnet types.
--
-- Maps every constructor of the core Telnet sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/telnet.zig) exactly.
--
-- INSECURE PROTOCOL -- for legacy interoperability only.
--
-- Types covered:
--   Command          (16 constructors, tags 0-15)
--   Option           (10 constructors, tags 0-9)
--   NegotiationState (4 constructors, tags 0-3)
--   SessionState     (5 constructors, tags 0-4)

module TelnetABI.Types

import Telnet.Types

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
commandToTag SE               = 0
commandToTag NOP              = 1
commandToTag DataMark         = 2
commandToTag Break            = 3
commandToTag InterruptProcess = 4
commandToTag AbortOutput      = 5
commandToTag AreYouThere      = 6
commandToTag EraseChar        = 7
commandToTag EraseLine        = 8
commandToTag GoAhead          = 9
commandToTag SB               = 10
commandToTag Will             = 11
commandToTag Wont             = 12
commandToTag Do               = 13
commandToTag Dont             = 14
commandToTag IAC              = 15

||| Decode an ABI tag to a Command.
public export
tagToCommand : Bits8 -> Maybe Command
tagToCommand 0  = Just SE
tagToCommand 1  = Just NOP
tagToCommand 2  = Just DataMark
tagToCommand 3  = Just Break
tagToCommand 4  = Just InterruptProcess
tagToCommand 5  = Just AbortOutput
tagToCommand 6  = Just AreYouThere
tagToCommand 7  = Just EraseChar
tagToCommand 8  = Just EraseLine
tagToCommand 9  = Just GoAhead
tagToCommand 10 = Just SB
tagToCommand 11 = Just Will
tagToCommand 12 = Just Wont
tagToCommand 13 = Just Do
tagToCommand 14 = Just Dont
tagToCommand 15 = Just IAC
tagToCommand _  = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all Command values.
public export
commandRoundtrip : (c : Command) -> tagToCommand (commandToTag c) = Just c
commandRoundtrip SE               = Refl
commandRoundtrip NOP              = Refl
commandRoundtrip DataMark         = Refl
commandRoundtrip Break            = Refl
commandRoundtrip InterruptProcess = Refl
commandRoundtrip AbortOutput      = Refl
commandRoundtrip AreYouThere      = Refl
commandRoundtrip EraseChar        = Refl
commandRoundtrip EraseLine        = Refl
commandRoundtrip GoAhead          = Refl
commandRoundtrip SB               = Refl
commandRoundtrip Will             = Refl
commandRoundtrip Wont             = Refl
commandRoundtrip Do               = Refl
commandRoundtrip Dont             = Refl
commandRoundtrip IAC              = Refl

---------------------------------------------------------------------------
-- Option (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
optionSize : Nat
optionSize = 1

||| Encode an Option to its ABI tag value.
public export
optionToTag : Option -> Bits8
optionToTag Echo              = 0
optionToTag SuppressGoAhead   = 1
optionToTag Status            = 2
optionToTag TimingMark        = 3
optionToTag TerminalType      = 4
optionToTag WindowSize        = 5
optionToTag TerminalSpeed     = 6
optionToTag RemoteFlowControl = 7
optionToTag Linemode          = 8
optionToTag Environment       = 9

||| Decode an ABI tag to an Option.
public export
tagToOption : Bits8 -> Maybe Option
tagToOption 0 = Just Echo
tagToOption 1 = Just SuppressGoAhead
tagToOption 2 = Just Status
tagToOption 3 = Just TimingMark
tagToOption 4 = Just TerminalType
tagToOption 5 = Just WindowSize
tagToOption 6 = Just TerminalSpeed
tagToOption 7 = Just RemoteFlowControl
tagToOption 8 = Just Linemode
tagToOption 9 = Just Environment
tagToOption _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all Option values.
public export
optionRoundtrip : (o : Option) -> tagToOption (optionToTag o) = Just o
optionRoundtrip Echo              = Refl
optionRoundtrip SuppressGoAhead   = Refl
optionRoundtrip Status            = Refl
optionRoundtrip TimingMark        = Refl
optionRoundtrip TerminalType      = Refl
optionRoundtrip WindowSize        = Refl
optionRoundtrip TerminalSpeed     = Refl
optionRoundtrip RemoteFlowControl = Refl
optionRoundtrip Linemode          = Refl
optionRoundtrip Environment       = Refl

---------------------------------------------------------------------------
-- NegotiationState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
negotiationStateSize : Nat
negotiationStateSize = 1

||| Encode a NegotiationState to its ABI tag value.
public export
negotiationStateToTag : NegotiationState -> Bits8
negotiationStateToTag Inactive = 0
negotiationStateToTag WillSent = 1
negotiationStateToTag DoSent   = 2
negotiationStateToTag Active   = 3

||| Decode an ABI tag to a NegotiationState.
public export
tagToNegotiationState : Bits8 -> Maybe NegotiationState
tagToNegotiationState 0 = Just Inactive
tagToNegotiationState 1 = Just WillSent
tagToNegotiationState 2 = Just DoSent
tagToNegotiationState 3 = Just Active
tagToNegotiationState _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all NegotiationState values.
public export
negotiationStateRoundtrip : (n : NegotiationState) -> tagToNegotiationState (negotiationStateToTag n) = Just n
negotiationStateRoundtrip Inactive = Refl
negotiationStateRoundtrip WillSent = Refl
negotiationStateRoundtrip DoSent   = Refl
negotiationStateRoundtrip Active   = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| Telnet session lifecycle states for FFI management.
||| INSECURE PROTOCOL -- for legacy interoperability only.
public export
data SessionState : Type where
  ||| No connection. Initial and terminal state.
  SSIdle        : SessionState
  ||| Connection established, negotiation in progress.
  SSNegotiating : SessionState
  ||| Negotiation complete, data transfer active.
  SSActive      : SessionState
  ||| Subnegotiation in progress.
  SSSubneg      : SessionState
  ||| Connection closing.
  SSClosing     : SessionState

public export
Eq SessionState where
  SSIdle        == SSIdle        = True
  SSNegotiating == SSNegotiating = True
  SSActive      == SSActive      = True
  SSSubneg      == SSSubneg      = True
  SSClosing     == SSClosing     = True
  _             == _             = False

public export
Show SessionState where
  show SSIdle        = "Idle"
  show SSNegotiating = "Negotiating"
  show SSActive      = "Active"
  show SSSubneg      = "Subnegotiation"
  show SSClosing     = "Closing"

public export
sessionStateSize : Nat
sessionStateSize = 1

||| Encode a SessionState to its ABI tag value.
public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle        = 0
sessionStateToTag SSNegotiating = 1
sessionStateToTag SSActive      = 2
sessionStateToTag SSSubneg      = 3
sessionStateToTag SSClosing     = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSNegotiating
tagToSessionState 2 = Just SSActive
tagToSessionState 3 = Just SSSubneg
tagToSessionState 4 = Just SSClosing
tagToSessionState _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all SessionState values.
public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle        = Refl
sessionStateRoundtrip SSNegotiating = Refl
sessionStateRoundtrip SSActive      = Refl
sessionStateRoundtrip SSSubneg      = Refl
sessionStateRoundtrip SSClosing     = Refl
