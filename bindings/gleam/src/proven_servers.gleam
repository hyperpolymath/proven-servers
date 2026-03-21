//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Root module for the proven_servers Gleam bindings.
////
//// Each submodule mirrors the corresponding Idris2 ABI definitions
//// and Rust bindings in the proven-servers repository:
////
//// - `proven_servers/core` -- Result codes, platform types, alignment utilities
//// - `proven_servers/error` -- Shared error types across all protocols
//// - `proven_servers/http` -- HTTP methods, status codes, request lifecycle
//// - `proven_servers/dns` -- Record types, response codes, domain validation
//// - `proven_servers/smtp` -- SMTP commands, reply codes, session state machine
//// - `proven_servers/ftp` -- FTP session states, transfer types, commands
//// - `proven_servers/ssh_bastion` -- SSH message types, auth, channel/bastion states
//// - `proven_servers/mqtt` -- QoS levels, packet types, directions
//// - `proven_servers/grpc` -- gRPC status codes, stream types, state machine
//// - `proven_servers/graphql` -- Operation types, type kinds, directive locations
//// - `proven_servers/tls` -- TLS versions, cipher suites, handshake state machine
//// - `proven_servers/firewall` -- Actions, protocols, chains, connection states
//// - `proven_servers/websocket` -- Opcodes, close codes, frame validation

/// Library version string.
pub const version = "0.1.0"
