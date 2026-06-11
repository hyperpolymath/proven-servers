-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- KerberosABI.Transitions: Valid Kerberos authentication lifecycle transitions.
--
-- Authentication lifecycle (5 states, linear with failure edges):
--
--   Initial --> TGTObtained --> ServiceTicketObtained --> Authenticated
--      |             |                   |                    |
--      v             v                   v                    v
--   AuthFailed   AuthFailed          AuthFailed           AuthFailed
--
-- Forward path:
--   Initial -----------(AS exchange)----------> TGTObtained
--   TGTObtained -------(TGS exchange)---------> ServiceTicketObtained
--   ServiceTicketObtained -(AP exchange)-------> Authenticated
--
-- Failure edges:
--   Any non-terminal state ---(error/timeout)---> AuthFailed
--
-- Re-authentication:
--   Authenticated -(ticket expired/revoked)----> Initial
--   AuthFailed ---(retry)---------------------> Initial
--
-- Key invariants:
--   - Cannot skip AS exchange (must get TGT before service ticket)
--   - Cannot skip TGS exchange (must have service ticket before AP)
--   - AuthFailed can only return to Initial (full restart)
--   - Initial is the only entry point for a new authentication

module KerberosABI.Transitions

import KerberosABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidAuthTransition: exhaustive enumeration of legal auth transitions.
---------------------------------------------------------------------------

||| Proof witness that an authentication state transition is valid.
||| Each constructor corresponds to exactly one legal edge in the
||| Kerberos authentication lifecycle graph.
public export
data ValidAuthTransition : AuthState -> AuthState -> Type where
  ||| Initial -> TGTObtained (AS_REQ/AS_REP exchange succeeds).
  ||| Client sends AS_REQ to KDC, receives AS_REP with TGT.
  ObtainTGT           : ValidAuthTransition Initial TGTObtained

  ||| TGTObtained -> ServiceTicketObtained (TGS_REQ/TGS_REP exchange succeeds).
  ||| Client presents TGT to TGS, receives service ticket.
  ObtainServiceTicket  : ValidAuthTransition TGTObtained ServiceTicketObtained

  ||| ServiceTicketObtained -> Authenticated (AP_REQ/AP_REP exchange succeeds).
  ||| Client presents service ticket to application server.
  Authenticate         : ValidAuthTransition ServiceTicketObtained Authenticated

  ||| Initial -> AuthFailed (AS exchange failed: bad password, unknown principal, etc.).
  FailFromInitial      : ValidAuthTransition Initial AuthFailed

  ||| TGTObtained -> AuthFailed (TGS exchange failed: service unknown, clock skew, etc.).
  FailFromTGT          : ValidAuthTransition TGTObtained AuthFailed

  ||| ServiceTicketObtained -> AuthFailed (AP exchange failed: replay, clock skew, etc.).
  FailFromServiceTicket : ValidAuthTransition ServiceTicketObtained AuthFailed

  ||| Authenticated -> AuthFailed (ticket expired or explicitly revoked).
  FailFromAuthenticated : ValidAuthTransition Authenticated AuthFailed

  ||| Authenticated -> Initial (re-authentication: ticket expired, start fresh).
  ReauthFromAuthenticated : ValidAuthTransition Authenticated Initial

  ||| AuthFailed -> Initial (retry authentication from scratch).
  RetryFromFailed      : ValidAuthTransition AuthFailed Initial

  ||| TGTObtained -> TGTObtained (TGT renewal: client renews existing TGT).
  RenewTGT             : ValidAuthTransition TGTObtained TGTObtained

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a client can request a service ticket (TGS exchange).
||| Requires a valid TGT.
public export
data CanRequestServiceTicket : AuthState -> Type where
  TGTCanRequestService : CanRequestServiceTicket TGTObtained

||| Proof that a client can authenticate to a service (AP exchange).
||| Requires a valid service ticket.
public export
data CanAuthenticate : AuthState -> Type where
  ServiceTicketCanAuth : CanAuthenticate ServiceTicketObtained

||| Proof that a client has completed authentication and can access the service.
public export
data HasAccess : AuthState -> Type where
  AuthenticatedHasAccess : HasAccess Authenticated

||| Proof that a client can renew its TGT.
||| Only valid when holding a TGT (before or after service ticket).
public export
data CanRenewTGT : AuthState -> Type where
  TGTCanRenew : CanRenewTGT TGTObtained

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot request a service ticket without a TGT.
public export
initialCannotRequestService : CanRequestServiceTicket Initial -> Void
initialCannotRequestService _ impossible

||| Cannot authenticate to a service without a service ticket.
public export
initialCannotAuthenticate : CanAuthenticate Initial -> Void
initialCannotAuthenticate _ impossible

||| Cannot authenticate from just holding a TGT (must get service ticket first).
public export
tgtCannotAuthenticate : CanAuthenticate TGTObtained -> Void
tgtCannotAuthenticate _ impossible

||| Failed clients cannot request service tickets.
public export
failedCannotRequestService : CanRequestServiceTicket AuthFailed -> Void
failedCannotRequestService _ impossible

||| Failed clients have no access.
public export
failedHasNoAccess : HasAccess AuthFailed -> Void
failedHasNoAccess _ impossible

||| Initial clients have no access.
public export
initialHasNoAccess : HasAccess Initial -> Void
initialHasNoAccess _ impossible

||| Cannot skip AS exchange to go directly to ServiceTicketObtained.
public export
cannotSkipASExchange : ValidAuthTransition Initial ServiceTicketObtained -> Void
cannotSkipASExchange _ impossible

||| Cannot skip TGS exchange to go directly from Initial to Authenticated.
public export
cannotSkipToAuthenticated : ValidAuthTransition Initial Authenticated -> Void
cannotSkipToAuthenticated _ impossible

