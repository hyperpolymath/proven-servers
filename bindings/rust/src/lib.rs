// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
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
//! | [`pop3`]     | POP3          | `protocols/proven-pop3/src/`            |
//! | [`irc`]      | IRC           | `protocols/proven-irc/src/`             |
//! | [`dhcp`]     | DHCP          | `protocols/proven-dhcp/src/`            |
//! | [`radius`]   | RADIUS        | `protocols/proven-radius/src/`          |
//! | [`kerberos`] | Kerberos      | `protocols/proven-kerberos/src/`        |
//! | [`telnet`]   | Telnet        | `protocols/proven-telnet/src/`          |
//! | [`tftp`]     | TFTP          | `protocols/proven-tftp/src/`            |
//! | [`socks`]    | SOCKS5        | `protocols/proven-socks/src/`           |
//! | [`vpn`]      | VPN/IPsec     | `protocols/proven-vpn/src/`             |
//! | [`coap`]     | CoAP          | `protocols/proven-coap/src/`            |
//! | [`rtsp`]     | RTSP          | `protocols/proven-rtsp/src/`            |
//! | [`modbus`]   | Modbus        | `protocols/proven-modbus/src/`          |
//! | [`bgp`]      | BGP           | `protocols/proven-bgp/src/`             |
//! | [`ospf`]     | OSPF          | `protocols/proven-ospf/src/`            |
//! | [`nfs`]      | NFS           | `protocols/proven-nfs/src/`             |
//! | [`opcua`]    | OPC UA        | `protocols/proven-opcua/src/`           |
//! | [`smb`]      | SMB2/3        | `protocols/proven-smb/src/`             |
//! | [`tacacs`]   | TACACS+       | `protocols/proven-tacacs/src/`          |
//! | [`voip`]     | VoIP/SIP      | `protocols/proven-voip/src/`            |
//! | [`webdav`]   | WebDAV        | `protocols/proven-webdav/src/`          |
//! | [`xmpp`]     | XMPP          | `protocols/proven-xmpp/src/`           |
//! | [`dbserver`] | Database      | `protocols/proven-dbserver/src/`       |
//! | [`authserver`]| Auth Server  | `protocols/proven-authserver/src/`     |
//! | [`ca`]       | PKI/CA        | `protocols/proven-ca/src/`             |
//! | [`doh`]      | DNS-over-HTTPS| `protocols/proven-doh/src/`            |
//! | [`doq`]      | DNS-over-QUIC | `protocols/proven-doq/src/`            |
//! | [`dot`]      | DNS-over-TLS  | `protocols/proven-dot/src/`            |
//! | [`nts`]      | NTS           | `protocols/proven-nts/src/`            |
//! | [`pqc`]      | PQC           | `protocols/proven-pqc/src/`            |
//! | [`firewall`] | Firewall      | `protocols/proven-firewall/src/`       |
//! | [`proxy`]    | Proxy         | `protocols/proven-proxy/src/`          |
//! | [`loadbalancer`]| Load Balancer| `protocols/proven-loadbalancer/src/` |
//! | [`graphdb`]  | Graph DB      | `protocols/proven-graphdb/src/`        |
//! | [`objectstore`]| Object Store| `protocols/proven-objectstore/src/`    |
//! | [`kms`]      | KMS           | `protocols/proven-kms/src/`            |
//! | [`ids`]      | IDS           | `protocols/proven-ids/src/`            |
//! | [`siem`]     | SIEM          | `protocols/proven-siem/src/`           |
//! | [`stun`]     | STUN/TURN     | `protocols/proven-stun/src/`           |
//! | [`agentic`]  | Agentic AI    | `protocols/proven-agentic/src/`        |
//! | [`airgap`]   | Air Gap       | `protocols/proven-airgap/src/`         |
//! | [`apiserver`]| API Server    | `protocols/proven-apiserver/src/`      |
//! | [`appserver`]| App Server    | `protocols/proven-appserver/src/`      |
//! | [`backup`]   | Backup        | `protocols/proven-backup/src/`         |
//! | [`bfd`]      | BFD           | `protocols/proven-bfd/src/`            |
//! | [`caldav`]   | CalDAV        | `protocols/proven-caldav/src/`         |
//! | [`carddav`]  | CardDAV       | `protocols/proven-carddav/src/`        |
//! | [`chat`]     | Chat          | `protocols/proven-chat/src/`           |
//! | [`configmgmt`]| Config Mgmt | `protocols/proven-configmgmt/src/`     |
//! | [`container`]| Container     | `protocols/proven-container/src/`      |
//! | [`ctlog`]    | CT Log        | `protocols/proven-ctlog/src/`          |
//! | [`dds`]      | DDS           | `protocols/proven-dds/src/`            |
//! | [`deception`]| Deception     | `protocols/proven-deception/src/`      |
//! | [`diode`]    | Data Diode    | `protocols/proven-diode/src/`          |
//! | [`federation`]| Federation   | `protocols/proven-federation/src/`     |
//! | [`fileserver`]| File Server  | `protocols/proven-fileserver/src/`     |
//! | [`gameserver`]| Game Server  | `protocols/proven-gameserver/src/`     |
//! | [`git`]      | Git           | `protocols/proven-git/src/`            |
//! | [`hardened`] | Hardened      | `protocols/proven-hardened/src/`       |
//! | [`honeypot`] | Honeypot      | `protocols/proven-honeypot/src/`       |
//! | [`ldp`]      | LDP           | `protocols/proven-ldp/src/`            |
//! | [`logcollector`]| Log Collector| `protocols/proven-logcollector/src/` |
//! | [`lpd`]      | LPD           | `protocols/proven-lpd/src/`            |
//! | [`mcp`]      | MCP           | `protocols/proven-mcp/src/`            |
//! | [`mdns`]     | mDNS          | `protocols/proven-mdns/src/`           |
//! | [`media`]    | Media         | `protocols/proven-media/src/`          |
//! | [`metrics`]  | Metrics       | `protocols/proven-metrics/src/`        |
//! | [`monitor`]  | Monitor       | `protocols/proven-monitor/src/`        |
//! | [`nesy`]     | NeSy          | `protocols/proven-nesy/src/`           |
//! | [`netconf`]  | NETCONF       | `protocols/proven-netconf/src/`        |
//! | [`neurosym`] | Neurosym      | `protocols/proven-neurosym/src/`       |
//! | [`ocsp`]     | OCSP          | `protocols/proven-ocsp/src/`           |
//! | [`odns`]     | ODNS          | `protocols/proven-odns/src/`           |
//! | [`ptp`]      | PTP           | `protocols/proven-ptp/src/`            |
//! | [`sandbox`]  | Sandbox       | `protocols/proven-sandbox/src/`        |
//! | [`sdn`]      | SDN           | `protocols/proven-sdn/src/`            |
//! | [`semweb`]   | Semantic Web  | `protocols/proven-semweb/src/`         |
//! | [`sparql`]   | SPARQL        | `protocols/proven-sparql/src/`         |
//! | [`triplestore`]| Triplestore | `protocols/proven-triplestore/src/`    |
//! | [`virt`]     | Virt          | `protocols/proven-virt/src/`           |
//! | [`wasm`]     | WASM          | `protocols/proven-wasm/src/`           |
//! | [`zerotrust`]| Zero Trust    | `protocols/proven-zerotrust/src/`      |
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

