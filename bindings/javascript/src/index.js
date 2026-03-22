// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// proven-servers — JavaScript/Deno bindings for formally verified protocol libraries.
//
// This package provides type-safe N-API/WASM wrappers for 10 core FFI protocols
// and pure-type frozen-object enum modules for 90+ additional protocol definitions.
//
// Each protocol module exposes:
//   - Object.freeze enum constants matching Idris2 ABI tags
//   - For FFI modules: N-API native addon calls or WASM imports
//   - JSDoc type annotations
//   - For FFI modules: Promise-based async API

/**
 * @module proven-servers
 * @description JavaScript/Deno bindings for the proven-servers
 *   formal-verification protocol libraries.
 */

export { ProvenError, ErrorCode, checkSlot, checkStatus } from "./error.js";
export { loadLibrary, loadNativeAddon, loadWasmModule } from "./ffi.js";

// FFI protocol modules (import individually to avoid loading all libraries):
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

// Pure type modules — re-export all enum constants for convenience.
// These have no FFI dependencies and are safe to import eagerly.

export * as agentic from "./agentic.js";
export * as airgap from "./airgap.js";
export * as amqp from "./amqp.js";
export * as apiserver from "./apiserver.js";
export * as appserver from "./appserver.js";
export * as authserver from "./authserver.js";
export * as backup from "./backup.js";
export * as bfd from "./bfd.js";
export * as bgp from "./bgp.js";
export * as ca from "./ca.js";
export * as cache from "./cache.js";
export * as caldav from "./caldav.js";
export * as carddav from "./carddav.js";
export * as chat from "./chat.js";
export * as coap from "./coap.js";
export * as configmgmt from "./configmgmt.js";
export * as container from "./container.js";
export * as ctlog from "./ctlog.js";
export * as dbserver from "./dbserver.js";
export * as dds from "./dds.js";
export * as deception from "./deception.js";
export * as dhcp from "./dhcp.js";
export * as diode from "./diode.js";
export * as doh from "./doh.js";
export * as doq from "./doq.js";
export * as dot from "./dot.js";
export * as federation from "./federation.js";
export * as fileserver from "./fileserver.js";
export * as gameserver from "./gameserver.js";
export * as git from "./git.js";
export * as graphdb from "./graphdb.js";
export * as hardened from "./hardened.js";
export * as honeypot from "./honeypot.js";
export * as http from "./http.js";
export * as ids from "./ids.js";
export * as imap from "./imap.js";
export * as irc from "./irc.js";
export * as kerberos from "./kerberos.js";
export * as kms from "./kms.js";
export * as ldap from "./ldap.js";
export * as ldp from "./ldp.js";
export * as loadbalancer from "./loadbalancer.js";
export * as logcollector from "./logcollector.js";
export * as lpd from "./lpd.js";
export * as mcp from "./mcp.js";
export * as mdns from "./mdns.js";
export * as media from "./media.js";
export * as metrics from "./metrics.js";
export * as modbus from "./modbus.js";
export * as monitor from "./monitor.js";
export * as nesy from "./nesy.js";
export * as netconf from "./netconf.js";
export * as neurosym from "./neurosym.js";
export * as nfs from "./nfs.js";
export * as ntp from "./ntp.js";
export * as nts from "./nts.js";
export * as objectstore from "./objectstore.js";
export * as ocsp from "./ocsp.js";
export * as odns from "./odns.js";
export * as opcua from "./opcua.js";
export * as ospf from "./ospf.js";
export * as pop3 from "./pop3.js";
export * as pqc from "./pqc.js";
export * as proxy from "./proxy.js";
export * as ptp from "./ptp.js";
export * as radius from "./radius.js";
export * as rtsp from "./rtsp.js";
export * as sandbox from "./sandbox.js";
export * as sdn from "./sdn.js";
export * as semweb from "./semweb.js";
export * as siem from "./siem.js";
export * as smb from "./smb.js";
export * as snmp from "./snmp.js";
export * as socks from "./socks.js";
export * as sparql from "./sparql.js";
export * as ssh from "./ssh.js";
export * as stun from "./stun.js";
export * as syslog from "./syslog.js";
export * as tacacs from "./tacacs.js";
export * as telnet from "./telnet.js";
export * as tftp from "./tftp.js";
export * as triplestore from "./triplestore.js";
export * as virt from "./virt.js";
export * as voip from "./voip.js";
export * as vpn from "./vpn.js";
export * as wasm from "./wasm.js";
export * as webdav from "./webdav.js";
export * as websocket from "./websocket.js";
export * as xmpp from "./xmpp.js";
export * as zerotrust from "./zerotrust.js";
