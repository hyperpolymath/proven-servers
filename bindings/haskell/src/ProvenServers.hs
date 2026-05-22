-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Top-level re-export module for proven-servers Haskell bindings.
--
-- Re-exports the shared error type, FFI infrastructure, and the
-- original 10 FFI-backed protocol modules.
--
-- The remaining 88+ protocol type modules should be imported qualified
-- to avoid name collisions (many export @Command@, @State@, etc.):
--
-- > import qualified ProvenServers.Amqp      as Amqp
-- > import qualified ProvenServers.Pop3      as Pop3
-- > import qualified ProvenServers.Bgp       as Bgp
-- > import qualified ProvenServers.Agentic   as Agentic
-- > import qualified ProvenServers.Zerotrust as Zerotrust
--
-- See the @.cabal@ file for the full list of 110 exposed modules.

module ProvenServers
  ( -- * Shared types
    module ProvenServers.Error
    -- * FFI infrastructure
  , module ProvenServers.FFI
    -- * Core ABI types
  , module ProvenServers.Core
    -- * Protocol modules (FFI-backed)
  , module ProvenServers.Httpd
  , module ProvenServers.Dns
  , module ProvenServers.Smtp
  , module ProvenServers.Ftp
  , module ProvenServers.SshBastion
  , module ProvenServers.Mqtt
  , module ProvenServers.Grpc
  , module ProvenServers.Graphql
  , module ProvenServers.Tls
  , module ProvenServers.Firewall
  ) where

-- Shared infrastructure
import ProvenServers.Error
import ProvenServers.FFI
import ProvenServers.Core

-- FFI-backed protocol modules (original 10)
import ProvenServers.Httpd
import ProvenServers.Dns
import ProvenServers.Smtp
import ProvenServers.Ftp
import ProvenServers.SshBastion
import ProvenServers.Mqtt
import ProvenServers.Grpc
import ProvenServers.Graphql
import ProvenServers.Tls
import ProvenServers.Firewall

-- NOTE: The remaining 88+ protocol type modules are available but must
-- be imported qualified due to overlapping type names.  See the .cabal
-- file for the full list:
--
--   ProvenServers.Agentic, ProvenServers.Airgap, ProvenServers.Amqp,
--   ProvenServers.Apiserver, ProvenServers.Appserver,
--   ProvenServers.Authserver, ProvenServers.Backup, ProvenServers.Bfd,
--   ProvenServers.Bgp, ProvenServers.Ca, ProvenServers.Cache,
--   ProvenServers.Caldav, ProvenServers.Carddav, ProvenServers.Chat,
--   ProvenServers.Coap, ProvenServers.Configmgmt,
--   ProvenServers.Container, ProvenServers.Ctlog,
--   ProvenServers.Dbserver, ProvenServers.Dds, ProvenServers.Deception,
--   ProvenServers.Dhcp, ProvenServers.Diode, ProvenServers.Doh,
--   ProvenServers.Doq, ProvenServers.Dot, ProvenServers.Federation,
--   ProvenServers.Fileserver, ProvenServers.FirewallTypes,
--   ProvenServers.FtpTypes, ProvenServers.Gameserver,
--   ProvenServers.Git, ProvenServers.Graphdb,
--   ProvenServers.GraphqlTypes, ProvenServers.GrpcTypes,
--   ProvenServers.Hardened, ProvenServers.Honeypot, ProvenServers.Http,
--   ProvenServers.Ids, ProvenServers.Imap, ProvenServers.Irc,
--   ProvenServers.Kerberos, ProvenServers.Kms, ProvenServers.Ldap,
--   ProvenServers.Ldp, ProvenServers.Loadbalancer,
--   ProvenServers.Logcollector, ProvenServers.Lpd, ProvenServers.Mcp,
--   ProvenServers.Mdns, ProvenServers.Media, ProvenServers.Metrics,
--   ProvenServers.Modbus, ProvenServers.Monitor,
--   ProvenServers.MqttTypes, ProvenServers.Nesy,
--   ProvenServers.Netconf, ProvenServers.Neurosym, ProvenServers.Nfs,
--   ProvenServers.Ntp, ProvenServers.Nts, ProvenServers.Objectstore,
--   ProvenServers.Ocsp, ProvenServers.Odns, ProvenServers.Opcua,
--   ProvenServers.Ospf, ProvenServers.Pop3, ProvenServers.Pqc,
--   ProvenServers.Proxy, ProvenServers.Ptp, ProvenServers.Radius,
--   ProvenServers.Rtsp, ProvenServers.Sandbox, ProvenServers.Sdn,
--   ProvenServers.Semweb, ProvenServers.Siem, ProvenServers.Smb,
--   ProvenServers.SmtpTypes, ProvenServers.Snmp, ProvenServers.Socks,
--   ProvenServers.Sparql, ProvenServers.Ssh, ProvenServers.Stun,
--   ProvenServers.Syslog, ProvenServers.Tacacs, ProvenServers.Telnet,
--   ProvenServers.Tftp, ProvenServers.Triplestore, ProvenServers.Virt,
--   ProvenServers.Voip, ProvenServers.Vpn, ProvenServers.Wasm,
--   ProvenServers.Webdav, ProvenServers.Websocket, ProvenServers.Xmpp,
--   ProvenServers.Zerotrust
