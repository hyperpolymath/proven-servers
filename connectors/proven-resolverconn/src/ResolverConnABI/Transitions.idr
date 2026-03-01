-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ResolverConnABI.Transitions: Valid state transition proofs for DNS resolvers.
--
-- State machine:
--
--   Ready --Query--> Querying --QueryComplete--> Ready
--     |                |                           ^
--     |                +--StoreResult--> Cached    |
--     |                |                  |   |    |
--     +--CacheHit--> Cached               |   |    |
--     |                |                  |   |    |
--     +--InitFail-->   +--CacheExpire-----+---+----+
--                  |   |                          |
--                  |   +--RefreshQuery--> Querying |
--                  |                               |
--         Failed <-+--- QueryFail                  |
--           |                                      |
--           +---Reset---> Ready -------------------+

module ResolverConnABI.Transitions

import ResolverConn.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition
---------------------------------------------------------------------------

public export
data ValidTransition : ResolverState -> ResolverState -> Type where
  ||| Ready -> Querying (initiate DNS query).
  Query         : ValidTransition Ready Querying
  ||| Ready -> Cached (result served from cache).
  CacheHit      : ValidTransition Ready Cached
  ||| Ready -> Failed (initialisation failure).
  InitFail      : ValidTransition Ready Failed
  ||| Querying -> Ready (query completed, result delivered).
  QueryComplete : ValidTransition Querying Ready
  ||| Querying -> Cached (query completed, result stored in cache).
  StoreResult   : ValidTransition Querying Cached
  ||| Querying -> Failed (query failed).
  QueryFail     : ValidTransition Querying Failed
  ||| Cached -> Ready (cached entry expired, back to ready).
  CacheExpire   : ValidTransition Cached Ready
  ||| Cached -> Querying (refresh the cached entry).
  RefreshQuery  : ValidTransition Cached Querying
  ||| Failed -> Ready (reset the failed resolver).
  Reset         : ValidTransition Failed Ready

public export
Show (ValidTransition from to) where
  show Query         = "Query"
  show CacheHit      = "CacheHit"
  show InitFail      = "InitFail"
  show QueryComplete = "QueryComplete"
  show StoreResult   = "StoreResult"
  show QueryFail     = "QueryFail"
  show CacheExpire   = "CacheExpire"
  show RefreshQuery  = "RefreshQuery"
  show Reset         = "Reset"

---------------------------------------------------------------------------
-- CanResolve: proof that DNS queries can be initiated.
---------------------------------------------------------------------------

||| Proof that a DNS query can be initiated from the current state.
||| Only Ready permits new queries.
public export
data CanResolve : ResolverState -> Type where
  ||| Queries can be initiated when Ready.
  ResolveReady : CanResolve Ready

---------------------------------------------------------------------------
-- CanServe: proof that answers can be served.
---------------------------------------------------------------------------

||| Proof that the resolver can serve answers.
||| Both Ready (from upstream) and Cached (from local cache) can serve.
public export
data CanServe : ResolverState -> Type where
  ||| Can serve fresh results when Ready.
  ServeReady  : CanServe Ready
  ||| Can serve cached results when Cached.
  ServeCached : CanServe Cached

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

public export
queryingCantResolve : CanResolve Querying -> Void
queryingCantResolve x impossible

public export
cachedCantResolve : CanResolve Cached -> Void
cachedCantResolve x impossible

public export
failedCantResolve : CanResolve Failed -> Void
failedCantResolve x impossible

public export
queryingCantServe : CanServe Querying -> Void
queryingCantServe x impossible

public export
failedCantServe : CanServe Failed -> Void
failedCantServe x impossible

---------------------------------------------------------------------------
-- Decidability
---------------------------------------------------------------------------

public export
canResolve : (s : ResolverState) -> Dec (CanResolve s)
canResolve Ready    = Yes ResolveReady
canResolve Querying = No queryingCantResolve
canResolve Cached   = No cachedCantResolve
canResolve Failed   = No failedCantResolve

public export
canServe : (s : ResolverState) -> Dec (CanServe s)
canServe Ready    = Yes ServeReady
canServe Querying = No queryingCantServe
canServe Cached   = Yes ServeCached
canServe Failed   = No failedCantServe
