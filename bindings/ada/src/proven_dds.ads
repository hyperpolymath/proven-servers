-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-dds protocol (Data Distribution Service).
--
-- Wraps the C-ABI functions from protocols/proven-dds/ffi/zig/src/dds.zig:
--   dds_abi_version, dds_create_context, dds_destroy_context,
--   dds_state, dds_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Dds is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `ReliabilityKind` in `DdsABI.Types`.
   type Reliability_Kind is
     (Best_Effort,
      Reliable);
   pragma Convention (C, Reliability_Kind);

   -- Matches `DurabilityKind` in `DdsABI.Types`.
   type Durability_Kind is
     (Transient_Local,
      Transient,
      Persistent);
   for Durability_Kind use
     (Transient_Local => 1,
      Transient       => 2,
      Persistent      => 3);
   pragma Convention (C, Durability_Kind);

   -- Matches `HistoryKind` in `DdsABI.Types`.
   type History_Kind is
     (Keep_Last,
      Keep_All);
   pragma Convention (C, History_Kind);

   -- Matches `OwnershipKind` in `DdsABI.Types`.
   type Ownership_Kind is
     (Shared,
      Exclusive);
   pragma Convention (C, Ownership_Kind);

   -- Matches `EntityType` in `DdsABI.Types`.
   type Entity_Type is
     (Participant,
      Publisher,
      Subscriber,
      Topic,
      Data_Writer,
      Data_Reader);
   pragma Convention (C, Entity_Type);

   -- Matches `ParticipantState` in `DdsABI.Types`.
   type Participant_State is
     (Idle,
      Joined,
      Publishing,
      Subscribing,
      Leaving);
   pragma Convention (C, Participant_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "dds_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "dds_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "dds_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "dds_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "dds_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Dds;
