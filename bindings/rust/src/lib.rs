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
//! | [`ssh`]      | SSH Bastion   | `protocols/proven-ssh-bastion/src/`     |
//! | [`amqp`]     | AMQP 0-9-1    | `protocols/proven-amqp/src/`            |
//! | [`ldap`]     | LDAP          | `protocols/proven-ldap/src/`            |
//! | [`smtp`]     | SMTP          | `protocols/proven-smtp/src/`            |
//! | [`ftp`]      | FTP           | `protocols/proven-ftp/src/`             |
//! | [`cache`]    | Redis/Memcache| `protocols/proven-cache/src/`           |
//! | [`ntp`]      | NTP           | `protocols/proven-ntp/src/`             |
//! | [`syslog`]   | Syslog        | `protocols/proven-syslog/src/`          |
//! | [`snmp`]     | SNMP          | `protocols/proven-snmp/src/`            |
//! | [`imap`]     | IMAP          | `protocols/proven-imap/src/`            |
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

// Batch 2: 10 additional protocols (v0.2.0)
pub mod amqp;
pub mod cache;
pub mod ftp;
pub mod imap;
pub mod ldap;
pub mod ntp;
pub mod smtp;
pub mod snmp;
pub mod ssh;
pub mod syslog;
