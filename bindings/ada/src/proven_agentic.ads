-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-agentic protocol (Agentic AI orchestration).
--
-- Wraps the C-ABI functions from protocols/proven-agentic/ffi/zig/src/agentic.zig:
--   agentic_abi_version, agentic_create_context, agentic_destroy_context,
--   agentic_state, agentic_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Agentic is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `AgentState` in `AgenticABI.Types`.
   type Agent_State is
     (Idle,
      Planning,
      Acting,
      Observing,
      Reflecting,
      Blocked,
      Terminated);
   pragma Convention (C, Agent_State);

   -- Matches `ToolCall` in `AgenticABI.Types`.
   type Tool_Call is
     (Execute,
      Query,
      Transform,
      Communicate,
      Delegate,
      Escalate);
   pragma Convention (C, Tool_Call);

   -- Matches `PlanStep` in `AgenticABI.Types`.
   type Plan_Step is
     (Action,
      Condition,
      Loop,
      Branch,
      Parallel,
      Checkpoint,
      Rollback);
   pragma Convention (C, Plan_Step);

   -- Matches `Coordination` in `AgenticABI.Types`.
   type Coordination is
     (Solo,
      Collaborative,
      Competitive,
      Hierarchical,
      Swarm,
      Consensus);
   pragma Convention (C, Coordination);

   -- Matches `SafetyCheck` in `AgenticABI.Types`.
   type Safety_Check is
     (Approved,
      Denied,
      Escalated,
      Timeout,
      Sandboxed,
      Human_Required);
   pragma Convention (C, Safety_Check);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "agentic_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "agentic_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "agentic_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "agentic_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "agentic_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Agentic;
