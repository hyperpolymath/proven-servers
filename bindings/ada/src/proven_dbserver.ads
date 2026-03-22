-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-dbserver protocol (Database server).
--
-- Wraps the C-ABI functions from protocols/proven-dbserver/ffi/zig/src/dbserver.zig:
--   dbserver_abi_version, dbserver_create_context, dbserver_destroy_context,
--   dbserver_state, dbserver_can_transition.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Dbserver is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Matches `QueryType` in `DbserverABI.Types`.
   type Query_Type is
     (Select,
      Insert,
      Update,
      Delete,
      Create_Table,
      Drop_Table,
      Alter_Table,
      Create_Index,
      Drop_Index,
      Begin,
      Commit,
      Rollback);
   pragma Convention (C, Query_Type);

   -- Matches `DataType` in `DbserverABI.Types`.
   type Data_Type is
     (Integer,
      Float,
      Text,
      Blob,
      Boolean,
      Timestamp,
      Uuid,
      Json,
      Null);
   pragma Convention (C, Data_Type);

   -- Matches `IsolationLevel` in `DbserverABI.Types`.
   type Isolation_Level is
     (Read_Uncommitted,
      Read_Committed,
      Repeatable_Read,
      Serializable);
   pragma Convention (C, Isolation_Level);

   -- Matches `ErrorCode` in `DbserverABI.Types`.
   type Error_Code is
     (Syntax_Error,
      Table_Not_Found,
      Column_Not_Found,
      Duplicate_Key,
      Constraint_Violation,
      Type_Mismatch,
      Deadlock_Detected,
      Transaction_Aborted,
      Disk_Full,
      Connection_Lost);
   pragma Convention (C, Error_Code);

   -- Matches `JoinType` in `DbserverABI.Types`.
   type Join_Type is
     (Inner,
      Left_Outer,
      Right_Outer,
      Full_Outer,
      Cross);
   pragma Convention (C, Join_Type);

   -- Matches `SessionState` in `DbserverABI.Types`.
   type Session_State is
     (Idle,
      Connected,
      Transaction,
      Executing,
      Finalising,
      Disconnecting);
   pragma Convention (C, Session_State);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "dbserver_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "dbserver_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "dbserver_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "dbserver_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "dbserver_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Dbserver;
