-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-caldav protocol (CalDAV calendar server (RFC 4791)).
--
-- Wraps the C-ABI functions from protocols/proven-caldav/ffi/zig/src/caldav.zig:
--   caldav_abi_version, caldav_create_context, caldav_destroy_context,
--   caldav_state, caldav_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Caldav is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `ComponentType` in `CaldavABI.Types`.
   type Component_Type is
     (Vevent,
      Vtodo,
      Vjournal,
      Vfreebusy);
   pragma Convention (C, Component_Type);

   -- Matches `CalMethod` in `CaldavABI.Types`.
   type Cal_Method is
     (Get,
      Put,
      Delete,
      Propfind,
      Proppatch,
      Report,
      Mkcalendar);
   pragma Convention (C, Cal_Method);

   -- Matches `ScheduleStatus` in `CaldavABI.Types`.
   type Schedule_Status is
     (Needs_Action,
      Accepted,
      Declined,
      Tentative,
      Delegated);
   pragma Convention (C, Schedule_Status);

   -- Matches `CalError` in `CaldavABI.Types`.
   type Cal_Error is
     (Valid_Calendar_Data,
      No_Resource_Type_Change,
      Supported_Component_Mismatch,
      Max_Resource_Size,
      Uid_Conflict,
      Precondition_Failed);
   pragma Convention (C, Cal_Error);

   -- Matches `ServerState` in `CaldavABI.Types`.
   type Server_State is
     (Idle,
      Bound,
      Serving,
      Scheduling,
      Shutdown);
   pragma Convention (C, Server_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "caldav_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "caldav_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "caldav_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "caldav_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "caldav_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Caldav;
