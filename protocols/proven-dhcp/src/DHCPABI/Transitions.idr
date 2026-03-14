-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DHCPABI.Transitions: Valid DHCP lifecycle and lease state transitions.
--
-- Models two orthogonal state machines:
--
-- 1. DORA lifecycle (RFC 2131 Section 3.1):
--
--   Idle --> DiscoverReceived --> OfferSent --> RequestReceived --> AckSent
--
--   With error/abort edges:
--     RequestReceived --> NakSent (address conflict)
--     Any non-terminal  --> Idle  (release/timeout)
--
-- 2. Lease lifecycle (RFC 2131 Section 4.4):
--
--   Available --> Offered --> Bound --> Renewing --> Rebinding --> Expired
--                                                                   |
--                                                                   v
--                                                               Available
--   With shortcut edges:
--     Bound --> Available (release)
--     Offered --> Available (decline/timeout)
--
-- The key invariants:
--   - AckSent and NakSent are terminal DORA states.
--   - Expired is terminal (must reclaim to Available explicitly).
--   - Cannot skip DORA steps (no Idle -> AckSent).
--   - Lease cannot go from Available directly to Bound (must be Offered first).
--   - CanAllocate witness requires Available state.
--   - CanAcknowledge witness requires RequestReceived state.

module DHCPABI.Transitions

import DHCPABI.Layout

%default total

---------------------------------------------------------------------------
-- DORA lifecycle states
---------------------------------------------------------------------------

||| The lifecycle state of a DHCP server context processing a single
||| client exchange (one DORA cycle).
public export
data DhcpState : Type where
  ||| Awaiting a DISCOVER — no message has been received yet.
  Idle              : DhcpState
  ||| A DHCPDISCOVER has been received and parsed.
  DiscoverReceived  : DhcpState
  ||| A DHCPOFFER has been sent to the client.
  OfferSent         : DhcpState
  ||| A DHCPREQUEST has been received from the client.
  RequestReceived   : DhcpState
  ||| A DHCPACK has been sent — lease is now active.
  AckSent           : DhcpState
  ||| A DHCPNAK has been sent — request was rejected.
  NakSent           : DhcpState

public export
Eq DhcpState where
  Idle              == Idle              = True
  DiscoverReceived  == DiscoverReceived  = True
  OfferSent         == OfferSent         = True
  RequestReceived   == RequestReceived   = True
  AckSent           == AckSent           = True
  NakSent           == NakSent           = True
  _                 == _                 = False

---------------------------------------------------------------------------
-- ValidDhcpTransition: exhaustive enumeration of legal DORA transitions.
---------------------------------------------------------------------------

||| Proof witness that a DHCP DORA lifecycle transition is valid.
public export
data ValidDhcpTransition : DhcpState -> DhcpState -> Type where
  ||| Idle -> DiscoverReceived (DHCPDISCOVER arrives).
  ReceiveDiscover : ValidDhcpTransition Idle DiscoverReceived
  ||| DiscoverReceived -> OfferSent (server sends DHCPOFFER).
  SendOffer       : ValidDhcpTransition DiscoverReceived OfferSent
  ||| OfferSent -> RequestReceived (DHCPREQUEST arrives).
  ReceiveRequest  : ValidDhcpTransition OfferSent RequestReceived
  ||| RequestReceived -> AckSent (server sends DHCPACK).
  SendAck         : ValidDhcpTransition RequestReceived AckSent
  ||| RequestReceived -> NakSent (server sends DHCPNAK, e.g. address conflict).
  SendNak         : ValidDhcpTransition RequestReceived NakSent
  ||| DiscoverReceived -> Idle (abort: reject malformed DISCOVER).
  AbortDiscover   : ValidDhcpTransition DiscoverReceived Idle
  ||| OfferSent -> Idle (abort: client never responded, offer timeout).
  AbortOffer      : ValidDhcpTransition OfferSent Idle
  ||| RequestReceived -> Idle (abort: processing error).
  AbortRequest    : ValidDhcpTransition RequestReceived Idle

---------------------------------------------------------------------------
-- ValidLeaseTransition: legal lease state changes.
---------------------------------------------------------------------------

