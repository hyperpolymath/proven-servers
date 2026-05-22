# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# proven_servers — Python bindings for the proven-servers Zig FFI libraries.
#
# This package provides type-safe ctypes wrappers for 10 core FFI protocols
# and pure-type enum modules for 90+ additional protocol definitions.
#
# Each protocol module exposes:
#   - IntEnum classes matching Idris2 ABI tags
#   - For FFI modules: ctypes wrapper functions calling the Zig shared library
#   - For FFI modules: a context manager for session lifecycle (create/destroy)
#   - Full type hints and docstrings

"""proven_servers — Python bindings for formally verified protocol libraries."""

__version__ = "0.1.0"
__author__ = "Jonathan D.A. Jewell"
__license__ = "MPL-2.0"

from proven_servers.error import ProvenError, ProvenErrorCode
from proven_servers.ffi import get_library_path, load_library

__all__ = [
    "ProvenError",
    "ProvenErrorCode",
    "get_library_path",
    "load_library",
    # FFI protocol modules (import individually):
    # proven_servers.httpd
    # proven_servers.dns
    # proven_servers.smtp
    # proven_servers.ftp
    # proven_servers.ssh_bastion
    # proven_servers.mqtt
    # proven_servers.grpc
    # proven_servers.graphql
    # proven_servers.tls
    # proven_servers.firewall
    #
    # Pure type modules (import individually):
    # proven_servers.agentic
    # proven_servers.airgap
    # proven_servers.amqp
    # proven_servers.apiserver
    # proven_servers.appserver
    # proven_servers.authserver
    # proven_servers.backup
    # proven_servers.bfd
    # proven_servers.bgp
    # proven_servers.ca
    # proven_servers.cache
    # proven_servers.caldav
    # proven_servers.carddav
    # proven_servers.chat
    # proven_servers.coap
    # proven_servers.configmgmt
    # proven_servers.container
    # proven_servers.ctlog
    # proven_servers.dbserver
    # proven_servers.dds
    # proven_servers.deception
    # proven_servers.dhcp
    # proven_servers.diode
    # proven_servers.doh
    # proven_servers.doq
    # proven_servers.dot
    # proven_servers.federation
    # proven_servers.fileserver
    # proven_servers.gameserver
    # proven_servers.git
    # proven_servers.graphdb
    # proven_servers.hardened
    # proven_servers.honeypot
    # proven_servers.http
    # proven_servers.ids
    # proven_servers.imap
    # proven_servers.irc
    # proven_servers.kerberos
    # proven_servers.kms
    # proven_servers.ldap
    # proven_servers.ldp
    # proven_servers.loadbalancer
    # proven_servers.logcollector
    # proven_servers.lpd
    # proven_servers.mcp
    # proven_servers.mdns
    # proven_servers.media
    # proven_servers.metrics
    # proven_servers.modbus
    # proven_servers.monitor
    # proven_servers.nesy
    # proven_servers.netconf
    # proven_servers.neurosym
    # proven_servers.nfs
    # proven_servers.ntp
    # proven_servers.nts
    # proven_servers.objectstore
    # proven_servers.ocsp
    # proven_servers.odns
    # proven_servers.opcua
    # proven_servers.ospf
    # proven_servers.pop3
    # proven_servers.pqc
    # proven_servers.proxy
    # proven_servers.ptp
    # proven_servers.radius
    # proven_servers.rtsp
    # proven_servers.sandbox
    # proven_servers.sdn
    # proven_servers.semweb
    # proven_servers.siem
    # proven_servers.smb
    # proven_servers.snmp
    # proven_servers.socks
    # proven_servers.sparql
    # proven_servers.ssh
    # proven_servers.stun
    # proven_servers.syslog
    # proven_servers.tacacs
    # proven_servers.telnet
    # proven_servers.tftp
    # proven_servers.triplestore
    # proven_servers.virt
    # proven_servers.voip
    # proven_servers.vpn
    # proven_servers.wasm
    # proven_servers.webdav
    # proven_servers.websocket
    # proven_servers.xmpp
    # proven_servers.zerotrust
]