||| Cannot skip AP exchange to go from TGTObtained directly to Authenticated.
public export
cannotSkipAPExchange : ValidAuthTransition TGTObtained Authenticated -> Void
cannotSkipAPExchange _ impossible

||| AuthFailed cannot transition to TGTObtained (must restart from Initial).
public export
failedCannotObtainTGT : ValidAuthTransition AuthFailed TGTObtained -> Void
failedCannotObtainTGT _ impossible

||| AuthFailed cannot transition to ServiceTicketObtained.
public export
failedCannotObtainService : ValidAuthTransition AuthFailed ServiceTicketObtained -> Void
failedCannotObtainService _ impossible

||| AuthFailed cannot transition to Authenticated.
public export
failedCannotAuthenticate : ValidAuthTransition AuthFailed Authenticated -> Void
failedCannotAuthenticate _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether an authentication state transition is valid.
||| Returns a proof witness if valid, Nothing otherwise.
public export
validateAuthTransition : (from : AuthState) -> (to : AuthState)
                       -> Maybe (ValidAuthTransition from to)
validateAuthTransition Initial               TGTObtained           = Just ObtainTGT
validateAuthTransition TGTObtained           ServiceTicketObtained = Just ObtainServiceTicket
validateAuthTransition ServiceTicketObtained Authenticated         = Just Authenticate
validateAuthTransition Initial               AuthFailed            = Just FailFromInitial
validateAuthTransition TGTObtained           AuthFailed            = Just FailFromTGT
validateAuthTransition ServiceTicketObtained AuthFailed            = Just FailFromServiceTicket
validateAuthTransition Authenticated         AuthFailed            = Just FailFromAuthenticated
validateAuthTransition Authenticated         Initial               = Just ReauthFromAuthenticated
validateAuthTransition AuthFailed            Initial               = Just RetryFromFailed
validateAuthTransition TGTObtained           TGTObtained           = Just RenewTGT
validateAuthTransition _                     _                     = Nothing

---------------------------------------------------------------------------
-- Encryption negotiation transition
-- Models the process of negotiating a mutually-acceptable cipher.
---------------------------------------------------------------------------

||| States in the encryption type negotiation process.
||| The client proposes a list of ciphers; the server selects the strongest.
public export
data NegotiationState : Type where
  ||| No negotiation started.
  NegIdle      : NegotiationState
  ||| Client has proposed encryption types.
  Proposed     : NegotiationState
  ||| Server has selected an encryption type.
  Selected     : NegotiationState
  ||| Negotiation failed (no common cipher).
  NegFailed    : NegotiationState

public export
Eq NegotiationState where
  NegIdle   == NegIdle   = True
  Proposed  == Proposed  = True
  Selected  == Selected  = True
  NegFailed == NegFailed = True
  _         == _         = False

public export
Show NegotiationState where
  show NegIdle   = "NegIdle"
  show Proposed  = "Proposed"
  show Selected  = "Selected"
  show NegFailed = "NegFailed"

||| Size in bytes for the NegotiationState tag.
public export
negotiationStateSize : Nat
negotiationStateSize = 1

||| Encode a NegotiationState to its ABI tag value.
public export
negotiationStateToTag : NegotiationState -> Bits8
negotiationStateToTag NegIdle   = 0
negotiationStateToTag Proposed  = 1
negotiationStateToTag Selected  = 2
negotiationStateToTag NegFailed = 3

||| Decode an ABI tag back to a NegotiationState.
public export
tagToNegotiationState : Bits8 -> Maybe NegotiationState
tagToNegotiationState 0 = Just NegIdle
tagToNegotiationState 1 = Just Proposed
tagToNegotiationState 2 = Just Selected
tagToNegotiationState 3 = Just NegFailed
tagToNegotiationState _ = Nothing

||| Roundtrip proof for NegotiationState.
public export
negotiationStateRoundtrip : (s : NegotiationState) -> tagToNegotiationState (negotiationStateToTag s) = Just s
negotiationStateRoundtrip NegIdle   = Refl
negotiationStateRoundtrip Proposed  = Refl
negotiationStateRoundtrip Selected  = Refl
negotiationStateRoundtrip NegFailed = Refl

||| Valid encryption negotiation transitions.
public export
data ValidNegotiationTransition : NegotiationState -> NegotiationState -> Type where
  ||| Client proposes supported ciphers.
  ProposeEncTypes   : ValidNegotiationTransition NegIdle Proposed
  ||| Server selects a cipher from the proposal.
  SelectEncType     : ValidNegotiationTransition Proposed Selected
  ||| No common cipher found.
  NegotiationFail   : ValidNegotiationTransition Proposed NegFailed

||| Validate a negotiation state transition.
public export
validateNegotiation : (from : NegotiationState) -> (to : NegotiationState)
                    -> Maybe (ValidNegotiationTransition from to)
validateNegotiation NegIdle  Proposed  = Just ProposeEncTypes
validateNegotiation Proposed Selected  = Just SelectEncType
validateNegotiation Proposed NegFailed = Just NegotiationFail
validateNegotiation _        _         = Nothing

||| Cannot skip proposal to go directly to Selected.
public export
cannotSkipProposal : ValidNegotiationTransition NegIdle Selected -> Void
cannotSkipProposal _ impossible

||| Selected is terminal (no outgoing edges).
public export
selectedIsTerminal : ValidNegotiationTransition Selected s -> Void
selectedIsTerminal _ impossible

||| NegFailed is terminal (no outgoing edges).
public export
negFailedIsTerminal : ValidNegotiationTransition NegFailed s -> Void
negFailedIsTerminal _ impossible
