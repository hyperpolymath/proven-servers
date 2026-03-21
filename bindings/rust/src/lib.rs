// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! # proven-servers-rs
//!
//! Rust bindings for the proven-servers formally verified protocol ABI.
//!
//! This crate provides idiomatic Rust types that mirror the Idris2 ABI
//! definitions in `src/abi/` and the per-protocol type modules. Every enum
//! uses `#[repr(u8)]` to match the C-compatible tag values defined in the
//! `*ABI.Layout` modules, ensuring seamless interop with the Zig FFI layer.
//!
//! ## Protocols covered
//!
//! | Module       | Protocol      | Idris2 source                          |
//! |--------------|---------------|----------------------------------------|
//! | [`core`]     | Core ABI      | `src/abi/Types.idr`, `Layout.idr`      |
//! | [`http`]     | HTTP/1.1+     | `protocols/proven-httpd/src/`           |
//! | [`grpc`]     | gRPC/HTTP2    | `protocols/proven-grpc/src/`            |
//! | [`graphql`]  | GraphQL       | `protocols/proven-graphql/src/`         |
//! | [`websocket`]| WebSocket     | `protocols/proven-ws/src/`              |
//! | [`mqtt`]     | MQTT 3.1.1+   | `protocols/proven-mqtt/src/`            |
//! | [`dns`]      | DNS           | `protocols/proven-dns/src/`             |
//!
//! ## FFI
//!
//! Enable the `ffi` feature to link against `libproven_servers` (the Zig FFI
//! layer). Without it, this crate is a pure Rust type library with no foreign
//! dependencies.

pub mod core;
pub mod dns;
pub mod graphql;
pub mod grpc;
pub mod http;
pub mod mqtt;
pub mod websocket;
