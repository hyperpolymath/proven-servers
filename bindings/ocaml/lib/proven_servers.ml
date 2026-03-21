(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Top-level module for proven-servers OCaml bindings.

    Re-exports all 10 core protocol modules and the shared error type.
    Each protocol module provides OCaml variant types matching the Idris2
    ABI enums and safe wrapper functions returning [result] types.

    {2 Usage}

    {[
      open Proven_servers
      let ctx = Proven_httpd.create_context ()
    ]}

    Or use individual modules directly:

    {[
      let result = Proven_dns.create_context ()
    ]} *)

module Error = Proven_error
module Httpd = Proven_httpd
module Dns = Proven_dns
module Smtp = Proven_smtp
module Ftp = Proven_ftp
module Ssh_bastion = Proven_ssh_bastion
module Mqtt = Proven_mqtt
module Grpc = Proven_grpc
module Graphql = Proven_graphql
module Tls = Proven_tls
module Firewall = Proven_firewall
