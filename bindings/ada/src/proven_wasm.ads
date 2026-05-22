-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-wasm protocol (WebAssembly Runtime).
--
-- Enumerations match the Idris2 ABI tag definitions.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Wasm is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Value types (tags 0-6).
   type Val_Type is
     (Vt_I32, Vt_I64, Vt_F32, Vt_F64, Vt_V128, Vt_Func_Ref, Vt_Extern_Ref);
   for Val_Type use
     (Vt_I32 => 0, Vt_I64 => 1, Vt_F32 => 2, Vt_F64 => 3,
      Vt_V128 => 4, Vt_Func_Ref => 5, Vt_Extern_Ref => 6);
   pragma Convention (C, Val_Type);

   -- External kinds (tags 0-3).
   type Extern_Kind is (Ek_Func, Ek_Table, Ek_Mem, Ek_Global);
   for Extern_Kind use (Ek_Func => 0, Ek_Table => 1, Ek_Mem => 2, Ek_Global => 3);
   pragma Convention (C, Extern_Kind);

   -- Mutability (tags 0-1).
   type Wasm_Mutability is (Mut_Immutable, Mut_Mutable);
   for Wasm_Mutability use (Mut_Immutable => 0, Mut_Mutable => 1);
   pragma Convention (C, Wasm_Mutability);

   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "wasm_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "wasm_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "wasm_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "wasm_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "wasm_can_transition");


   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);


end Proven_Wasm;
