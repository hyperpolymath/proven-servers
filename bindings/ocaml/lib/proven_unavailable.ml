(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Shared fail-closed error for OCaml operations whose native C stubs have
    not been implemented. Raw Zig C exports are not OCaml runtime primitives. *)
let raise_unavailable () =
  failwith
    "proven-servers OCaml FFI is unavailable: OCaml-compatible C stubs are not implemented"
