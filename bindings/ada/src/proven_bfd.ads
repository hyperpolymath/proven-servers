-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-bfd protocol (Bidirectional Forwarding Detection (RFC 5880)).
--
-- Wraps the C-ABI functions from protocols/proven-bfd/ffi/zig/src/bfd.zig:
--   bfd_abi_version, bfd_create_context, bfd_destroy_context,
--   bfd_state, bfd_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Bfd is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `BfdState` in `BfdABI.Types`.
   type Bfd_State is
     (Admin_Down,
      Down,
      Init,
      Up);
   pragma Convention (C, Bfd_State);

   -- Matches `Diagnostic` in `BfdABI.Types`.
   type Diagnostic is
     (No_Diagnostic,
      Control_Detection_Time_Expired,
      Echo_Function_Failed,
      Neighbor_Signaled_Session_Down,
      Forwarding_Plane_Reset,
      Path_Down,
      Concatenated_Path_Down,
      Administratively_Down,
      Reverse_Concatenated_Path_Down);
   pragma Convention (C, Diagnostic);

   -- Matches `SessionMode` in `BfdABI.Types`.
   type Session_Mode is
     (Async_Mode,
      Demand_Mode);
   pragma Convention (C, Session_Mode);

   -- Matches `SessionState` in `BfdABI.Types`.
   type Session_State is
     (Idle,
      Ss_Down,
      Negotiating,
      Established,
      Teardown);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "bfd_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "bfd_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "bfd_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "bfd_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "bfd_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Bfd;
