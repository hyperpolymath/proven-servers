-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-gameserver protocol (Game server).
--
-- Wraps the C-ABI functions from protocols/proven-gameserver/ffi/zig/src/gameserver.zig:
--   gameserver_abi_version, gameserver_create_context, gameserver_destroy_context,
--   gameserver_state, gameserver_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Gameserver is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `SessionType` in `GameserverABI.Types`.
   type Session_Type is
     (Lobby,
      Match,
      Practice,
      Spectator,
      Tournament);
   pragma Convention (C, Session_Type);

   -- Matches `PlayerState` in `GameserverABI.Types`.
   type Player_State is
     (Idle,
      Queuing,
      Loading,
      Playing,
      Spectating,
      Disconnected);
   pragma Convention (C, Player_State);

   -- Matches `MatchState` in `GameserverABI.Types`.
   type Match_State is
     (Waiting,
      Starting,
      In_Progress,
      Paused,
      Ending,
      Complete);
   pragma Convention (C, Match_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "gameserver_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "gameserver_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "gameserver_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "gameserver_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "gameserver_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Gameserver;
