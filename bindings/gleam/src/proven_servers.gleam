//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Root module for the proven_servers Gleam bindings.
////
//// Each submodule mirrors the corresponding Idris2 ABI definitions
//// and Rust bindings in the proven-servers repository. All 98 protocols
//// are covered with idiomatic Gleam types, to_int/from_int conversions,
//// and state machine validators where applicable.
////
//// ## Core & Infrastructure
////
//// - `proven_servers/core` -- Result codes, platform types, alignment utilities
//// - `proven_servers/error` -- Shared error types across all protocols
//// - `proven_servers/tls` -- TLS versions, cipher suites, handshake state machine
//// - `proven_servers/firewall` -- Actions, protocols, chains, connection states
//// - `proven_servers/proxy` -- Proxy modes, cache directives, hop-by-hop headers
//// - `proven_servers/loadbalancer` -- Algorithms, health checks, backend states
////
//// ## Web & Application
////
//// - `proven_servers/http` -- HTTP methods, status codes, request lifecycle
//// - `proven_servers/grpc` -- gRPC status codes, stream types, state machine
//// - `proven_servers/graphql` -- Operation types, type kinds, directive locations
//// - `proven_servers/websocket` -- Opcodes, close codes, frame validation
//// - `proven_servers/webdav` -- WebDAV methods, lock types, depth values
//// - `proven_servers/apiserver` -- Auth schemes, rate limiting, API versioning
//// - `proven_servers/appserver` -- Request types, lifecycle, deploy strategies
////
//// ## Messaging & Streaming
////
//// - `proven_servers/mqtt` -- QoS levels, packet types, directions
//// - `proven_servers/amqp` -- Frame types, exchange types, broker state machine
//// - `proven_servers/xmpp` -- Stanza types, presence, IQ types
//// - `proven_servers/irc` -- Commands, channel modes, connection lifecycle
//// - `proven_servers/chat` -- Message types, presence, room types
////
//// ## Email
////
//// - `proven_servers/smtp` -- SMTP commands, reply codes, session state machine
//// - `proven_servers/imap` -- Commands, session states, message flags
//// - `proven_servers/pop3` -- Commands, session states, response codes
////
//// ## DNS & Name Resolution
////
//// - `proven_servers/dns` -- Record types, response codes, domain validation
//// - `proven_servers/doh` -- DNS-over-HTTPS content types, wire formats
//// - `proven_servers/doq` -- DNS-over-QUIC stream types, error codes
//// - `proven_servers/dot` -- DNS-over-TLS session states, padding strategies
//// - `proven_servers/mdns` -- mDNS record types, conflict resolution
//// - `proven_servers/odns` -- Oblivious DNS roles, encapsulation formats
////
//// ## File Transfer & Storage
////
//// - `proven_servers/ftp` -- FTP session states, transfer types, commands
//// - `proven_servers/tftp` -- TFTP opcodes, transfer modes, error codes
//// - `proven_servers/nfs` -- NFS operations, file types, status codes
//// - `proven_servers/smb` -- SMB2/3 commands, dialects, share types
//// - `proven_servers/fileserver` -- File operations, permissions, lock types
//// - `proven_servers/objectstore` -- S3-compatible operations, storage classes
////
//// ## Remote Access & Network
////
//// - `proven_servers/ssh_bastion` -- SSH message types, auth, channel/bastion states
//// - `proven_servers/telnet` -- Telnet commands, options, negotiation states
//// - `proven_servers/socks` -- SOCKS5 auth, commands, address types, replies
//// - `proven_servers/vpn` -- VPN tunnel types, encryption, SA lifecycle
////
//// ## Authentication & Security
////
//// - `proven_servers/radius` -- RADIUS packet types, attributes, session states
//// - `proven_servers/kerberos` -- Message types, encryption, ticket flags
//// - `proven_servers/tacacs` -- TACACS+ packet types, authen/author/acct states
//// - `proven_servers/ldap` -- LDAP operations, search scopes, result codes
//// - `proven_servers/authserver` -- Auth methods, token types, MFA
//// - `proven_servers/ca` -- PKI/CA cert types, key algorithms, revocation
//// - `proven_servers/kms` -- Key management object types, operations
//// - `proven_servers/pqc` -- Post-quantum algorithms, NIST levels
//// - `proven_servers/nts` -- Network Time Security record types, AEAD
//// - `proven_servers/zerotrust` -- Zero trust policies, identity confidence
////
//// ## Monitoring & Logging
////
//// - `proven_servers/snmp` -- SNMP versions, PDU types, error status codes
//// - `proven_servers/syslog` -- Severity levels, facility codes, transports
//// - `proven_servers/ntp` -- NTP modes, leap indicators, clock discipline
//// - `proven_servers/metrics` -- Metric types, scrape results, aggregation
//// - `proven_servers/monitor` -- Check types, alert channels, severities
//// - `proven_servers/logcollector` -- Log levels, input formats, pipeline stages
////
//// ## Security & Defence
////
//// - `proven_servers/ids` -- Alert severities, detection methods, actions
//// - `proven_servers/siem` -- Event categories, correlation rules, alert states
//// - `proven_servers/honeypot` -- Service emulations, interaction levels
//// - `proven_servers/deception` -- Decoy types, trigger events, response actions
//// - `proven_servers/hardened` -- Hardening levels, security controls, compliance
//// - `proven_servers/sandbox` -- Execution policies, resource limits, exit reasons
//// - `proven_servers/airgap` -- Transfer directions, media types, scan results
//// - `proven_servers/diode` -- Data diode protocols, transfer states
////
//// ## Routing & Network Infrastructure
////
//// - `proven_servers/bgp` -- BGP FSM states, events, path attributes
//// - `proven_servers/ospf` -- OSPF packet types, neighbor states, LSA types
//// - `proven_servers/bfd` -- BFD session states, diagnostics, modes
//// - `proven_servers/sdn` -- SDN/OpenFlow message types, flow actions
//// - `proven_servers/ptp` -- PTP message types, clock classes, port states
////
//// ## IoT & Industrial
////
//// - `proven_servers/coap` -- CoAP methods, message types, content formats
//// - `proven_servers/modbus` -- Modbus function codes, exception codes
//// - `proven_servers/opcua` -- OPC UA service types, node classes, security modes
//// - `proven_servers/dds` -- DDS QoS policies, entity types, participant states
////
//// ## Media & Communication
////
//// - `proven_servers/voip` -- SIP methods, response codes, dialog states
//// - `proven_servers/rtsp` -- RTSP methods, transport protocols, status codes
//// - `proven_servers/media` -- Media types, codecs, stream protocols
//// - `proven_servers/stun` -- STUN/TURN message types, transport protocols
////
//// ## Databases
////
//// - `proven_servers/cache` -- Cache commands, eviction policies, data types
//// - `proven_servers/dbserver` -- Query types, data types, isolation levels
//// - `proven_servers/graphdb` -- Graph element types, query languages, traversal
////
//// ## Semantic & Linked Data
////
//// - `proven_servers/semweb` -- RDF formats, resource types
//// - `proven_servers/sparql` -- SPARQL query types, result formats
//// - `proven_servers/triplestore` -- Statements, index orders, storage backends
//// - `proven_servers/ldp` -- Container types, interaction models
////
//// ## Calendaring & Contacts
////
//// - `proven_servers/caldav` -- Calendar components, methods, scheduling
//// - `proven_servers/carddav` -- vCard properties, methods, versions
////
//// ## Infrastructure Management
////
//// - `proven_servers/container` -- Container states, operations, network modes
//// - `proven_servers/virt` -- VM states, operations, disk formats
//// - `proven_servers/configmgmt` -- Resource types, states, drift detection
//// - `proven_servers/backup` -- Backup types, schedules, compression
//// - `proven_servers/netconf` -- NETCONF operations, datastores, edit operations
//// - `proven_servers/lpd` -- Line printer commands, job statuses
////
//// ## AI & Advanced
////
//// - `proven_servers/agentic` -- Agent states, tool calls, safety checks
//// - `proven_servers/nesy` -- Neurosymbolic reasoning, proof status, constraints
//// - `proven_servers/neurosym` -- Inference modes, fusion strategies
//// - `proven_servers/mcp` -- Model Context Protocol messages, capabilities
//// - `proven_servers/wasm` -- WebAssembly value types, extern kinds
////
//// ## Trust & PKI
////
//// - `proven_servers/ctlog` -- CT log entry types, verification results
//// - `proven_servers/ocsp` -- OCSP cert/response status, hash algorithms
////
//// ## Other
////
//// - `proven_servers/federation` -- ActivityPub activity/actor types
//// - `proven_servers/gameserver` -- Session types, player/match states
//// - `proven_servers/git` -- Git protocol commands, ref types, capabilities
//// - `proven_servers/dhcp` -- DHCP message types, options, lease states

/// Library version string.
pub const version = "0.2.0"
