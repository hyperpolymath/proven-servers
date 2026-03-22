(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Hardened server protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-hardened/ffi/zig/src/hardened.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for hardening levels, security controls,
    compliance standards, and server states. *)

(** Hardening levels matching [HardeningLevel] in hardened.zig. *)
type hardening_level =
  | Minimal | Standard | High | Maximum

(** Security controls matching [SecurityControl] in hardened.zig. *)
type security_control =
  | Aslr | Dep | StackCanary | Cfi | Sandboxing | SecureBoot | AuditLog

(** Compliance standards matching [ComplianceStandard] in hardened.zig. *)
type compliance_standard =
  | Cis | Stig | Nist80053 | PciDss | Fips140

(** Audit events matching [AuditEvent] in hardened.zig. *)
type audit_event =
  | ProcessStart | FileAccess | NetworkConn | PrivilegeEscalation
  | ConfigChange | AuthAttempt

(** Health statuses matching [HardenedHealthStatus] in hardened.zig. *)
type health_status =
  | Healthy | Degraded | Compromised | Unresponsive

(** Server lifecycle states matching [ServerState] in hardened.zig. *)
type server_state =
  | Idle | Hardening | Active | Auditing | Shutdown

(** Convert a hardening level to its ABI tag value. *)
let hardening_level_to_tag = function
  | Minimal -> 0 | Standard -> 1 | High -> 2 | Maximum -> 3

(** Decode a hardening level from its ABI tag value. *)
let hardening_level_of_tag = function
  | 0 -> Some Minimal | 1 -> Some Standard | 2 -> Some High
  | 3 -> Some Maximum | _ -> None

(** Convert a security control to its ABI tag value. *)
let security_control_to_tag = function
  | Aslr -> 0 | Dep -> 1 | StackCanary -> 2 | Cfi -> 3
  | Sandboxing -> 4 | SecureBoot -> 5 | AuditLog -> 6

(** Decode a security control from its ABI tag value. *)
let security_control_of_tag = function
  | 0 -> Some Aslr | 1 -> Some Dep | 2 -> Some StackCanary | 3 -> Some Cfi
  | 4 -> Some Sandboxing | 5 -> Some SecureBoot | 6 -> Some AuditLog
  | _ -> None

(** Convert a compliance standard to its ABI tag value. *)
let compliance_standard_to_tag = function
  | Cis -> 0 | Stig -> 1 | Nist80053 -> 2 | PciDss -> 3 | Fips140 -> 4

(** Decode a compliance standard from its ABI tag value. *)
let compliance_standard_of_tag = function
  | 0 -> Some Cis | 1 -> Some Stig | 2 -> Some Nist80053
  | 3 -> Some PciDss | 4 -> Some Fips140 | _ -> None

(** Convert an audit event to its ABI tag value. *)
let audit_event_to_tag = function
  | ProcessStart -> 0 | FileAccess -> 1 | NetworkConn -> 2
  | PrivilegeEscalation -> 3 | ConfigChange -> 4 | AuthAttempt -> 5

(** Decode an audit event from its ABI tag value. *)
let audit_event_of_tag = function
  | 0 -> Some ProcessStart | 1 -> Some FileAccess | 2 -> Some NetworkConn
  | 3 -> Some PrivilegeEscalation | 4 -> Some ConfigChange
  | 5 -> Some AuthAttempt | _ -> None

(** Convert a health status to its ABI tag value. *)
let health_status_to_tag = function
  | Healthy -> 0 | Degraded -> 1 | Compromised -> 2 | Unresponsive -> 3

(** Decode a health status from its ABI tag value. *)
let health_status_of_tag = function
  | 0 -> Some Healthy | 1 -> Some Degraded | 2 -> Some Compromised
  | 3 -> Some Unresponsive | _ -> None

(** Convert a server state to its ABI tag value. *)
let server_state_to_tag = function
  | Idle -> 0 | Hardening -> 1 | Active -> 2 | Auditing -> 3 | Shutdown -> 4

(** Decode a server state from its ABI tag value. *)
let server_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Hardening | 2 -> Some Active
  | 3 -> Some Auditing | 4 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_hardened_abi_version : unit -> int = "hardened_abi_version"
external c_hardened_create_context : unit -> int = "hardened_create_context"
external c_hardened_destroy_context : int -> unit = "hardened_destroy_context"
external c_hardened_can_transition : int -> int -> int = "hardened_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_hardened]. *)
let abi_version () = c_hardened_abi_version ()

(** Create a new hardened server context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_hardened_create_context ())

(** Destroy a hardened server context, releasing its slot. *)
let destroy_context slot = c_hardened_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_hardened_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
