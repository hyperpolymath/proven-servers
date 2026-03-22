(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Reverse proxy bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-proxy/ffi/zig/src/proxy.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for proxy modes, hop-by-hop headers,
    cache directives, and error codes. *)

(** Proxy operating modes matching [ProxyMode] in proxy.zig. *)
type proxy_mode = Forward | Reverse

(** Hop-by-hop headers matching [HopByHopHeader] in proxy.zig. *)
type hop_by_hop_header =
  | Connection | Keep_alive | Proxy_auth | Proxy_authz
  | Te | Trailers | Transfer_encoding | Upgrade

(** Cache directives matching [CacheDirective] in proxy.zig. *)
type cache_directive =
  | No_cache | No_store | Max_age | Public | Private | Must_revalidate

(** Proxy error codes matching [ProxyError] in proxy.zig. *)
type proxy_error = Bad_gateway | Gateway_timeout | Upstream_refused | Upstream_tls

(** Convert a proxy mode to its ABI tag value. *)
let proxy_mode_to_tag = function
  | Forward -> 0 | Reverse -> 1

(** Decode a proxy mode from its ABI tag value. *)
let proxy_mode_of_tag = function
  | 0 -> Some Forward | 1 -> Some Reverse | _ -> None

(** Convert a hop-by-hop header to its ABI tag value. *)
let hop_by_hop_header_to_tag = function
  | Connection -> 0 | Keep_alive -> 1 | Proxy_auth -> 2 | Proxy_authz -> 3
  | Te -> 4 | Trailers -> 5 | Transfer_encoding -> 6 | Upgrade -> 7

(** Decode a hop-by-hop header from its ABI tag value. *)
let hop_by_hop_header_of_tag = function
  | 0 -> Some Connection | 1 -> Some Keep_alive | 2 -> Some Proxy_auth
  | 3 -> Some Proxy_authz | 4 -> Some Te | 5 -> Some Trailers
  | 6 -> Some Transfer_encoding | 7 -> Some Upgrade | _ -> None

(** Convert a cache directive to its ABI tag value. *)
let cache_directive_to_tag = function
  | No_cache -> 0 | No_store -> 1 | Max_age -> 2
  | Public -> 3 | Private -> 4 | Must_revalidate -> 5

(** Decode a cache directive from its ABI tag value. *)
let cache_directive_of_tag = function
  | 0 -> Some No_cache | 1 -> Some No_store | 2 -> Some Max_age
  | 3 -> Some Public | 4 -> Some Private | 5 -> Some Must_revalidate | _ -> None

(** Convert a proxy error to its ABI tag value. *)
let proxy_error_to_tag = function
  | Bad_gateway -> 0 | Gateway_timeout -> 1
  | Upstream_refused -> 2 | Upstream_tls -> 3

(** Decode a proxy error from its ABI tag value. *)
let proxy_error_of_tag = function
  | 0 -> Some Bad_gateway | 1 -> Some Gateway_timeout
  | 2 -> Some Upstream_refused | 3 -> Some Upstream_tls | _ -> None

(* --- C FFI declarations --- *)

external c_proxy_abi_version : unit -> int = "proxy_abi_version"
external c_proxy_create_context : unit -> int = "proxy_create_context"
external c_proxy_destroy_context : int -> unit = "proxy_destroy_context"
external c_proxy_can_transition : int -> int -> int = "proxy_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_proxy]. *)
let abi_version () = c_proxy_abi_version ()

(** Create a new proxy context. *)
let create_context () =
  Proven_error.from_slot (c_proxy_create_context ())

(** Destroy a proxy context, releasing its slot. *)
let destroy_context slot = c_proxy_destroy_context slot

(** Stateless query: check whether a proxy mode transition is valid. *)
let can_transition ~from ~to_ =
  c_proxy_can_transition (proxy_mode_to_tag from) (proxy_mode_to_tag to_) = 1
