-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-snmp protocol (Simple Network Management Protocol).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Snmp is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- SNMP versions (tags 0-2).
   type Version is (Snmp_V1, Snmp_V2c, Snmp_V3);
   for Version use (Snmp_V1 => 0, Snmp_V2c => 1, Snmp_V3 => 2);
   pragma Convention (C, Version);

   -- PDU types (tags 0-6).
   type Pdu_Type is
     (Pdu_Get_Request, Pdu_Get_Next_Request, Pdu_Get_Response,
      Pdu_Set_Request, Pdu_Get_Bulk_Request, Pdu_Inform_Request,
      Pdu_Snmp_V2_Trap);
   for Pdu_Type use
     (Pdu_Get_Request      => 0, Pdu_Get_Next_Request => 1,
      Pdu_Get_Response     => 2, Pdu_Set_Request      => 3,
      Pdu_Get_Bulk_Request => 4, Pdu_Inform_Request   => 5,
      Pdu_Snmp_V2_Trap     => 6);
   pragma Convention (C, Pdu_Type);

   -- Error status codes (tags 0-15).
   type Error_Status is
     (Err_No_Error, Err_Too_Big, Err_No_Such_Name, Err_Bad_Value,
      Err_Read_Only, Err_Gen_Err, Err_No_Access, Err_Wrong_Type,
      Err_Wrong_Length, Err_Wrong_Value, Err_No_Creation,
      Err_Inconsistent_Value, Err_Resource_Unavailable,
      Err_Commit_Failed, Err_Undo_Failed, Err_Authorization_Error);
   for Error_Status use
     (Err_No_Error             => 0,  Err_Too_Big              => 1,
      Err_No_Such_Name         => 2,  Err_Bad_Value            => 3,
      Err_Read_Only            => 4,  Err_Gen_Err              => 5,
      Err_No_Access            => 6,  Err_Wrong_Type           => 7,
      Err_Wrong_Length          => 8,  Err_Wrong_Value          => 9,
      Err_No_Creation          => 10, Err_Inconsistent_Value   => 11,
      Err_Resource_Unavailable => 12, Err_Commit_Failed        => 13,
      Err_Undo_Failed          => 14, Err_Authorization_Error  => 15);
   pragma Convention (C, Error_Status);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "snmp_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "snmp_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "snmp_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "snmp_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "snmp_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Snmp;
