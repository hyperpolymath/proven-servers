-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-federation protocol (ActivityPub federation).
--
-- Wraps the C-ABI functions from protocols/proven-federation/ffi/zig/src/federation.zig:
--   federation_abi_version, federation_create_context, federation_destroy_context,
--   federation_state, federation_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Federation is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `ActivityType` in `FederationABI.Types`.
   type Activity_Type is
     (Create,
      Update,
      Delete,
      Follow,
      Accept,
      Reject,
      Announce,
      Like,
      Undo,
      Block,
      Flag);
   pragma Convention (C, Activity_Type);

   -- Matches `ActorType` in `FederationABI.Types`.
   type Actor_Type is
     (Person,
      Service,
      Application,
      Group,
      Organization);
   pragma Convention (C, Actor_Type);

   -- Matches `DeliveryStatus` in `FederationABI.Types`.
   type Delivery_Status is
     (Pending,
      Delivered,
      Failed,
      Rejected,
      Deferred);
   pragma Convention (C, Delivery_Status);

   -- Matches `TrustLevel` in `FederationABI.Types`.
   type Trust_Level is
     (Self_Signed,
      Peer_Verified,
      Federation_Trusted,
      Revoked,
      Unknown);
   pragma Convention (C, Trust_Level);

   -- Matches `ObjectType` in `FederationABI.Types`.
   type Object_Type is
     (Note,
      Article,
      Image,
      Video,
      Audio,
      Document,
      Event,
      Collection,
      Ordered_Collection);
   pragma Convention (C, Object_Type);

   -- Matches `ServerState` in `FederationABI.Types`.
   type Server_State is
     (Idle,
      Active,
      Processing,
      Delivering,
      Shutdown);
   pragma Convention (C, Server_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "federation_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "federation_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "federation_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "federation_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "federation_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Federation;
