// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Shared error types for the proven-servers ReScript binding layer.
//
// Provides a unified error variant that aggregates protocol-specific
// error conditions alongside the core ResultCode from ProvenCore.
// All proven-servers FFI calls return result<'a, provenError> so that
// callers get a single, exhaustive error surface to match against.
//
// This module re-exports ProvenCore.resultCode for convenience and
// adds protocol-context wrappers (e.g. which protocol, which operation)
// so upstream code can produce actionable diagnostics without losing
// type safety.

// ===========================================================================
// Error context
// ===========================================================================

/// Identifies the protocol that produced an error.
/// Used to tag errors originating from cross-protocol calls.
/// Covers all 98 protocols in the proven-servers suite.
type protocol =
  // Batch 1: Core protocols (v0.1.0)
  | Httpd
  | Dns
  | Smtp
  | Ftp
  | SshBastion
  | Mqtt
  | Grpc
  | Graphql
  | Tls
  | Firewall
  | Websocket
  // Batch 2: Additional protocols (v0.2.0)
  | Amqp
  | Cache
  | Imap
  | Ldap
  | Ntp
  | Snmp
  | Syslog
  // Batch 3: Extended protocols (v0.3.0)
  | Bgp
  | Coap
  | Dhcp
  | Irc
  | Kerberos
  | Modbus
  | Nfs
  | Ospf
  | Pop3
  | Radius
  | Rtsp
  | Socks
  | Telnet
  | Tftp
  | Vpn
  // Batch 4: More protocols (v0.4.0)
  | Opcua
  | Smb
  | Tacacs
  | Voip
  | Webdav
  | Xmpp
  // Batch 5: Database, auth, transport, security (v0.5.0)
  | Dbserver
  | Authserver
  | Ca
  | Doh
  | Doq
  | Dot
  | Nts
  | Pqc
  | Proxy
  | Loadbalancer
  | Graphdb
  | Objectstore
  | Kms
  | Ids
  | Siem
  | Stun
  // Batch 6: Application and infrastructure (v0.5.0)
  | Agentic
  | Airgap
  | Apiserver
  | Appserver
  | Backup
  | Bfd
  | Caldav
  | Carddav
  | Chat
  | Configmgmt
  | Container
  | Ctlog
  | Dds
  | Deception
  | Diode
  | Federation
  | Fileserver
  | Gameserver
  | Git
  | Hardened
  | Honeypot
  | Ldp
  | Logcollector
  | Lpd
  | Mcp
  | Mdns
  | Media
  | Metrics
  | Monitor
  | Nesy
  | Netconf
  | Neurosym
  | Ocsp
  | Odns
  | Ptp
  | Sandbox
  | Sdn
  | Semweb
  | Sparql
  | Triplestore
  | Virt
  | Wasm
  | Zerotrust
  // Catch-all for unknown protocols
  | Other(string)

/// Human-readable protocol name.
let protocolAsStr = (p: protocol): string =>
  switch p {
  | Httpd => "httpd"
  | Dns => "dns"
  | Smtp => "smtp"
  | Ftp => "ftp"
  | SshBastion => "ssh-bastion"
  | Mqtt => "mqtt"
  | Grpc => "grpc"
  | Graphql => "graphql"
  | Tls => "tls"
  | Firewall => "firewall"
  | Websocket => "websocket"
  | Amqp => "amqp"
  | Cache => "cache"
  | Imap => "imap"
  | Ldap => "ldap"
  | Ntp => "ntp"
  | Snmp => "snmp"
  | Syslog => "syslog"
  | Bgp => "bgp"
  | Coap => "coap"
  | Dhcp => "dhcp"
  | Irc => "irc"
  | Kerberos => "kerberos"
  | Modbus => "modbus"
  | Nfs => "nfs"
  | Ospf => "ospf"
  | Pop3 => "pop3"
  | Radius => "radius"
  | Rtsp => "rtsp"
  | Socks => "socks"
  | Telnet => "telnet"
  | Tftp => "tftp"
  | Vpn => "vpn"
  | Opcua => "opcua"
  | Smb => "smb"
  | Tacacs => "tacacs"
  | Voip => "voip"
  | Webdav => "webdav"
  | Xmpp => "xmpp"
  | Dbserver => "dbserver"
  | Authserver => "authserver"
  | Ca => "ca"
  | Doh => "doh"
  | Doq => "doq"
  | Dot => "dot"
  | Nts => "nts"
  | Pqc => "pqc"
  | Proxy => "proxy"
  | Loadbalancer => "loadbalancer"
  | Graphdb => "graphdb"
  | Objectstore => "objectstore"
  | Kms => "kms"
  | Ids => "ids"
  | Siem => "siem"
  | Stun => "stun"
  | Agentic => "agentic"
  | Airgap => "airgap"
  | Apiserver => "apiserver"
  | Appserver => "appserver"
  | Backup => "backup"
  | Bfd => "bfd"
  | Caldav => "caldav"
  | Carddav => "carddav"
  | Chat => "chat"
  | Configmgmt => "configmgmt"
  | Container => "container"
  | Ctlog => "ctlog"
  | Dds => "dds"
  | Deception => "deception"
  | Diode => "diode"
  | Federation => "federation"
  | Fileserver => "fileserver"
  | Gameserver => "gameserver"
  | Git => "git"
  | Hardened => "hardened"
  | Honeypot => "honeypot"
  | Ldp => "ldp"
  | Logcollector => "logcollector"
  | Lpd => "lpd"
  | Mcp => "mcp"
  | Mdns => "mdns"
  | Media => "media"
  | Metrics => "metrics"
  | Monitor => "monitor"
  | Nesy => "nesy"
  | Netconf => "netconf"
  | Neurosym => "neurosym"
  | Ocsp => "ocsp"
  | Odns => "odns"
  | Ptp => "ptp"
  | Sandbox => "sandbox"
  | Sdn => "sdn"
  | Semweb => "semweb"
  | Sparql => "sparql"
  | Triplestore => "triplestore"
  | Virt => "virt"
  | Wasm => "wasm"
  | Zerotrust => "zerotrust"
  | Other(name) => name
  }

