-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-tacacs protocol (TACACS+ AAA).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Tacacs is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Packet types (tags 0-2).
   type Packet_Type is (Pkt_Authentication, Pkt_Authorization, Pkt_Accounting);
   for Packet_Type use
     (Pkt_Authentication => 0, Pkt_Authorization => 1, Pkt_Accounting => 2);
   pragma Convention (C, Packet_Type);

   -- Authentication types (tags 0-4).
   type Authen_Type is (At_Ascii, At_Pap, At_Chap, At_Ms_Chap_V1, At_Ms_Chap_V2);
   for Authen_Type use
     (At_Ascii => 0, At_Pap => 1, At_Chap => 2,
      At_Ms_Chap_V1 => 3, At_Ms_Chap_V2 => 4);
   pragma Convention (C, Authen_Type);

   -- Authentication actions (tags 0-2).
   type Authen_Action is (Aa_Login, Aa_Change_Pass, Aa_Send_Auth);
   for Authen_Action use (Aa_Login => 0, Aa_Change_Pass => 1, Aa_Send_Auth => 2);
   pragma Convention (C, Authen_Action);

   -- Authentication statuses (tags 0-7).
   type Authen_Status is
     (As_Pass, As_Fail, As_Get_Data, As_Get_User,
      As_Get_Pass, As_Restart, As_Error, As_Follow);
   for Authen_Status use
     (As_Pass     => 0, As_Fail     => 1, As_Get_Data => 2,
      As_Get_User => 3, As_Get_Pass => 4, As_Restart  => 5,
      As_Error    => 6, As_Follow   => 7);
   pragma Convention (C, Authen_Status);

   -- Authorization statuses (tags 0-4).
   type Author_Status is
     (Az_Pass_Add, Az_Pass_Repl, Az_Fail, Az_Error, Az_Follow);
   for Author_Status use
     (Az_Pass_Add  => 0, Az_Pass_Repl => 1, Az_Fail => 2,
      Az_Error     => 3, Az_Follow    => 4);
   pragma Convention (C, Author_Status);

   -- Accounting statuses (tags 0-2).
   type Acct_Status is (Acct_Success, Acct_Error, Acct_Follow);
   for Acct_Status use (Acct_Success => 0, Acct_Error => 1, Acct_Follow => 2);
   pragma Convention (C, Acct_Status);

   -- Accounting flags (tags 0-2).
   type Acct_Flag is (Flag_Start, Flag_Stop, Flag_Watchdog);
   for Acct_Flag use (Flag_Start => 0, Flag_Stop => 1, Flag_Watchdog => 2);
   pragma Convention (C, Acct_Flag);

   -- Session states (tags 0-4).
   type Session_State is
     (State_Idle, State_Authenticating, State_Authorizing,
      State_Active, State_Closing);
   for Session_State use
     (State_Idle           => 0, State_Authenticating => 1,
      State_Authorizing    => 2, State_Active         => 3,
      State_Closing        => 4);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "tacacs_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "tacacs_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "tacacs_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "tacacs_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "tacacs_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Tacacs;
