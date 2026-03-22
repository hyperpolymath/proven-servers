-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-deception protocol (Cyber deception platform).
--
-- Wraps the C-ABI functions from protocols/proven-deception/ffi/zig/src/deception.zig:
--   deception_abi_version, deception_create_context, deception_destroy_context,
--   deception_state, deception_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Deception is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `DecoyType` in `DeceptionABI.Types`.
   type Decoy_Type is
     (Service,
      Credential,
      File,
      Network,
      Token,
      Breadcrumb);
   pragma Convention (C, Decoy_Type);

   -- Matches `TriggerEvent` in `DeceptionABI.Types`.
   type Trigger_Event is
     (Access,
      Login,
      Read,
      Write,
      Execute,
      Scan);
   pragma Convention (C, Trigger_Event);

   -- Matches `AlertPriority` in `DeceptionABI.Types`.
   type Alert_Priority is
     (Low,
      Medium,
      High,
      Critical);
   pragma Convention (C, Alert_Priority);

   -- Matches `DecoyState` in `DeceptionABI.Types`.
   type Decoy_State is
     (Active,
      Triggered,
      Disabled,
      Expired);
   pragma Convention (C, Decoy_State);

   -- Matches `ResponseAction` in `DeceptionABI.Types`.
   type Response_Action is
     (Alert,
      Redirect,
      Delay,
      Fingerprint,
      Isolate);
   pragma Convention (C, Response_Action);

   -- Matches `ServerState` in `DeceptionABI.Types`.
   type Server_State is
     (Idle,
      Configured,
      Monitoring,
      Responding,
      Shutdown);
   pragma Convention (C, Server_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "deception_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "deception_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "deception_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "deception_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "deception_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Deception;
