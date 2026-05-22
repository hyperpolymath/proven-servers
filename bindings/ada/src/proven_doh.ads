-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-doh protocol (DNS-over-HTTPS (RFC 8484)).
--
-- Wraps the C-ABI functions from protocols/proven-doh/ffi/zig/src/doh.zig:
--   doh_abi_version, doh_create_context, doh_destroy_context,
--   doh_state, doh_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Doh is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `ContentType` in `DohABI.Types`.
   type Content_Type is
     (Dns_Message,
      Dns_Json);
   pragma Convention (C, Content_Type);

   -- Matches `RequestMethod` in `DohABI.Types`.
   type Request_Method is
     (Get,
      Post);
   pragma Convention (C, Request_Method);

   -- Matches `WireFormat` in `DohABI.Types`.
   type Wire_Format is
     (Binary,
      Json);
   pragma Convention (C, Wire_Format);

   -- Matches `ErrorReason` in `DohABI.Types`.
   type Error_Reason is
     (Bad_Content_Type,
      Bad_Method,
      Payload_Too_Large,
      Upstream_Timeout,
      Upstream_Error);
   pragma Convention (C, Error_Reason);

   -- Matches `SessionState` in `DohABI.Types`.
   type Session_State is
     (Idle,
      Bound,
      Serving,
      Resolving,
      Shutdown);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "doh_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "doh_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "doh_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "doh_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "doh_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Doh;
