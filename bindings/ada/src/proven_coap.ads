-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-coap protocol (Constrained Application Protocol (RFC 7252)).
--
-- Wraps the C-ABI functions from protocols/proven-coap/ffi/zig/src/coap.zig:
--   coap_abi_version, coap_create_context, coap_destroy_context,
--   coap_state, coap_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Coap is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `Method` in `CoapABI.Types`.
   type Method is
     (Get,
      Post,
      Put,
      Delete);
   pragma Convention (C, Method);

   -- Matches `MessageType` in `CoapABI.Types`.
   type Message_Type is
     (Confirmable,
      Non_Confirmable,
      Acknowledgement,
      Reset);
   pragma Convention (C, Message_Type);

   -- Matches `ContentFormat` in `CoapABI.Types`.
   type Content_Format is
     (Text_Plain,
      Link_Format,
      Xml,
      Octet_Stream,
      Exi,
      Json,
      Cbor);
   pragma Convention (C, Content_Format);

   -- Matches `ResponseClass` in `CoapABI.Types`.
   type Response_Class is
     (Success,
      Client_Error,
      Server_Error,
      Signaling,
      Empty);
   pragma Convention (C, Response_Class);

   -- Matches `SessionState` in `CoapABI.Types`.
   type Session_State is
     (Idle,
      Bound,
      Serving,
      Observing,
      Shutdown);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "coap_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "coap_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "coap_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "coap_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "coap_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Coap;
