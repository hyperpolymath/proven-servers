-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-ldap protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Ldap is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- LDAP session states (tags 0-3).
   type Session_State is
     (State_Anonymous, State_Bound, State_Closed, State_Binding);
   for Session_State use
     (State_Anonymous => 0, State_Bound => 1,
      State_Closed => 2, State_Binding => 3);
   pragma Convention (C, Session_State);

   -- LDAP operations (tags 0-9).
   type Ldap_Operation is
     (Op_Bind, Op_Unbind, Op_Search, Op_Modify, Op_Add,
      Op_Delete, Op_Mod_Dn, Op_Compare, Op_Abandon, Op_Extended);
   for Ldap_Operation use
     (Op_Bind => 0, Op_Unbind => 1, Op_Search => 2, Op_Modify => 3,
      Op_Add => 4, Op_Delete => 5, Op_Mod_Dn => 6, Op_Compare => 7,
      Op_Abandon => 8, Op_Extended => 9);
   pragma Convention (C, Ldap_Operation);

   -- Search scope levels (tags 0-2).
   type Search_Scope is
     (Scope_Base_Object, Scope_Single_Level, Scope_Whole_Subtree);
   for Search_Scope use
     (Scope_Base_Object => 0, Scope_Single_Level => 1,
      Scope_Whole_Subtree => 2);
   pragma Convention (C, Search_Scope);

   -- LDAP result codes (tags 0-10).
   type Result_Code is
     (Rc_Success, Rc_Operations_Error, Rc_Protocol_Error,
      Rc_Time_Limit_Exceeded, Rc_Size_Limit_Exceeded,
      Rc_Auth_Method_Not_Supported, Rc_No_Such_Object,
      Rc_Invalid_Credentials, Rc_Insufficient_Access_Rights,
      Rc_Busy, Rc_Unavailable);
   for Result_Code use
     (Rc_Success => 0, Rc_Operations_Error => 1, Rc_Protocol_Error => 2,
      Rc_Time_Limit_Exceeded => 3, Rc_Size_Limit_Exceeded => 4,
      Rc_Auth_Method_Not_Supported => 5, Rc_No_Such_Object => 6,
      Rc_Invalid_Credentials => 7, Rc_Insufficient_Access_Rights => 8,
      Rc_Busy => 9, Rc_Unavailable => 10);
   pragma Convention (C, Result_Code);

   -- Standard LDAP ports.
   Ldap_Port  : constant := 389;
   Ldaps_Port : constant := 636;


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "ldap_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "ldap_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "ldap_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "ldap_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "ldap_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Ldap;