// Batch 3: 15 additional protocols (v0.3.0)
pub mod bgp;
pub mod coap;
pub mod dhcp;
pub mod irc;
pub mod kerberos;
pub mod modbus;
pub mod nfs;
pub mod ospf;
pub mod pop3;
pub mod radius;
pub mod rtsp;
pub mod socks;
pub mod telnet;
pub mod tftp;
pub mod vpn;

// Batch 4: 6 additional protocols (v0.4.0)
pub mod opcua;
pub mod smb;
pub mod tacacs;
pub mod voip;
pub mod webdav;
pub mod xmpp;

// Batch 5: Database, auth, transport, security (v0.5.0)
pub mod dbserver;
pub mod authserver;
pub mod ca;
pub mod doh;
pub mod doq;
pub mod dot;
pub mod nts;
pub mod pqc;
pub mod firewall;
pub mod proxy;
pub mod loadbalancer;
pub mod graphdb;
pub mod objectstore;
pub mod kms;
pub mod ids;
pub mod siem;
pub mod stun;

// Batch 6: Application and infrastructure (v0.5.0)
pub mod agentic;
pub mod airgap;
pub mod apiserver;
pub mod appserver;
pub mod backup;
pub mod bfd;
pub mod caldav;
pub mod carddav;
pub mod chat;
pub mod configmgmt;
pub mod container;
pub mod ctlog;
pub mod dds;
pub mod deception;
pub mod diode;
pub mod federation;
pub mod fileserver;
pub mod gameserver;
pub mod git;
pub mod hardened;
pub mod honeypot;
pub mod ldp;
pub mod logcollector;
pub mod lpd;
pub mod mcp;
pub mod mdns;
pub mod media;
pub mod metrics;
pub mod monitor;
pub mod nesy;
pub mod netconf;
pub mod neurosym;
pub mod ocsp;
pub mod odns;
pub mod ptp;
pub mod sandbox;
pub mod sdn;
pub mod semweb;
pub mod sparql;
pub mod triplestore;
pub mod virt;
pub mod wasm;
pub mod zerotrust;

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
