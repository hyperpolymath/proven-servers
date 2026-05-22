-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TypedFrameRouter: Core types for a generalised typed frame-level router.
--
-- The router accepts connections on one frame family and transparently
-- translates/splices them to an endpoint on another frame family. It
-- operates at the frame/stream layer, not the application layer. Bytes
-- flow through without parsing, copying to userspace (on Linux via
-- splice(2)), or modification.
--
-- Supports any frame translation: IPv4, IPv6, FibreChannel, iSCSI,
-- InfiniBand, BLE, Raw, and future families.
--
-- This module defines the core types. Formal proofs are in TypedFrameRouterABI.

module TypedFrameRouter

import public TypedFrameRouter.Types

%default total
