-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ntp protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ntp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- NTP leap second indicator (tags 0-3).
   type Leap_Indicator is
     (Li_No_Warning, Li_Last_Minute_61, Li_Last_Minute_59, Li_Unsynchronised);
   for Leap_Indicator use
     (Li_No_Warning => 0, Li_Last_Minute_61 => 1,
      Li_Last_Minute_59 => 2, Li_Unsynchronised => 3);
   pragma Convention (C, Leap_Indicator);

   -- NTP association modes (tags 0-7).
   type Ntp_Mode is
     (Ntp_Reserved, Ntp_Symmetric_Active, Ntp_Symmetric_Passive,
      Ntp_Client, Ntp_Server, Ntp_Broadcast,
      Ntp_Control_Message, Ntp_Private);
   for Ntp_Mode use
     (Ntp_Reserved => 0, Ntp_Symmetric_Active => 1,
      Ntp_Symmetric_Passive => 2, Ntp_Client => 3, Ntp_Server => 4,
      Ntp_Broadcast => 5, Ntp_Control_Message => 6, Ntp_Private => 7);
   pragma Convention (C, Ntp_Mode);

   -- NTP exchange states (tags 0-3).
   type Exchange_State is
     (Es_Idle, Es_Request_Received, Es_Timestamp_Calculated, Es_Response_Sent);
   for Exchange_State use
     (Es_Idle => 0, Es_Request_Received => 1,
      Es_Timestamp_Calculated => 2, Es_Response_Sent => 3);
   pragma Convention (C, Exchange_State);

   -- Clock discipline algorithm states (tags 0-4).
   type Clock_Discipline_State is
     (Cd_Unset, Cd_Spike, Cd_Freq, Cd_Sync, Cd_Panic);
   for Clock_Discipline_State use
     (Cd_Unset => 0, Cd_Spike => 1, Cd_Freq => 2,
      Cd_Sync => 3, Cd_Panic => 4);
   pragma Convention (C, Clock_Discipline_State);

   -- Kiss-o-Death codes (tags 0-3).
   type Kiss_Code is (Kc_Deny, Kc_Rstr, Kc_Rate, Kc_Other);
   for Kiss_Code use
     (Kc_Deny => 0, Kc_Rstr => 1, Kc_Rate => 2, Kc_Other => 3);
   pragma Convention (C, Kiss_Code);

   -- NTP error codes (tags 0-5).
   type Ntp_Error is
     (Ne_Ok, Ne_Invalid_Slot, Ne_Not_Active,
      Ne_Invalid_Packet, Ne_Kiss_Of_Death, Ne_Stratum_Too_High);
   for Ntp_Error use
     (Ne_Ok => 0, Ne_Invalid_Slot => 1, Ne_Not_Active => 2,
      Ne_Invalid_Packet => 3, Ne_Kiss_Of_Death => 4,
      Ne_Stratum_Too_High => 5);
   pragma Convention (C, Ntp_Error);

   -- Standard NTP port.
   Ntp_Port : constant := 123;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ntp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ntp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ntp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ntp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ntp_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Ntp;
