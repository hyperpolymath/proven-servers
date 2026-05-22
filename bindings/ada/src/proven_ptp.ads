-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ptp protocol (Precision Time Protocol, IEEE 1588).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ptp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- PTP message types (tags 0-9).
   type Ptp_Message_Type is
     (Msg_Sync, Msg_Delay_Req, Msg_Pdelay_Req, Msg_Pdelay_Resp,
      Msg_Follow_Up, Msg_Delay_Resp, Msg_Pdelay_Resp_Follow_Up,
      Msg_Announce, Msg_Signaling, Msg_Management);
   for Ptp_Message_Type use
     (Msg_Sync                    => 0, Msg_Delay_Req    => 1,
      Msg_Pdelay_Req              => 2, Msg_Pdelay_Resp  => 3,
      Msg_Follow_Up               => 4, Msg_Delay_Resp   => 5,
      Msg_Pdelay_Resp_Follow_Up   => 6, Msg_Announce     => 7,
      Msg_Signaling               => 8, Msg_Management   => 9);
   pragma Convention (C, Ptp_Message_Type);

   -- PTP clock classes (tags 0-3).
   type Clock_Class is
     (Clk_Primary, Clk_Application_Specific, Clk_Slave_Only, Clk_Default);
   for Clock_Class use
     (Clk_Primary => 0, Clk_Application_Specific => 1,
      Clk_Slave_Only => 2, Clk_Default => 3);
   pragma Convention (C, Clock_Class);

   -- PTP port states (tags 0-8).
   type Ptp_Port_State is
     (Port_Initializing, Port_Faulty, Port_Disabled, Port_Listening,
      Port_Pre_Master, Port_Master, Port_Passive,
      Port_Uncalibrated, Port_Slave);
   for Ptp_Port_State use
     (Port_Initializing => 0, Port_Faulty       => 1,
      Port_Disabled     => 2, Port_Listening     => 3,
      Port_Pre_Master   => 4, Port_Master        => 5,
      Port_Passive      => 6, Port_Uncalibrated  => 7,
      Port_Slave        => 8);
   pragma Convention (C, Ptp_Port_State);

   -- Delay mechanisms (tags 0-2).
   type Delay_Mechanism is (Dm_E2E, Dm_P2P, Dm_Disabled);
   for Delay_Mechanism use (Dm_E2E => 0, Dm_P2P => 1, Dm_Disabled => 2);
   pragma Convention (C, Delay_Mechanism);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ptp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ptp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ptp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ptp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ptp_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Ptp;