||| Proof witness that a DHCP lease state transition is valid.
public export
data ValidLeaseTransition : LeaseState -> LeaseState -> Type where
  ||| Available -> Offered (address selected for a DHCPOFFER).
  AllocateOffer  : ValidLeaseTransition Available Offered
  ||| Offered -> Bound (client accepted, DHCPACK sent).
  BindLease      : ValidLeaseTransition Offered Bound
  ||| Bound -> Renewing (T1 timer expired, client sends unicast REQUEST).
  BeginRenew     : ValidLeaseTransition Bound Renewing
  ||| Renewing -> Bound (server sends ACK, lease renewed).
  RenewSuccess   : ValidLeaseTransition Renewing Bound
  ||| Renewing -> Rebinding (unicast renewal failed, T2 timer expired).
  BeginRebind    : ValidLeaseTransition Renewing Rebinding
  ||| Rebinding -> Bound (broadcast renewal succeeded).
  RebindSuccess  : ValidLeaseTransition Rebinding Bound
  ||| Rebinding -> Expired (rebinding failed, lease time elapsed).
  ExpireLease    : ValidLeaseTransition Rebinding Expired
  ||| Expired -> Available (address reclaimed by server).
  ReclaimAddress : ValidLeaseTransition Expired Available
  ||| Bound -> Available (client sent DHCPRELEASE).
  ReleaseLease   : ValidLeaseTransition Bound Available
  ||| Offered -> Available (client sent DHCPDECLINE or offer timed out).
  DeclineOffer   : ValidLeaseTransition Offered Available

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a lease can be allocated (address is available).
public export
data CanAllocate : LeaseState -> Type where
  AvailableCanAllocate : CanAllocate Available

||| Proof that a DHCP context can send an ACK (request has been received).
public export
data CanAcknowledge : DhcpState -> Type where
  RequestCanAck : CanAcknowledge RequestReceived

||| Proof that a DHCP context can receive a DISCOVER (is idle).
public export
data CanReceiveDiscover : DhcpState -> Type where
  IdleCanReceive : CanReceiveDiscover Idle

||| Proof that a lease can be renewed (is in Bound state).
public export
data CanRenew : LeaseState -> Type where
  BoundCanRenew : CanRenew Bound

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the AckSent state — it is terminal for the DORA cycle.
public export
ackSentIsTerminal : ValidDhcpTransition AckSent s -> Void
ackSentIsTerminal _ impossible

||| Cannot leave the NakSent state — it is terminal for the DORA cycle.
public export
nakSentIsTerminal : ValidDhcpTransition NakSent s -> Void
nakSentIsTerminal _ impossible

||| Cannot skip from Idle directly to AckSent.
public export
cannotSkipToAck : ValidDhcpTransition Idle AckSent -> Void
cannotSkipToAck _ impossible

||| Cannot skip from Idle directly to OfferSent.
public export
cannotSkipToOffer : ValidDhcpTransition Idle OfferSent -> Void
cannotSkipToOffer _ impossible

||| Cannot go from Available directly to Bound (must pass through Offered).
public export
cannotSkipToBound : ValidLeaseTransition Available Bound -> Void
cannotSkipToBound _ impossible

||| Cannot allocate from a Bound lease.
public export
cannotAllocateBound : CanAllocate Bound -> Void
cannotAllocateBound _ impossible

||| Cannot allocate from an Expired lease.
public export
cannotAllocateExpired : CanAllocate Expired -> Void
cannotAllocateExpired _ impossible

||| Cannot acknowledge from Idle.
public export
cannotAckFromIdle : CanAcknowledge Idle -> Void
cannotAckFromIdle _ impossible

||| Cannot renew from Available.
public export
cannotRenewAvailable : CanRenew Available -> Void
cannotRenewAvailable _ impossible

||| Cannot renew from Expired.
public export
cannotRenewExpired : CanRenew Expired -> Void
cannotRenewExpired _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a DHCP DORA lifecycle transition is valid.
public export
validateDhcpTransition : (from : DhcpState) -> (to : DhcpState)
                       -> Maybe (ValidDhcpTransition from to)
validateDhcpTransition Idle             DiscoverReceived = Just ReceiveDiscover
validateDhcpTransition DiscoverReceived OfferSent        = Just SendOffer
validateDhcpTransition OfferSent        RequestReceived  = Just ReceiveRequest
validateDhcpTransition RequestReceived  AckSent          = Just SendAck
validateDhcpTransition RequestReceived  NakSent          = Just SendNak
validateDhcpTransition DiscoverReceived Idle             = Just AbortDiscover
validateDhcpTransition OfferSent        Idle             = Just AbortOffer
validateDhcpTransition RequestReceived  Idle             = Just AbortRequest
validateDhcpTransition _                _                = Nothing

||| Check whether a lease state transition is valid.
public export
validateLeaseTransition : (from : LeaseState) -> (to : LeaseState)
                        -> Maybe (ValidLeaseTransition from to)
validateLeaseTransition Available Offered   = Just AllocateOffer
validateLeaseTransition Offered   Bound     = Just BindLease
validateLeaseTransition Bound     Renewing  = Just BeginRenew
validateLeaseTransition Renewing  Bound     = Just RenewSuccess
validateLeaseTransition Renewing  Rebinding = Just BeginRebind
validateLeaseTransition Rebinding Bound     = Just RebindSuccess
validateLeaseTransition Rebinding Expired   = Just ExpireLease
validateLeaseTransition Expired   Available = Just ReclaimAddress
validateLeaseTransition Bound     Available = Just ReleaseLease
validateLeaseTransition Offered   Available = Just DeclineOffer
validateLeaseTransition _         _         = Nothing
