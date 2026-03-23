-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GrooveProxy: Core types for the Groove IPv4→IPv6 frame-level proxy.
--
-- The proxy accepts IPv4 TCP connections and transparently splices them
-- to an IPv6 endpoint. It operates at the TCP stream layer (Layer 4),
-- not the HTTP application layer (Layer 7). Bytes flow through without
-- parsing, copying to userspace (on Linux via splice(2)), or modification.
--
-- This module defines the core types. Formal proofs are in GrooveProxyABI.

module GrooveProxy

import public GrooveProxy.Types

%default total
