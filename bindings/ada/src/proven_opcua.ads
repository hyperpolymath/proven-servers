-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-opc ua protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Opcua is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- OPC UA service types (tags 0-10).
   type Service_Type is
     (Svc_Read, Svc_Write, Svc_Browse, Svc_Subscribe, Svc_Publish,
      Svc_Call, Svc_Create_Session, Svc_Activate_Session,
      Svc_Close_Session, Svc_Create_Subscription, Svc_Delete_Subscription);
   for Service_Type use
     (Svc_Read => 0, Svc_Write => 1, Svc_Browse => 2, Svc_Subscribe => 3,
      Svc_Publish => 4, Svc_Call => 5, Svc_Create_Session => 6,
      Svc_Activate_Session => 7, Svc_Close_Session => 8,
      Svc_Create_Subscription => 9, Svc_Delete_Subscription => 10);
   pragma Convention (C, Service_Type);

   -- OPC UA node classes (tags 0-7).
   type Node_Class is
     (Nc_Object, Nc_Variable, Nc_Method, Nc_Object_Type,
      Nc_Variable_Type, Nc_Reference_Type, Nc_Data_Type, Nc_View);
   for Node_Class use
     (Nc_Object => 0, Nc_Variable => 1, Nc_Method => 2,
      Nc_Object_Type => 3, Nc_Variable_Type => 4,
      Nc_Reference_Type => 5, Nc_Data_Type => 6, Nc_View => 7);
   pragma Convention (C, Node_Class);

   -- OPC UA status codes (tags 0-11).
   type Opcua_Status_Code is
     (Sc_Good, Sc_Uncertain, Sc_Bad, Sc_Bad_Node_Id_Unknown,
      Sc_Bad_Attribute_Id_Invalid, Sc_Bad_Not_Readable,
      Sc_Bad_Not_Writable, Sc_Bad_Out_Of_Range,
      Sc_Bad_Type_Mismatch, Sc_Bad_Session_Id_Invalid,
      Sc_Bad_Subscription_Id_Invalid, Sc_Bad_Timeout);
   for Opcua_Status_Code use
     (Sc_Good => 0, Sc_Uncertain => 1, Sc_Bad => 2,
      Sc_Bad_Node_Id_Unknown => 3, Sc_Bad_Attribute_Id_Invalid => 4,
      Sc_Bad_Not_Readable => 5, Sc_Bad_Not_Writable => 6,
      Sc_Bad_Out_Of_Range => 7, Sc_Bad_Type_Mismatch => 8,
      Sc_Bad_Session_Id_Invalid => 9,
      Sc_Bad_Subscription_Id_Invalid => 10, Sc_Bad_Timeout => 11);
   pragma Convention (C, Opcua_Status_Code);

   -- Message security modes (tags 0-2).
   type Security_Mode is (Sm_None, Sm_Sign, Sm_Sign_And_Encrypt);
   for Security_Mode use
     (Sm_None => 0, Sm_Sign => 1, Sm_Sign_And_Encrypt => 2);
   pragma Convention (C, Security_Mode);

   -- OPC UA session lifecycle states (tags 0-5).
   type Session_State is
     (State_Idle, State_Connected, State_Created,
      State_Activated, State_Monitoring, State_Closing);
   for Session_State use
     (State_Idle => 0, State_Connected => 1, State_Created => 2,
      State_Activated => 3, State_Monitoring => 4, State_Closing => 5);
   pragma Convention (C, Session_State);

   -- Standard OPC UA ports.
   Opcua_Port     : constant := 4840;
   Opcua_Tls_Port : constant := 4843;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "opcua_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "opcua_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "opcua_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "opcua_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "opcua_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Opcua;
