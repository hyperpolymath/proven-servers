-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-multicast dns protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Mdns is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- mDNS record types (tags 0-4).
   type Mdns_Record_Type is (Rt_A, Rt_Aaaa, Rt_Ptr, Rt_Srv, Rt_Txt);
   for Mdns_Record_Type use
     (Rt_A => 0, Rt_Aaaa => 1, Rt_Ptr => 2, Rt_Srv => 3, Rt_Txt => 4);
   pragma Convention (C, Mdns_Record_Type);

   -- mDNS query types (tags 0-2).
   type Query_Type is (Qt_Standard, Qt_One_Shot, Qt_Continuous);
   for Query_Type use
     (Qt_Standard => 0, Qt_One_Shot => 1, Qt_Continuous => 2);
   pragma Convention (C, Query_Type);

   -- mDNS conflict resolution actions (tags 0-2).
   type Conflict_Action is (Ca_Probe, Ca_Defend, Ca_Withdraw);
   for Conflict_Action use (Ca_Probe => 0, Ca_Defend => 1, Ca_Withdraw => 2);
   pragma Convention (C, Conflict_Action);

   -- mDNS service flags (tags 0-1).
   type Service_Flag is (Sf_Unique, Sf_Shared);
   for Service_Flag use (Sf_Unique => 0, Sf_Shared => 1);
   pragma Convention (C, Service_Flag);

   -- mDNS responder states (tags 0-4).
   type Responder_State is
     (State_Idle, State_Probing, State_Announcing,
      State_Running, State_Shutting_Down);
   for Responder_State use
     (State_Idle => 0, State_Probing => 1, State_Announcing => 2,
      State_Running => 3, State_Shutting_Down => 4);
   pragma Convention (C, Responder_State);

   -- Standard mDNS port.
   Mdns_Port : constant := 5353;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "mdns_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "mdns_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "mdns_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "mdns_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "mdns_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Mdns;
