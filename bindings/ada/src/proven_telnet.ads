-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-telnet protocol (Telnet -- INSECURE, legacy only).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Telnet is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Telnet commands (tags 0-15).
   type Telnet_Command is
     (Cmd_Se, Cmd_Nop, Cmd_Data_Mark, Cmd_Break,
      Cmd_Interrupt_Process, Cmd_Abort_Output, Cmd_Are_You_There,
      Cmd_Erase_Char, Cmd_Erase_Line, Cmd_Go_Ahead, Cmd_Sb,
      Cmd_Will, Cmd_Wont, Cmd_Do, Cmd_Dont, Cmd_Iac);
   for Telnet_Command use
     (Cmd_Se               => 0,  Cmd_Nop              => 1,
      Cmd_Data_Mark        => 2,  Cmd_Break            => 3,
      Cmd_Interrupt_Process => 4, Cmd_Abort_Output     => 5,
      Cmd_Are_You_There    => 6,  Cmd_Erase_Char       => 7,
      Cmd_Erase_Line       => 8,  Cmd_Go_Ahead         => 9,
      Cmd_Sb               => 10, Cmd_Will             => 11,
      Cmd_Wont             => 12, Cmd_Do               => 13,
      Cmd_Dont             => 14, Cmd_Iac              => 15);
   pragma Convention (C, Telnet_Command);

   -- Telnet options (tags 0-9).
   type Telnet_Option is
     (Opt_Echo, Opt_Suppress_Go_Ahead, Opt_Status, Opt_Timing_Mark,
      Opt_Terminal_Type, Opt_Window_Size, Opt_Terminal_Speed,
      Opt_Remote_Flow_Control, Opt_Linemode, Opt_Environment);
   for Telnet_Option use
     (Opt_Echo              => 0, Opt_Suppress_Go_Ahead => 1,
      Opt_Status            => 2, Opt_Timing_Mark       => 3,
      Opt_Terminal_Type     => 4, Opt_Window_Size       => 5,
      Opt_Terminal_Speed    => 6, Opt_Remote_Flow_Control => 7,
      Opt_Linemode          => 8, Opt_Environment       => 9);
   pragma Convention (C, Telnet_Option);

   -- Negotiation states (tags 0-3).
   type Negotiation_State is (Neg_Inactive, Neg_Will_Sent, Neg_Do_Sent, Neg_Active);
   for Negotiation_State use
     (Neg_Inactive => 0, Neg_Will_Sent => 1, Neg_Do_Sent => 2, Neg_Active => 3);
   pragma Convention (C, Negotiation_State);

   -- Session states (tags 0-4).
   type Session_State is
     (State_Idle, State_Negotiating, State_Active, State_Subneg, State_Closing);
   for Session_State use
     (State_Idle        => 0, State_Negotiating => 1, State_Active => 2,
      State_Subneg      => 3, State_Closing     => 4);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "telnet_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "telnet_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "telnet_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "telnet_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "telnet_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Telnet;
