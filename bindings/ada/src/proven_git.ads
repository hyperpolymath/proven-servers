-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-git protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Git is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Git protocol commands (tags 0-2).
   type Git_Command is
     (Cmd_Upload_Pack,
      Cmd_Receive_Pack,
      Cmd_Upload_Archive);
   for Git_Command use
     (Cmd_Upload_Pack    => 0,
      Cmd_Receive_Pack   => 1,
      Cmd_Upload_Archive => 2);
   pragma Convention (C, Git_Command);

   -- Git protocol packet types (tags 0-7).
   type Packet_Type is
     (Pkt_Flush,
      Pkt_Delimiter,
      Pkt_Response_End,
      Pkt_Data,
      Pkt_Error,
      Pkt_Sideband_Data,
      Pkt_Sideband_Progress,
      Pkt_Sideband_Error);
   for Packet_Type use
     (Pkt_Flush             => 0,
      Pkt_Delimiter         => 1,
      Pkt_Response_End      => 2,
      Pkt_Data              => 3,
      Pkt_Error             => 4,
      Pkt_Sideband_Data     => 5,
      Pkt_Sideband_Progress => 6,
      Pkt_Sideband_Error    => 7);
   pragma Convention (C, Packet_Type);

   -- Git reference types (tags 0-4).
   type Ref_Type is
     (Ref_Branch,
      Ref_Tag,
      Ref_Head,
      Ref_Remote,
      Ref_Git_Note);
   for Ref_Type use
     (Ref_Branch   => 0,
      Ref_Tag      => 1,
      Ref_Head     => 2,
      Ref_Remote   => 3,
      Ref_Git_Note => 4);
   pragma Convention (C, Ref_Type);

   -- Git protocol capabilities (tags 0-8).
   type Capability is
     (Cap_Multi_Ack,
      Cap_Thin_Pack,
      Cap_Side_Band_64k,
      Cap_Ofs_Delta,
      Cap_Shallow,
      Cap_Deepen_Since,
      Cap_Deepen_Not,
      Cap_Filter_Spec,
      Cap_Object_Format);
   for Capability use
     (Cap_Multi_Ack     => 0,
      Cap_Thin_Pack     => 1,
      Cap_Side_Band_64k => 2,
      Cap_Ofs_Delta     => 3,
      Cap_Shallow       => 4,
      Cap_Deepen_Since  => 5,
      Cap_Deepen_Not    => 6,
      Cap_Filter_Spec   => 7,
      Cap_Object_Format => 8);
   pragma Convention (C, Capability);

   -- Git hook results (tags 0-1).
   type Hook_Result is (Hook_Accept, Hook_Reject);
   for Hook_Result use (Hook_Accept => 0, Hook_Reject => 1);
   pragma Convention (C, Hook_Result);

   -- Git server states (tags 0-4).
   type Server_State is
     (State_Idle,
      State_Discovery,
      State_Negotiating,
      State_Transfer,
      State_Shutdown);
   for Server_State use
     (State_Idle        => 0,
      State_Discovery   => 1,
      State_Negotiating => 2,
      State_Transfer    => 3,
      State_Shutdown    => 4);
   pragma Convention (C, Server_State);

   -- Standard Git daemon port.
   Git_Port : constant := 9418;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "git_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "git_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "git_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "git_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "git_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Git;
