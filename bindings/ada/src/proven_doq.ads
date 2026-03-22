-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-doq protocol (DNS-over-QUIC (RFC 9250)).
--
-- Wraps the C-ABI functions from protocols/proven-doq/ffi/zig/src/doq.zig:
--   doq_abi_version, doq_create_context, doq_destroy_context,
--   doq_state, doq_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Doq is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `StreamType` in `DoqABI.Types`.
   type Stream_Type is
     (Unidirectional,
      Bidirectional);
   pragma Convention (C, Stream_Type);

   -- Matches `ErrorCode` in `DoqABI.Types`.
   type Error_Code is
     (No_Error,
      Internal_Error,
      Excessive_Load,
      Protocol_Error);
   pragma Convention (C, Error_Code);

   -- Matches `SessionState` in `DoqABI.Types`.
   type Session_State is
     (Initial,
      Handshaking,
      Ready,
      Draining,
      Closed);
   pragma Convention (C, Session_State);

   -- Matches `ServerState` in `DoqABI.Types`.
   type Server_State is
     (Idle,
      Bound,
      Listening,
      Processing,
      Shutdown);
   pragma Convention (C, Server_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "doq_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "doq_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "doq_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "doq_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "doq_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Doq;
