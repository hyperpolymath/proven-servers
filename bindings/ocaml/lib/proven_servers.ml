(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Top-level module for proven-servers OCaml bindings.

    Re-exports all 99 protocol modules and the shared error type.
    Each protocol module provides OCaml variant types matching the Idris2
    ABI enums and safe wrapper functions returning [result] types.

    {2 Usage}

    {[
      open Proven_servers
      let ctx = Proven_httpd.create_context ()
    ]}

    Or use individual modules directly:

    {[
      let result = Proven_dns.create_context ()
    ]} *)

module Error = Proven_error
module Agentic = Proven_agentic
module Airgap = Proven_airgap
module Amqp = Proven_amqp
module Apiserver = Proven_apiserver
module Appserver = Proven_appserver
module Authserver = Proven_authserver
module Backup = Proven_backup
module Bfd = Proven_bfd
module Bgp = Proven_bgp
module Ca = Proven_ca
module Cache = Proven_cache
module Caldav = Proven_caldav
module Carddav = Proven_carddav
module Chat = Proven_chat
module Coap = Proven_coap
module Configmgmt = Proven_configmgmt
module Container = Proven_container
module Ctlog = Proven_ctlog
module Dbserver = Proven_dbserver
module Dds = Proven_dds
module Deception = Proven_deception
module Dhcp = Proven_dhcp
module Diode = Proven_diode
module Dns = Proven_dns
module Doh = Proven_doh
module Doq = Proven_doq
module Dot = Proven_dot
module Federation = Proven_federation
module Fileserver = Proven_fileserver
module Firewall = Proven_firewall
module Ftp = Proven_ftp
module Gameserver = Proven_gameserver
module Git = Proven_git
module Graphdb = Proven_graphdb
module Graphql = Proven_graphql
module Grpc = Proven_grpc
module Hardened = Proven_hardened
module Honeypot = Proven_honeypot
module Http = Proven_http
module Httpd = Proven_httpd
module Ids = Proven_ids
module Imap = Proven_imap
module Irc = Proven_irc
module Kerberos = Proven_kerberos
module Kms = Proven_kms
module Ldap = Proven_ldap
module Ldp = Proven_ldp
module Loadbalancer = Proven_loadbalancer
module Logcollector = Proven_logcollector
module Lpd = Proven_lpd
module Mcp = Proven_mcp
module Mdns = Proven_mdns
module Media = Proven_media
module Metrics = Proven_metrics
module Modbus = Proven_modbus
module Monitor = Proven_monitor
module Mqtt = Proven_mqtt
module Nesy = Proven_nesy
module Netconf = Proven_netconf
module Neurosym = Proven_neurosym
module Nfs = Proven_nfs
module Ntp = Proven_ntp
module Nts = Proven_nts
module Objectstore = Proven_objectstore
module Ocsp = Proven_ocsp
module Odns = Proven_odns
module Opcua = Proven_opcua
module Ospf = Proven_ospf
module Pop3 = Proven_pop3
module Pqc = Proven_pqc
module Proxy = Proven_proxy
module Ptp = Proven_ptp
module Radius = Proven_radius
module Rtsp = Proven_rtsp
module Sandbox = Proven_sandbox
module Sdn = Proven_sdn
module Semweb = Proven_semweb
module Siem = Proven_siem
module Smb = Proven_smb
module Smtp = Proven_smtp
module Snmp = Proven_snmp
module Socks = Proven_socks
module Sparql = Proven_sparql
module Ssh = Proven_ssh
module Ssh_bastion = Proven_ssh_bastion
module Stun = Proven_stun
module Syslog = Proven_syslog
module Tacacs = Proven_tacacs
module Telnet = Proven_telnet
module Tftp = Proven_tftp
module Tls = Proven_tls
module Triplestore = Proven_triplestore
module Virt = Proven_virt
module Voip = Proven_voip
module Vpn = Proven_vpn
module Wasm = Proven_wasm
module Webdav = Proven_webdav
module Websocket = Proven_websocket
module Xmpp = Proven_xmpp
module Zerotrust = Proven_zerotrust
