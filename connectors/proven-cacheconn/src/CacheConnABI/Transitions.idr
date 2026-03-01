-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CacheConnABI.Transitions: Valid state transition proofs for cache connections.
--
-- State machine:
--
--   Disconnected --Connect--> Connected --Degrade--> Degraded
--        ^                      |   |                  |   |
--        |                      |   |                  |   |
--       Reset                   |   +--ConnDrop-->     |   |
--        |                      |                 |    |   |
--        +--- Failed <----------+-- FullFailure --+----+   |
--                                                          |
--        +--- Disconnected <--- Connected <--- Recover ---+
--
-- Every arrow has exactly one ValidTransition constructor.

module CacheConnABI.Transitions

import CacheConn.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition: exhaustive enumeration of legal state transitions.
---------------------------------------------------------------------------

||| Proof witness that a state transition is valid.
public export
data ValidTransition : CacheState -> CacheState -> Type where
  ||| Disconnected -> Connected (connection established).
  Connect     : ValidTransition Disconnected Connected
  ||| Disconnected -> Failed (connection attempt failed).
  ConnectFail : ValidTransition Disconnected Failed
  ||| Connected -> Disconnected (graceful disconnect).
  Disconnect  : ValidTransition Connected Disconnected
  ||| Connected -> Degraded (partial backend impairment).
  Degrade     : ValidTransition Connected Degraded
  ||| Connected -> Failed (connection dropped).
  ConnDrop    : ValidTransition Connected Failed
  ||| Degraded -> Connected (backend recovered).
  Recover     : ValidTransition Degraded Connected
  ||| Degraded -> Failed (full backend failure).
  FullFailure : ValidTransition Degraded Failed
  ||| Failed -> Disconnected (reset the failed connection).
  Reset       : ValidTransition Failed Disconnected

||| Show instance for ValidTransition.
public export
Show (ValidTransition from to) where
  show Connect     = "Connect"
  show ConnectFail = "ConnectFail"
  show Disconnect  = "Disconnect"
  show Degrade     = "Degrade"
  show ConnDrop    = "ConnDrop"
  show Recover     = "Recover"
  show FullFailure = "FullFailure"
  show Reset       = "Reset"

---------------------------------------------------------------------------
-- CanOperate: proof that cache operations are permitted.
---------------------------------------------------------------------------

||| Proof witness that cache operations can be executed.
||| Both Connected and Degraded permit operations — Degraded may have
||| reduced performance or partial availability but still accepts requests.
public export
data CanOperate : CacheState -> Type where
  ||| Operations are allowed when fully connected.
  OperateConnected : CanOperate Connected
  ||| Operations are allowed when degraded (with possible reduced SLA).
  OperateDegraded  : CanOperate Degraded

---------------------------------------------------------------------------
-- CanFlush: proof that a full cache flush is permitted.
---------------------------------------------------------------------------

||| Proof witness that the cache can be fully flushed.
||| Only Connected permits flush — Degraded state might lose data during
||| a flush if the backend is partially unavailable.
public export
data CanFlush : CacheState -> Type where
  ||| Flush is permitted only when fully connected.
  FlushConnected : CanFlush Connected

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Proof that you cannot operate when Disconnected.
public export
disconnectedCantOperate : CanOperate Disconnected -> Void
disconnectedCantOperate x impossible

||| Proof that you cannot operate when Failed.
public export
failedCantOperate : CanOperate Failed -> Void
failedCantOperate x impossible

||| Proof that you cannot flush when Disconnected.
public export
disconnectedCantFlush : CanFlush Disconnected -> Void
disconnectedCantFlush x impossible

||| Proof that you cannot flush when Degraded.
public export
degradedCantFlush : CanFlush Degraded -> Void
degradedCantFlush x impossible

||| Proof that you cannot flush when Failed.
public export
failedCantFlush : CanFlush Failed -> Void
failedCantFlush x impossible

---------------------------------------------------------------------------
-- Decidability
---------------------------------------------------------------------------

||| Decide at runtime whether a given state permits cache operations.
public export
canOperate : (s : CacheState) -> Dec (CanOperate s)
canOperate Disconnected = No disconnectedCantOperate
canOperate Connected    = Yes OperateConnected
canOperate Degraded     = Yes OperateDegraded
canOperate Failed       = No failedCantOperate

||| Decide at runtime whether a given state permits a cache flush.
public export
canFlush : (s : CacheState) -> Dec (CanFlush s)
canFlush Disconnected = No disconnectedCantFlush
canFlush Connected    = Yes FlushConnected
canFlush Degraded     = No degradedCantFlush
canFlush Failed       = No failedCantFlush