// ===========================================================================
// Proven error type
// ===========================================================================

/// Unified error type for all proven-servers FFI calls.
///
/// Variants cover:
/// - FFI-level failures (null handle, OOM, invalid params)
/// - Protocol-specific decode failures (unknown tag values)
/// - Transition validation failures (illegal state machine moves)
/// - Initialisation / lifecycle failures
type provenError =
  | /// The FFI returned a non-OK ResultCode.
    FfiError({code: ProvenCore.resultCode, message: string})
  | /// The library handle was null or uninitialised.
    HandleError(string)
  | /// A C-ABI tag value could not be decoded to a known variant.
    DecodeError({protocol: protocol, typeName: string, rawTag: int})
  | /// A state machine transition was rejected.
    TransitionError({
      protocol: protocol,
      fromState: string,
      toState: string,
    })
  | /// Library initialisation failed.
    InitError(string)
  | /// An operation is not supported by the current build / platform.
    UnsupportedError(string)
  | /// Catch-all for unexpected errors from the FFI layer.
    UnknownError(string)

// ===========================================================================
// Constructors
// ===========================================================================

/// Build an FfiError from a ResultCode.
let fromResultCode = (code: ProvenCore.resultCode): provenError =>
  FfiError({code, message: ProvenCore.resultDescription(code)})

/// Build a DecodeError for an unknown tag.
let unknownTag = (proto: protocol, typeName: string, rawTag: int): provenError =>
  DecodeError({protocol: proto, typeName, rawTag})

/// Build a TransitionError.
let invalidTransition = (
  proto: protocol,
  ~fromState: string,
  ~toState: string,
): provenError => TransitionError({protocol: proto, fromState, toState})

// ===========================================================================
// Formatting
// ===========================================================================

/// Human-readable error description suitable for logging.
let describe = (err: provenError): string =>
  switch err {
  | FfiError({code, message}) =>
    "FFI error (code " ++
    Belt.Int.toString(ProvenCore.resultCodeToTag(code)) ++
    "): " ++
    message
  | HandleError(msg) => "Handle error: " ++ msg
  | DecodeError({protocol, typeName, rawTag}) =>
    "Decode error in " ++
    protocolAsStr(protocol) ++
    ": unknown " ++
    typeName ++
    " tag " ++
    Belt.Int.toString(rawTag)
  | TransitionError({protocol, fromState, toState}) =>
    "Invalid transition in " ++
    protocolAsStr(protocol) ++
    ": " ++
    fromState ++
    " -> " ++
    toState
  | InitError(msg) => "Initialisation error: " ++ msg
  | UnsupportedError(msg) => "Unsupported: " ++ msg
  | UnknownError(msg) => "Unknown error: " ++ msg
  }

/// Whether this error is recoverable (transient FFI errors, decode mismatches).
let isRecoverable = (err: provenError): bool =>
  switch err {
  | FfiError({code, message: _}) =>
    switch code {
    | ProvenCore.ResultError => true
    | ProvenCore.ResultOk | ProvenCore.InvalidParam | ProvenCore.OutOfMemory | ProvenCore.NullPointer => false
    }
  | DecodeError(_) => true
  | TransitionError(_) => true
  | HandleError(_) | InitError(_) | UnsupportedError(_) | UnknownError(_) => false
  }
