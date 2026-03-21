// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// proven-servers — JavaScript/Deno bindings for formally verified protocol libraries.
//
// This package provides type-safe N-API/WASM wrappers for all 10 core protocols:
// httpd, dns, smtp, ftp, ssh_bastion, mqtt, grpc, graphql, tls, firewall.
//
// Each protocol module exposes:
//   - Object.freeze enum constants matching Idris2 ABI tags
//   - N-API native addon calls or WASM imports
//   - JSDoc type annotations
//   - Promise-based async API

/**
 * @module proven-servers
 * @description JavaScript/Deno bindings for the proven-servers
 *   formal-verification protocol libraries.
 */

export { ProvenError, ErrorCode, checkSlot, checkStatus } from "./error.js";
export { loadLibrary, loadNativeAddon, loadWasmModule } from "./ffi.js";

// Protocol modules are imported individually to avoid loading all FFI
// libraries at once. Use:
//
//   import { HttpdContext } from "proven-servers/httpd";
//   import { DnsContext } from "proven-servers/dns";
//   import { SmtpContext } from "proven-servers/smtp";
//   import { FtpContext } from "proven-servers/ftp";
//   import { SshBastionContext } from "proven-servers/ssh_bastion";
//   import { MqttContext } from "proven-servers/mqtt";
//   import { GrpcContext } from "proven-servers/grpc";
//   import { GraphqlContext } from "proven-servers/graphql";
//   import { TlsContext } from "proven-servers/tls";
//   import { FirewallContext } from "proven-servers/firewall";
