-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Top-level re-export module for proven-servers Haskell bindings.
--
-- Provides convenient access to all 10 core protocol modules, the
-- shared error type, and the raw FFI declarations. Each protocol
-- module exports ADTs matching the Idris2 ABI enums and safe wrapper
-- functions returning @Either ProvenError a@.
--
-- == Usage
--
-- > import qualified ProvenServers.Httpd as Httpd
-- > import qualified ProvenServers.Dns   as Dns
-- > import ProvenServers.Error (ProvenError(..))
--
-- Or import everything via this umbrella module:
--
-- > import ProvenServers

module ProvenServers
  ( -- * Shared types
    module ProvenServers.Error
    -- * Protocol modules (re-exported qualified)
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

import ProvenServers.Error
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
