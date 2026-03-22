(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** NTP (Network Time Protocol) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ntp/ffi/zig/src/ntp.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for leap indicators, NTP modes, exchange
    states, clock discipline states, kiss codes, and errors. *)

(** Leap indicator matching [LeapIndicator] in ntp.zig. *)
type leap_indicator =
  | NoWarning | LastMinute61 | LastMinute59 | Unsynchronised

(** NTP mode matching [NtpMode] in ntp.zig. *)
type ntp_mode =
  | Reserved | SymmetricActive | SymmetricPassive | Client | Server
  | Broadcast | ControlMessage | Private

(** Exchange states matching [ExchangeState] in ntp.zig. *)
type exchange_state =
  | Idle | RequestReceived | TimestampCalculated | ResponseSent

(** Clock discipline states matching [ClockDisciplineState] in ntp.zig. *)
type clock_discipline_state =
  | Unset | Spike | Freq | Sync | Panic

(** Kiss-o'-death codes matching [KissCode] in ntp.zig. *)
type kiss_code =
  | Deny | Rstr | Rate | Other

(** NTP errors matching [NtpError] in ntp.zig. *)
type ntp_error =
  | Ok | InvalidSlot | NotActive | InvalidPacket
  | KissOfDeath | StratumTooHigh

(** Convert a leap indicator to its ABI tag value. *)
let leap_indicator_to_tag = function
  | NoWarning -> 0 | LastMinute61 -> 1 | LastMinute59 -> 2
  | Unsynchronised -> 3

(** Decode a leap indicator from its ABI tag value. *)
let leap_indicator_of_tag = function
  | 0 -> Some NoWarning | 1 -> Some LastMinute61 | 2 -> Some LastMinute59
  | 3 -> Some Unsynchronised | _ -> None

(** Convert an NTP mode to its ABI tag value. *)
let ntp_mode_to_tag = function
  | Reserved -> 0 | SymmetricActive -> 1 | SymmetricPassive -> 2
  | Client -> 3 | Server -> 4 | Broadcast -> 5 | ControlMessage -> 6
  | Private -> 7

(** Decode an NTP mode from its ABI tag value. *)
let ntp_mode_of_tag = function
  | 0 -> Some Reserved | 1 -> Some SymmetricActive
  | 2 -> Some SymmetricPassive | 3 -> Some Client | 4 -> Some Server
  | 5 -> Some Broadcast | 6 -> Some ControlMessage | 7 -> Some Private
  | _ -> None

(** Convert an exchange state to its ABI tag value. *)
let exchange_state_to_tag = function
  | Idle -> 0 | RequestReceived -> 1 | TimestampCalculated -> 2
  | ResponseSent -> 3

(** Decode an exchange state from its ABI tag value. *)
let exchange_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some RequestReceived
  | 2 -> Some TimestampCalculated | 3 -> Some ResponseSent | _ -> None

(** Convert a clock discipline state to its ABI tag value. *)
let clock_discipline_state_to_tag = function
  | Unset -> 0 | Spike -> 1 | Freq -> 2 | Sync -> 3 | Panic -> 4

(** Decode a clock discipline state from its ABI tag value. *)
let clock_discipline_state_of_tag = function
  | 0 -> Some Unset | 1 -> Some Spike | 2 -> Some Freq
  | 3 -> Some Sync | 4 -> Some Panic | _ -> None

(** Convert a kiss code to its ABI tag value. *)
let kiss_code_to_tag = function
  | Deny -> 0 | Rstr -> 1 | Rate -> 2 | Other -> 3

(** Decode a kiss code from its ABI tag value. *)
let kiss_code_of_tag = function
  | 0 -> Some Deny | 1 -> Some Rstr | 2 -> Some Rate
  | 3 -> Some Other | _ -> None

(** Convert an NTP error to its ABI tag value. *)
let ntp_error_to_tag = function
  | Ok -> 0 | InvalidSlot -> 1 | NotActive -> 2 | InvalidPacket -> 3
  | KissOfDeath -> 4 | StratumTooHigh -> 5

(** Decode an NTP error from its ABI tag value. *)
let ntp_error_of_tag = function
  | 0 -> Some Ok | 1 -> Some InvalidSlot | 2 -> Some NotActive
  | 3 -> Some InvalidPacket | 4 -> Some KissOfDeath
  | 5 -> Some StratumTooHigh | _ -> None

(* --- C FFI declarations --- *)

external c_ntp_abi_version : unit -> int = "ntp_abi_version"
external c_ntp_create_context : unit -> int = "ntp_create_context"
external c_ntp_destroy_context : int -> unit = "ntp_destroy_context"
external c_ntp_can_transition : int -> int -> int = "ntp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ntp]. *)
let abi_version () = c_ntp_abi_version ()

(** Create a new NTP context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_ntp_create_context ())

(** Destroy an NTP context, releasing its slot. *)
let destroy_context slot = c_ntp_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_ntp_can_transition (exchange_state_to_tag from) (exchange_state_to_tag to_) = 1
