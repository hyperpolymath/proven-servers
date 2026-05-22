(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** WebAssembly runtime bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-wasm/ffi/zig/src/wasm.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for WASM value types, extern kinds,
    and mutability. *)

(** WASM value types matching [ValType] in wasm.zig. *)
type val_type = I32 | I64 | F32 | F64 | V128 | Func_ref | Extern_ref

(** WASM extern kinds matching [ExternKind] in wasm.zig. *)
type extern_kind = Func_extern | Table_extern | Mem_extern | Global_extern

(** WASM global mutability matching [Mutability] in wasm.zig. *)
type mutability = Immutable | Mutable

(** Convert a value type to its ABI tag value. *)
let val_type_to_tag = function
  | I32 -> 0 | I64 -> 1 | F32 -> 2 | F64 -> 3
  | V128 -> 4 | Func_ref -> 5 | Extern_ref -> 6

(** Decode a value type from its ABI tag value. *)
let val_type_of_tag = function
  | 0 -> Some I32 | 1 -> Some I64 | 2 -> Some F32 | 3 -> Some F64
  | 4 -> Some V128 | 5 -> Some Func_ref | 6 -> Some Extern_ref | _ -> None

(** Convert an extern kind to its ABI tag value. *)
let extern_kind_to_tag = function
  | Func_extern -> 0 | Table_extern -> 1 | Mem_extern -> 2 | Global_extern -> 3

(** Decode an extern kind from its ABI tag value. *)
let extern_kind_of_tag = function
  | 0 -> Some Func_extern | 1 -> Some Table_extern
  | 2 -> Some Mem_extern | 3 -> Some Global_extern | _ -> None

(** Convert a mutability to its ABI tag value. *)
let mutability_to_tag = function
  | Immutable -> 0 | Mutable -> 1

(** Decode a mutability from its ABI tag value. *)
let mutability_of_tag = function
  | 0 -> Some Immutable | 1 -> Some Mutable | _ -> None

(* --- C FFI declarations --- *)

external c_wasm_abi_version : unit -> int = "wasm_abi_version"
external c_wasm_create_context : unit -> int = "wasm_create_context"
external c_wasm_destroy_context : int -> unit = "wasm_destroy_context"
external c_wasm_can_transition : int -> int -> int = "wasm_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_wasm]. *)
let abi_version () = c_wasm_abi_version ()

(** Create a new WASM context. *)
let create_context () =
  Proven_error.from_slot (c_wasm_create_context ())

(** Destroy a WASM context, releasing its slot. *)
let destroy_context slot = c_wasm_destroy_context slot

(** Stateless query: check whether a value type transition is valid. *)
let can_transition ~from ~to_ =
  c_wasm_can_transition (val_type_to_tag from) (val_type_to_tag to_) = 1
