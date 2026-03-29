-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DNSABI.Transitions: Valid DNS query lifecycle state transitions.
--
-- Models the DNS query processing lifecycle (RFC 1035 Section 4):
--
--   Idle --> QueryReceived --> Lookup --> ResponseBuilding --> Sent
--
-- With DNSSEC validation states layered on top:
--
--   DnssecDisabled | DnssecEnabled | DnssecKeyLoaded | DnssecValidated
--
-- The key invariants:
--   - Sent is terminal (no outbound edges).
--   - DNSSEC signing requires a loaded key (CanSign witness).
--   - Cannot skip from Idle directly to Sent.
--   - Cannot go backwards from ResponseBuilding to Idle.

module DNSABI.Transitions

%default total

---------------------------------------------------------------------------
-- DNS query lifecycle states
---------------------------------------------------------------------------

||| The lifecycle state of a DNS query context.
public export
data DnsState : Type where
  ||| Awaiting a query — no query has been parsed yet.
  Idle             : DnsState
  ||| A query has been received and parsed.
  QueryReceived    : DnsState
  ||| Zone/cache lookup is in progress.
  Lookup           : DnsState
  ||| Building the response message (adding sections).
  ResponseBuilding : DnsState
  ||| Response has been sent — context is finished.
  Sent             : DnsState

public export
Eq DnsState where
  Idle             == Idle             = True
  QueryReceived    == QueryReceived    = True
  Lookup           == Lookup           = True
  ResponseBuilding == ResponseBuilding = True
  Sent             == Sent             = True
  _                == _                = False

---------------------------------------------------------------------------
-- DNSSEC validation states
---------------------------------------------------------------------------

||| DNSSEC operational state, orthogonal to query lifecycle.
public export
data DnssecState : Type where
  ||| DNSSEC is not enabled for this context.
  DnssecDisabled  : DnssecState
  ||| DNSSEC is enabled but no signing key is loaded.
  DnssecEnabled   : DnssecState
  ||| A DNSSEC signing key has been loaded.
  DnssecKeyLoaded : DnssecState
  ||| DNSSEC validation has been performed on the response.
  DnssecValidated : DnssecState

public export
Eq DnssecState where
  DnssecDisabled  == DnssecDisabled  = True
  DnssecEnabled   == DnssecEnabled   = True
  DnssecKeyLoaded == DnssecKeyLoaded = True
  DnssecValidated == DnssecValidated = True
  _               == _               = False

---------------------------------------------------------------------------
-- ValidDnsTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a DNS lifecycle state transition is valid.
public export
data ValidDnsTransition : DnsState -> DnsState -> Type where
  ||| Idle -> QueryReceived (query arrives and is parsed).
  ReceiveQuery    : ValidDnsTransition Idle QueryReceived
  ||| QueryReceived -> Lookup (begin zone/cache lookup).
  BeginLookup     : ValidDnsTransition QueryReceived Lookup
  ||| Lookup -> ResponseBuilding (lookup complete, build response).
  BuildResponse   : ValidDnsTransition Lookup ResponseBuilding
  ||| ResponseBuilding -> Sent (response is complete and sent).
  SendResponse    : ValidDnsTransition ResponseBuilding Sent
  ||| Idle -> Sent (abort: reject malformed packet without parsing).
  AbortIdle       : ValidDnsTransition Idle Sent
  ||| QueryReceived -> Sent (abort: reject after parse, e.g. REFUSED).
  AbortReceived   : ValidDnsTransition QueryReceived Sent
  ||| Lookup -> Sent (abort: SERVFAIL during lookup).
  AbortLookup     : ValidDnsTransition Lookup Sent

---------------------------------------------------------------------------
-- ValidDnssecTransition: legal DNSSEC state changes.
---------------------------------------------------------------------------

||| Proof witness that a DNSSEC state transition is valid.
public export
data ValidDnssecTransition : DnssecState -> DnssecState -> Type where
  ||| Disabled -> Enabled (enable DNSSEC on context).
  EnableDnssec  : ValidDnssecTransition DnssecDisabled DnssecEnabled
  ||| Enabled -> KeyLoaded (load a signing key).
  LoadKey       : ValidDnssecTransition DnssecEnabled DnssecKeyLoaded
  ||| KeyLoaded -> Validated (sign and validate response).
  ValidateSig   : ValidDnssecTransition DnssecKeyLoaded DnssecValidated

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a context can add records to the response.
public export
data CanAddRecord : DnsState -> Type where
  BuildingCanAdd : CanAddRecord ResponseBuilding

||| Proof that a context can perform DNSSEC signing.
public export
data CanSign : DnssecState -> Type where
  KeyLoadedCanSign : CanSign DnssecKeyLoaded

||| Proof that a context can receive a query.
public export
data CanReceive : DnsState -> Type where
  IdleCanReceive : CanReceive Idle

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Sent state — it is terminal.
public export
sentIsTerminal : ValidDnsTransition Sent s -> Void
sentIsTerminal _ impossible

||| Cannot skip from Idle directly to ResponseBuilding.
public export
cannotSkipToBuilding : ValidDnsTransition Idle ResponseBuilding -> Void
cannotSkipToBuilding _ impossible

||| Cannot go backwards from ResponseBuilding to Idle.
public export
cannotGoBackToIdle : ValidDnsTransition ResponseBuilding Idle -> Void
cannotGoBackToIdle _ impossible

||| Cannot go backwards from Lookup to QueryReceived.
public export
cannotGoBackToReceived : ValidDnsTransition Lookup QueryReceived -> Void
cannotGoBackToReceived _ impossible

||| Cannot add records when in Idle state.
public export
cannotAddFromIdle : CanAddRecord Idle -> Void
cannotAddFromIdle _ impossible

||| Cannot sign without a loaded key (Disabled state).
public export
cannotSignDisabled : CanSign DnssecDisabled -> Void
cannotSignDisabled _ impossible

||| Cannot sign without a loaded key (Enabled-only state).
public export
cannotSignEnabled : CanSign DnssecEnabled -> Void
cannotSignEnabled _ impossible

||| Cannot revert DNSSEC from Validated back to Disabled.
public export
cannotRevertDnssec : ValidDnssecTransition DnssecValidated DnssecDisabled -> Void
cannotRevertDnssec _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a DNS lifecycle state transition is valid.
public export
validateDnsTransition : (from : DnsState) -> (to : DnsState)
                     -> Maybe (ValidDnsTransition from to)
validateDnsTransition Idle             QueryReceived    = Just ReceiveQuery
validateDnsTransition QueryReceived    Lookup           = Just BeginLookup
validateDnsTransition Lookup           ResponseBuilding = Just BuildResponse
validateDnsTransition ResponseBuilding Sent             = Just SendResponse
validateDnsTransition Idle             Sent             = Just AbortIdle
validateDnsTransition QueryReceived    Sent             = Just AbortReceived
validateDnsTransition Lookup           Sent             = Just AbortLookup
validateDnsTransition _                _                = Nothing

||| Check whether a DNSSEC state transition is valid.
public export
validateDnssecTransition : (from : DnssecState) -> (to : DnssecState)
                        -> Maybe (ValidDnssecTransition from to)
validateDnssecTransition DnssecDisabled  DnssecEnabled   = Just EnableDnssec
validateDnssecTransition DnssecEnabled   DnssecKeyLoaded = Just LoadKey
validateDnssecTransition DnssecKeyLoaded DnssecValidated = Just ValidateSig
validateDnssecTransition _               _               = Nothing
