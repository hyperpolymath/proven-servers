# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers do
  @moduledoc """
  Elixir bindings for the proven-servers protocol ABI types.

  This library provides idiomatic Elixir types mirroring the Idris2 ABI
  definitions (`src/abi/`) and the Rust bindings (`bindings/rust/src/`).
  All tag values, state machines, and validation logic are faithfully
  reproduced from the formally verified Idris2 specifications.

  ## Modules

    * `ProvenServers.Core` — Result codes, platform types, opaque handles
    * `ProvenServers.Error` — Shared error types across all protocols
    * `ProvenServers.Http` — HTTP methods, status codes, content types, request lifecycle
    * `ProvenServers.Dns` — DNS record types, response codes, domain validation
    * `ProvenServers.Smtp` — SMTP commands, reply codes, session state machine
    * `ProvenServers.Ftp` — FTP session states, transfer types, data modes
    * `ProvenServers.SshBastion` — SSH message types, auth, channel/bastion states
    * `ProvenServers.Mqtt` — MQTT QoS levels, packet types, directions
    * `ProvenServers.Grpc` — gRPC status codes, stream types, HTTP/2 stream state machine
    * `ProvenServers.Graphql` — GraphQL operation types, type kinds, directive locations
    * `ProvenServers.Tls` — TLS versions, cipher suites, handshake state machine
    * `ProvenServers.Firewall` — Actions, protocols, chains, connection states
    * `ProvenServers.Websocket` — WebSocket opcodes, close codes, frame validation

  ## Tag Compatibility

  All enum-like types use atoms internally but provide `from_tag/1` and
  `to_tag/1` functions that produce the same integer values as the Idris2
  ABI and Rust `#[repr(u8)]` enums. This ensures wire-level compatibility
  across language boundaries.
  """
end
