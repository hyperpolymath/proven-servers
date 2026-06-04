-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- POP3ABI.Types: C-ABI-compatible numeric representations of POP3 types.
--
-- Maps every constructor of the POP3 domain types (Command, State, Response)
-- to fixed Bits8 values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/pop3.zig) exactly.

module POP3ABI.Types

import POP3.Types

%default total

---------------------------------------------------------------------------
-- Command (11 constructors, tags 0-10)
---------------------------------------------------------------------------

||| C-ABI representation size for Command (1 byte).
public export
commandSize : Nat
commandSize = 1

||| Map Command to its C-ABI byte value.
|||
||| Tag assignments:
|||   User = 0    Pass = 1    Stat = 2    List = 3    Retr = 4
|||   Dele = 5    Noop = 6    Rset = 7    Quit = 8    Top  = 9
|||   Uidl = 10
public export
commandToTag : Command -> Bits8
commandToTag User = 0
commandToTag Pass = 1
commandToTag Stat = 2
commandToTag List = 3
commandToTag Retr = 4
commandToTag Dele = 5
commandToTag Noop = 6
commandToTag Rset = 7
commandToTag Quit = 8
commandToTag Top  = 9
commandToTag Uidl = 10

||| Recover Command from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-10.
public export
tagToCommand : Bits8 -> Maybe Command
tagToCommand 0  = Just User
tagToCommand 1  = Just Pass
tagToCommand 2  = Just Stat
tagToCommand 3  = Just List
tagToCommand 4  = Just Retr
tagToCommand 5  = Just Dele
tagToCommand 6  = Just Noop
tagToCommand 7  = Just Rset
tagToCommand 8  = Just Quit
tagToCommand 9  = Just Top
tagToCommand 10 = Just Uidl
tagToCommand _  = Nothing

||| Proof: encoding then decoding Command is the identity.
public export
commandRoundtrip : (c : Command) -> tagToCommand (commandToTag c) = Just c
commandRoundtrip User = Refl
commandRoundtrip Pass = Refl
commandRoundtrip Stat = Refl
commandRoundtrip List = Refl
commandRoundtrip Retr = Refl
commandRoundtrip Dele = Refl
commandRoundtrip Noop = Refl
commandRoundtrip Rset = Refl
commandRoundtrip Quit = Refl
commandRoundtrip Top  = Refl
commandRoundtrip Uidl = Refl

---------------------------------------------------------------------------
-- State (3 constructors, tags 0-2)
---------------------------------------------------------------------------

||| C-ABI representation size for State (1 byte).
public export
stateSize : Nat
stateSize = 1

||| Map State to its C-ABI byte value.
|||
||| Tag assignments:
|||   Authorization = 0
|||   Transaction   = 1
|||   Update        = 2
public export
stateToTag : State -> Bits8
stateToTag Authorization = 0
stateToTag Transaction   = 1
stateToTag Update        = 2

||| Recover State from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-2.
public export
tagToState : Bits8 -> Maybe State
tagToState 0 = Just Authorization
tagToState 1 = Just Transaction
tagToState 2 = Just Update
tagToState _ = Nothing

||| Proof: encoding then decoding State is the identity.
public export
stateRoundtrip : (s : State) -> tagToState (stateToTag s) = Just s
stateRoundtrip Authorization = Refl
stateRoundtrip Transaction   = Refl
stateRoundtrip Update        = Refl

---------------------------------------------------------------------------
-- Response (2 constructors, tags 0-1)
---------------------------------------------------------------------------

||| C-ABI representation size for Response (1 byte).
public export
responseSize : Nat
responseSize = 1

||| Map Response to its C-ABI byte value.
|||
||| Tag assignments:
|||   Ok  = 0
|||   Err = 1
public export
responseToTag : Response -> Bits8
responseToTag Ok  = 0
responseToTag Err = 1

||| Recover Response from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-1.
public export
tagToResponse : Bits8 -> Maybe Response
tagToResponse 0 = Just Ok
tagToResponse 1 = Just Err
tagToResponse _ = Nothing

||| Proof: encoding then decoding Response is the identity.
public export
responseRoundtrip : (r : Response) -> tagToResponse (responseToTag r) = Just r
responseRoundtrip Ok  = Refl
responseRoundtrip Err = Refl

---------------------------------------------------------------------------
-- POP3Error (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| Error codes for POP3 FFI operations.
public export
data POP3Error : Type where
  ||| No error.
  Pop3Ok               : POP3Error
  ||| Invalid slot index.
  Pop3InvalidSlot      : POP3Error
  ||| Session not active.
  Pop3NotActive        : POP3Error
  ||| Invalid state transition.
  Pop3InvalidTransition : POP3Error
  ||| Command not allowed in current state.
  Pop3InvalidCommand   : POP3Error
  ||| Authentication failed.
  Pop3AuthFailed       : POP3Error

public export
Show POP3Error where
  show Pop3Ok                = "Ok"
  show Pop3InvalidSlot       = "InvalidSlot"
  show Pop3NotActive         = "NotActive"
  show Pop3InvalidTransition = "InvalidTransition"
  show Pop3InvalidCommand    = "InvalidCommand"
  show Pop3AuthFailed        = "AuthFailed"

||| C-ABI representation size for POP3Error (1 byte).
public export
pop3ErrorSize : Nat
pop3ErrorSize = 1

||| Map POP3Error to its C-ABI byte value.
public export
pop3ErrorToTag : POP3Error -> Bits8
pop3ErrorToTag Pop3Ok                = 0
pop3ErrorToTag Pop3InvalidSlot       = 1
pop3ErrorToTag Pop3NotActive         = 2
pop3ErrorToTag Pop3InvalidTransition = 3
pop3ErrorToTag Pop3InvalidCommand    = 4
pop3ErrorToTag Pop3AuthFailed        = 5

||| Recover POP3Error from its C-ABI byte value.
public export
tagToPOP3Error : Bits8 -> Maybe POP3Error
tagToPOP3Error 0 = Just Pop3Ok
tagToPOP3Error 1 = Just Pop3InvalidSlot
tagToPOP3Error 2 = Just Pop3NotActive
tagToPOP3Error 3 = Just Pop3InvalidTransition
tagToPOP3Error 4 = Just Pop3InvalidCommand
tagToPOP3Error 5 = Just Pop3AuthFailed
tagToPOP3Error _ = Nothing

||| Proof: encoding then decoding POP3Error is the identity.
public export
pop3ErrorRoundtrip : (e : POP3Error) -> tagToPOP3Error (pop3ErrorToTag e) = Just e
pop3ErrorRoundtrip Pop3Ok                = Refl
pop3ErrorRoundtrip Pop3InvalidSlot       = Refl
pop3ErrorRoundtrip Pop3NotActive         = Refl
pop3ErrorRoundtrip Pop3InvalidTransition = Refl
pop3ErrorRoundtrip Pop3InvalidCommand    = Refl
pop3ErrorRoundtrip Pop3AuthFailed        = Refl
