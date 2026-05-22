(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Agentic AI protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-agentic/ffi/zig/src/agentic.zig]. *)

(** AgentState matching [AgentState] in agentic.zig. *)
type agent_state =
  | Idle  (** Idle (tag 0). *)
  | Planning  (** Planning (tag 1). *)
  | Acting  (** Acting (tag 2). *)
  | Observing  (** Observing (tag 3). *)
  | Reflecting  (** Reflecting (tag 4). *)
  | Blocked  (** Blocked (tag 5). *)
  | Terminated  (** Terminated (tag 6). *)

let agent_state_to_tag = function
  | Idle -> 0 | Planning -> 1 | Acting -> 2 | Observing -> 3
  | Reflecting -> 4 | Blocked -> 5 | Terminated -> 6

let agent_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Planning | 2 -> Some Acting
  | 3 -> Some Observing | 4 -> Some Reflecting | 5 -> Some Blocked
  | 6 -> Some Terminated | _ -> None

(** ToolCall matching [ToolCall] in agentic.zig. *)
type tool_call =
  | Execute  (** Execute (tag 0). *)
  | Query  (** Query (tag 1). *)
  | Transform  (** Transform (tag 2). *)
  | Communicate  (** Communicate (tag 3). *)
  | Delegate  (** Delegate (tag 4). *)
  | Escalate  (** Escalate (tag 5). *)

let tool_call_to_tag = function
  | Execute -> 0 | Query -> 1 | Transform -> 2 | Communicate -> 3
  | Delegate -> 4 | Escalate -> 5

let tool_call_of_tag = function
  | 0 -> Some Execute | 1 -> Some Query | 2 -> Some Transform
  | 3 -> Some Communicate | 4 -> Some Delegate | 5 -> Some Escalate
  | _ -> None

(** PlanStep matching [PlanStep] in agentic.zig. *)
type plan_step =
  | Action  (** Action (tag 0). *)
  | Condition  (** Condition (tag 1). *)
  | Loop  (** Loop (tag 2). *)
  | Branch  (** Branch (tag 3). *)
  | Parallel  (** Parallel (tag 4). *)
  | Checkpoint  (** Checkpoint (tag 5). *)
  | Rollback  (** Rollback (tag 6). *)

let plan_step_to_tag = function
  | Action -> 0 | Condition -> 1 | Loop -> 2 | Branch -> 3
  | Parallel -> 4 | Checkpoint -> 5 | Rollback -> 6

let plan_step_of_tag = function
  | 0 -> Some Action | 1 -> Some Condition | 2 -> Some Loop
  | 3 -> Some Branch | 4 -> Some Parallel | 5 -> Some Checkpoint
  | 6 -> Some Rollback | _ -> None

(** Coordination matching [Coordination] in agentic.zig. *)
type coordination =
  | Solo  (** Solo (tag 0). *)
  | Collaborative  (** Collaborative (tag 1). *)
  | Competitive  (** Competitive (tag 2). *)
  | Hierarchical  (** Hierarchical (tag 3). *)
  | Swarm  (** Swarm (tag 4). *)
  | Consensus  (** Consensus (tag 5). *)

let coordination_to_tag = function
  | Solo -> 0 | Collaborative -> 1 | Competitive -> 2
  | Hierarchical -> 3 | Swarm -> 4 | Consensus -> 5

let coordination_of_tag = function
  | 0 -> Some Solo | 1 -> Some Collaborative | 2 -> Some Competitive
  | 3 -> Some Hierarchical | 4 -> Some Swarm | 5 -> Some Consensus
  | _ -> None

(** SafetyCheck matching [SafetyCheck] in agentic.zig. *)
type safety_check =
  | Approved  (** Approved (tag 0). *)
  | Denied  (** Denied (tag 1). *)
  | Escalated  (** Escalated (tag 2). *)
  | Timeout  (** Timeout (tag 3). *)
  | Sandboxed  (** Sandboxed (tag 4). *)
  | HumanRequired  (** HumanRequired (tag 5). *)

let safety_check_to_tag = function
  | Approved -> 0 | Denied -> 1 | Escalated -> 2 | Timeout -> 3
  | Sandboxed -> 4 | HumanRequired -> 5

let safety_check_of_tag = function
  | 0 -> Some Approved | 1 -> Some Denied | 2 -> Some Escalated
  | 3 -> Some Timeout | 4 -> Some Sandboxed | 5 -> Some HumanRequired
  | _ -> None

(* --- C FFI declarations --- *)

external c_agentic_abi_version : unit -> int = "agentic_abi_version"
external c_agentic_create_context : unit -> int = "agentic_create_context"
external c_agentic_destroy_context : int -> unit = "agentic_destroy_context"
external c_agentic_state : int -> int = "agentic_state"
external c_agentic_can_transition : int -> int -> int = "agentic_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_agentic_abi_version ()

let create_context () = Proven_error.from_slot (c_agentic_create_context ())

let destroy_context slot = c_agentic_destroy_context slot

let get_state slot = agent_state_of_tag (c_agentic_state slot)

let can_transition ~from ~to_ =
  c_agentic_can_transition (agent_state_to_tag from) (agent_state_to_tag to_) = 1
