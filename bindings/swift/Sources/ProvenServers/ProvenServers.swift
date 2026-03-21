// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Top-level module for proven-servers Swift bindings.
//
// Provides Swift-idiomatic wrappers around the formally-verified Zig FFI
// context pools for 10 core server protocols. Each protocol module exposes:
//   - Swift enums with Int raw values matching Idris2 ABI tags
//   - C interop declarations via @_silgen_name
//   - Throwing wrapper methods for safe, idiomatic usage
//
// Protocols:
//   ProvenHttp, ProvenDns, ProvenSmtp, ProvenSsh, ProvenFtp,
//   ProvenMqtt, ProvenGrpc, ProvenGraphql, ProvenFirewall

/// Namespace for proven-servers library metadata.
public enum ProvenServers {

    /// The library version string.
    public static let version = "0.1.0"

    /// Human-readable library description.
    public static let description = "Swift bindings for proven-servers (Idris2 ABI + Zig FFI)"

    /// Maximum context pool size shared by all protocol FFI implementations.
    public static let maxPoolSlots = 64
}
