-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-carddav protocol (CardDAV contact server (RFC 6352)).
--
-- Wraps the C-ABI functions from protocols/proven-carddav/ffi/zig/src/carddav.zig:
--   carddav_abi_version, carddav_create_context, carddav_destroy_context,
--   carddav_state, carddav_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Carddav is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `PropertyType` in `CarddavABI.Types`.
   type Property_Type is
     (Fn_Name,
      N,
      Email,
      Tel,
      Adr,
      Org,
      Photo,
      Url,
      Note);
   pragma Convention (C, Property_Type);

   -- Matches `CardMethod` in `CarddavABI.Types`.
   type Card_Method is
     (Get,
      Put,
      Delete,
      Propfind,
      Proppatch,
      Report,
      Mkcol);
   pragma Convention (C, Card_Method);

   -- Matches `VCardVersion` in `CarddavABI.Types`.
   type V_Card_Version is
     (Vcard3,
      Vcard4);
   pragma Convention (C, V_Card_Version);

   -- Matches `CardError` in `CarddavABI.Types`.
   type Card_Error is
     (Valid_Address_Data,
      No_Resource_Type,
      Max_Resource_Size,
      Uid_Conflict,
      Supported_Address_Data,
      Precondition_Failed);
   pragma Convention (C, Card_Error);

   -- Matches `ServerState` in `CarddavABI.Types`.
   type Server_State is
     (Idle,
      Bound,
      Serving,
      Shutdown);
   pragma Convention (C, Server_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "carddav_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "carddav_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "carddav_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "carddav_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "carddav_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Carddav;
