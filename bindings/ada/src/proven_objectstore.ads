-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-object store protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Objectstore is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Object store operations (tags 0-11).
   type Os_Operation is
     (Op_Put_Object, Op_Get_Object, Op_Delete_Object, Op_List_Objects,
      Op_Head_Object, Op_Copy_Object, Op_Create_Bucket, Op_Delete_Bucket,
      Op_List_Buckets, Op_Init_Multipart_Upload, Op_Upload_Part,
      Op_Complete_Multipart_Upload);
   for Os_Operation use
     (Op_Put_Object => 0, Op_Get_Object => 1, Op_Delete_Object => 2,
      Op_List_Objects => 3, Op_Head_Object => 4, Op_Copy_Object => 5,
      Op_Create_Bucket => 6, Op_Delete_Bucket => 7, Op_List_Buckets => 8,
      Op_Init_Multipart_Upload => 9, Op_Upload_Part => 10,
      Op_Complete_Multipart_Upload => 11);
   pragma Convention (C, Os_Operation);

   -- Object storage classes (tags 0-4).
   type Storage_Class is
     (Sc_Standard, Sc_Infrequent_Access, Sc_Glacier,
      Sc_Deep_Archive, Sc_One_Zone);
   for Storage_Class use
     (Sc_Standard => 0, Sc_Infrequent_Access => 1, Sc_Glacier => 2,
      Sc_Deep_Archive => 3, Sc_One_Zone => 4);
   pragma Convention (C, Storage_Class);

   -- Object ACL policies (tags 0-3).
   type Acl is
     (Acl_Private, Acl_Public_Read, Acl_Public_Read_Write,
      Acl_Authenticated_Read);
   for Acl use
     (Acl_Private => 0, Acl_Public_Read => 1,
      Acl_Public_Read_Write => 2, Acl_Authenticated_Read => 3);
   pragma Convention (C, Acl);

   -- Object store error codes (tags 0-7).
   type Os_Error_Code is
     (Ec_No_Such_Bucket, Ec_No_Such_Key, Ec_Bucket_Already_Exists,
      Ec_Bucket_Not_Empty, Ec_Access_Denied, Ec_Entity_Too_Large,
      Ec_Invalid_Part, Ec_Incomplete_Body);
   for Os_Error_Code use
     (Ec_No_Such_Bucket => 0, Ec_No_Such_Key => 1,
      Ec_Bucket_Already_Exists => 2, Ec_Bucket_Not_Empty => 3,
      Ec_Access_Denied => 4, Ec_Entity_Too_Large => 5,
      Ec_Invalid_Part => 6, Ec_Incomplete_Body => 7);
   pragma Convention (C, Os_Error_Code);

   -- Object store session states (tags 0-4).
   type Session_State is
     (State_Idle, State_Ready, State_Bucket_Active,
      State_Uploading, State_Closing);
   for Session_State use
     (State_Idle => 0, State_Ready => 1, State_Bucket_Active => 2,
      State_Uploading => 3, State_Closing => 4);
   pragma Convention (C, Session_State);

   -- Standard MinIO/S3 port.
   Objectstore_Port : constant := 9000;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "objectstore_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "objectstore_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "objectstore_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "objectstore_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "objectstore_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Objectstore;
