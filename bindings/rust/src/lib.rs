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
//! ## Architecture
//!
//! The crate has two layers:
//!
//! 1. **Type definitions** (always available): Pure Rust types mirroring the
//!    Idris2 ABI. No foreign dependencies. Modules: [`core`], [`http`],
//!    [`dns`], [`smtp`], [`ftp`], [`ssh`], [`mqtt`], [`grpc`], [`graphql`],
//!    [`websocket`], [`amqp`], [`cache`], [`imap`], [`ldap`], [`ntp`],
//!    [`snmp`], [`syslog`].
//!
//! 2. **FFI wrappers** (behind the `ffi` feature): Safe Rust functions that
//!    call into the Zig-compiled `libproven_*` shared libraries. Each
//!    protocol's FFI module wraps `extern "C"` declarations with proper
//!    error handling via [`error::ProvenError`]. Modules: [`ffi_httpd`],
//!    [`ffi_dns`], [`ffi_smtp`], [`ffi_ftp`], [`ffi_ssh`], [`ffi_mqtt`],
//!    [`ffi_grpc`], [`ffi_graphql`], [`ffi_firewall`].
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
//! ## FFI wrappers (behind `ffi` feature)
//!
//! | Module           | Protocol       | Zig source                              |
//! |------------------|----------------|-----------------------------------------|
//! | [`ffi_httpd`]    | HTTP/1.1+      | `proven-httpd/ffi/zig/src/httpd.zig`    |
//! | [`ffi_dns`]      | DNS            | `proven-dns/ffi/zig/src/dns.zig`        |
//! | [`ffi_smtp`]     | SMTP           | `proven-smtp/ffi/zig/src/smtp.zig`      |
//! | [`ffi_ftp`]      | FTP            | `proven-ftp/ffi/zig/src/ftp.zig`        |
//! | [`ffi_ssh`]      | SSH Bastion    | `proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig` |
//! | [`ffi_mqtt`]     | MQTT           | `proven-mqtt/ffi/zig/src/mqtt.zig`      |
//! | [`ffi_grpc`]     | gRPC           | `proven-grpc/ffi/zig/src/grpc.zig`      |
//! | [`ffi_graphql`]  | GraphQL        | `proven-graphql/ffi/zig/src/graphql.zig`|
//! | [`ffi_firewall`] | Firewall       | `proven-firewall/ffi/zig/src/firewall.zig` |
//!
//! ## FFI
//!
//! Enable the `ffi` feature to link against the Zig FFI libraries.
//! Without it, this crate is a pure Rust type library with no foreign
//! dependencies.

// =========================================================================
// Type definition modules (always available)
// =========================================================================

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

// =========================================================================
// Shared error type (v0.3.0)
// =========================================================================

pub mod error;

// =========================================================================
// FFI macro infrastructure (v0.3.0)
// =========================================================================

#[macro_use]
pub mod ffi_macros;

// =========================================================================
// FFI wrapper modules (v0.3.0, behind `ffi` feature flag)
// =========================================================================

pub mod ffi_httpd;
pub mod ffi_dns;
pub mod ffi_smtp;
pub mod ffi_ftp;
pub mod ffi_ssh;
pub mod ffi_mqtt;
pub mod ffi_grpc;
pub mod ffi_graphql;
pub mod ffi_firewall;
