(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Sandbox/isolation bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-sandbox/ffi/zig/src/sandbox.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for execution policies, resource limits,
    sandbox states, exit reasons, and syscall policies. *)

(** Execution policies matching [ExecutionPolicy] in sandbox.zig. *)
type execution_policy =
  | Unrestricted | Read_only | Network_denied | Isolated | Ephemeral

(** Resource limit types matching [ResourceLimit] in sandbox.zig. *)
type resource_limit =
  | Cpu_time | Memory | Disk_io | Network_io | File_descriptors | Processes

(** Sandbox lifecycle states matching [SandboxState] in sandbox.zig. *)
type sandbox_state =
  | Creating | Ready | Running | Suspended | Terminated | Destroyed

(** Exit reasons matching [ExitReason] in sandbox.zig. *)
type exit_reason =
  | Normal | Timeout | Memory_exceeded | Policy_violation | Killed | Error

(** Syscall filter policies matching [SyscallPolicy] in sandbox.zig. *)
type syscall_policy = Allow | Deny | Log | Trap

(** Convert an execution policy to its ABI tag value. *)
let execution_policy_to_tag = function
  | Unrestricted -> 0 | Read_only -> 1 | Network_denied -> 2
  | Isolated -> 3 | Ephemeral -> 4

(** Decode an execution policy from its ABI tag value. *)
let execution_policy_of_tag = function
  | 0 -> Some Unrestricted | 1 -> Some Read_only | 2 -> Some Network_denied
  | 3 -> Some Isolated | 4 -> Some Ephemeral | _ -> None

(** Convert a resource limit to its ABI tag value. *)
let resource_limit_to_tag = function
  | Cpu_time -> 0 | Memory -> 1 | Disk_io -> 2
  | Network_io -> 3 | File_descriptors -> 4 | Processes -> 5

(** Decode a resource limit from its ABI tag value. *)
let resource_limit_of_tag = function
  | 0 -> Some Cpu_time | 1 -> Some Memory | 2 -> Some Disk_io
  | 3 -> Some Network_io | 4 -> Some File_descriptors
  | 5 -> Some Processes | _ -> None

(** Convert a sandbox state to its ABI tag value. *)
let sandbox_state_to_tag = function
  | Creating -> 0 | Ready -> 1 | Running -> 2
  | Suspended -> 3 | Terminated -> 4 | Destroyed -> 5

(** Decode a sandbox state from its ABI tag value. *)
let sandbox_state_of_tag = function
  | 0 -> Some Creating | 1 -> Some Ready | 2 -> Some Running
  | 3 -> Some Suspended | 4 -> Some Terminated | 5 -> Some Destroyed | _ -> None

(** Convert an exit reason to its ABI tag value. *)
let exit_reason_to_tag = function
  | Normal -> 0 | Timeout -> 1 | Memory_exceeded -> 2
  | Policy_violation -> 3 | Killed -> 4 | Error -> 5

(** Decode an exit reason from its ABI tag value. *)
let exit_reason_of_tag = function
  | 0 -> Some Normal | 1 -> Some Timeout | 2 -> Some Memory_exceeded
  | 3 -> Some Policy_violation | 4 -> Some Killed | 5 -> Some Error | _ -> None

(** Convert a syscall policy to its ABI tag value. *)
let syscall_policy_to_tag = function
  | Allow -> 0 | Deny -> 1 | Log -> 2 | Trap -> 3

(** Decode a syscall policy from its ABI tag value. *)
let syscall_policy_of_tag = function
  | 0 -> Some Allow | 1 -> Some Deny | 2 -> Some Log
  | 3 -> Some Trap | _ -> None

(* --- C FFI declarations --- *)

external c_sandbox_abi_version : unit -> int = "sandbox_abi_version"
external c_sandbox_create_context : unit -> int = "sandbox_create_context"
external c_sandbox_destroy_context : int -> unit = "sandbox_destroy_context"
external c_sandbox_can_transition : int -> int -> int = "sandbox_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_sandbox]. *)
let abi_version () = c_sandbox_abi_version ()

(** Create a new sandbox context. *)
let create_context () =
  Proven_error.from_slot (c_sandbox_create_context ())

(** Destroy a sandbox context, releasing its slot. *)
let destroy_context slot = c_sandbox_destroy_context slot

(** Stateless query: check whether a sandbox state transition is valid. *)
let can_transition ~from ~to_ =
  c_sandbox_can_transition (sandbox_state_to_tag from) (sandbox_state_to_tag to_) = 1
