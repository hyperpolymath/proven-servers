-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-dot protocol (DNS-over-TLS (RFC 7858)).
--
-- Wraps the C-ABI functions from protocols/proven-dot/ffi/zig/src/dot.zig:
--   dot_abi_version, dot_create_context, dot_destroy_context,
--   dot_state, dot_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Dot is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `SessionState` in `DotABI.Types`.
   type Session_State is
     (Connecting,
      Handshaking,
      Established,
      Closing,
      Closed);
   pragma Convention (C, Session_State);

   -- Matches `PaddingStrategy` in `DotABI.Types`.
   type Padding_Strategy is
     (No_Padding,
      Block_Padding,
      Random_Padding);
   pragma Convention (C, Padding_Strategy);

   -- Matches `ErrorReason` in `DotABI.Types`.
   type Error_Reason is
     (Handshake_Failed,
      Certificate_Invalid,
      Timeout,
      Upstream_Error);
   pragma Convention (C, Error_Reason);

   -- Matches `ServerState` in `DotABI.Types`.
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
   pragma Import (C, Abi_Version, "dot_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "dot_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "dot_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "dot_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "dot_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Dot;
