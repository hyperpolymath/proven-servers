-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphQLABI.Transitions: Valid GraphQL request lifecycle transitions.
--
-- Models two state machines:
--
-- 1. Request lifecycle (RFC-style for query/mutation):
--    Parse --> Validate --> Execute --> Resolve --> Serialize
--    With abort edges from any non-terminal state to Failed.
--
-- 2. Subscription lifecycle:
--    Subscribe --> Active --> Unsubscribe
--    With abort edges from Subscribe/Active to Failed.
--
-- Key invariants:
--   - Serialize and Unsubscribe are terminal (no outbound edges)
--   - Failed is terminal (no outbound edges)
--   - States cannot be skipped; the pipeline must proceed in order
--   - Active -> Active is valid (receiving successive events)

module GraphQLABI.Transitions

import GraphQL.Types

%default total

---------------------------------------------------------------------------
-- Request Phase: the stages of a GraphQL query/mutation pipeline.
---------------------------------------------------------------------------

||| Phases of the GraphQL request lifecycle pipeline.
public export
data RequestPhase : Type where
  Parse     : RequestPhase
  Validate  : RequestPhase
  Execute   : RequestPhase
  Resolve   : RequestPhase
  Serialize : RequestPhase
  Failed    : RequestPhase

public export
Show RequestPhase where
  show Parse     = "PARSE"
  show Validate  = "VALIDATE"
  show Execute   = "EXECUTE"
  show Resolve   = "RESOLVE"
  show Serialize = "SERIALIZE"
  show Failed    = "FAILED"

---------------------------------------------------------------------------
-- Request phase tag encoding (for FFI)
---------------------------------------------------------------------------

public export
requestPhaseToTag : RequestPhase -> Bits8
requestPhaseToTag Parse     = 0
requestPhaseToTag Validate  = 1
requestPhaseToTag Execute   = 2
requestPhaseToTag Resolve   = 3
requestPhaseToTag Serialize = 4
requestPhaseToTag Failed    = 5

public export
tagToRequestPhase : Bits8 -> Maybe RequestPhase
tagToRequestPhase 0 = Just Parse
tagToRequestPhase 1 = Just Validate
tagToRequestPhase 2 = Just Execute
tagToRequestPhase 3 = Just Resolve
tagToRequestPhase 4 = Just Serialize
tagToRequestPhase 5 = Just Failed
tagToRequestPhase _ = Nothing

public export
requestPhaseRoundtrip : (p : RequestPhase) -> tagToRequestPhase (requestPhaseToTag p) = Just p
requestPhaseRoundtrip Parse     = Refl
requestPhaseRoundtrip Validate  = Refl
requestPhaseRoundtrip Execute   = Refl
requestPhaseRoundtrip Resolve   = Refl
requestPhaseRoundtrip Serialize = Refl
requestPhaseRoundtrip Failed    = Refl

---------------------------------------------------------------------------
-- ValidRequestTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a request lifecycle transition is valid.
public export
data ValidRequestTransition : RequestPhase -> RequestPhase -> Type where
  ||| Parse -> Validate (query text parsed successfully).
  ParseToValidate     : ValidRequestTransition Parse Validate
  ||| Validate -> Execute (schema validation passed).
  ValidateToExecute   : ValidRequestTransition Validate Execute
  ||| Execute -> Resolve (execution plan created, begin resolving fields).
  ExecuteToResolve    : ValidRequestTransition Execute Resolve
  ||| Resolve -> Serialize (all fields resolved, produce response).
  ResolveToSerialize  : ValidRequestTransition Resolve Serialize
  ||| Parse -> Failed (syntax error in query).
  AbortParse          : ValidRequestTransition Parse Failed
  ||| Validate -> Failed (schema validation failed).
  AbortValidate       : ValidRequestTransition Validate Failed
  ||| Execute -> Failed (execution error, e.g. auth check).
  AbortExecute        : ValidRequestTransition Execute Failed
  ||| Resolve -> Failed (field resolver error).
  AbortResolve        : ValidRequestTransition Resolve Failed

---------------------------------------------------------------------------
-- Subscription Phase
---------------------------------------------------------------------------

||| Phases of the GraphQL subscription lifecycle.
public export
data SubscriptionPhase : Type where
  Subscribe   : SubscriptionPhase
  Active      : SubscriptionPhase
  Unsubscribe : SubscriptionPhase
  SubFailed   : SubscriptionPhase

public export
Show SubscriptionPhase where
  show Subscribe   = "SUBSCRIBE"
  show Active      = "ACTIVE"
  show Unsubscribe = "UNSUBSCRIBE"
  show SubFailed   = "SUB_FAILED"

---------------------------------------------------------------------------
-- Subscription phase tag encoding (for FFI)
---------------------------------------------------------------------------

public export
subscriptionPhaseToTag : SubscriptionPhase -> Bits8
subscriptionPhaseToTag Subscribe   = 0
subscriptionPhaseToTag Active      = 1
subscriptionPhaseToTag Unsubscribe = 2
subscriptionPhaseToTag SubFailed   = 3

public export
tagToSubscriptionPhase : Bits8 -> Maybe SubscriptionPhase
tagToSubscriptionPhase 0 = Just Subscribe
tagToSubscriptionPhase 1 = Just Active
tagToSubscriptionPhase 2 = Just Unsubscribe
tagToSubscriptionPhase 3 = Just SubFailed
tagToSubscriptionPhase _ = Nothing

public export
subscriptionPhaseRoundtrip : (p : SubscriptionPhase)
                           -> tagToSubscriptionPhase (subscriptionPhaseToTag p) = Just p
subscriptionPhaseRoundtrip Subscribe   = Refl
subscriptionPhaseRoundtrip Active      = Refl
subscriptionPhaseRoundtrip Unsubscribe = Refl
subscriptionPhaseRoundtrip SubFailed   = Refl

---------------------------------------------------------------------------
-- ValidSubscriptionTransition: legal subscription lifecycle transitions.
---------------------------------------------------------------------------

||| Proof witness that a subscription lifecycle transition is valid.
public export
data ValidSubscriptionTransition : SubscriptionPhase -> SubscriptionPhase -> Type where
  ||| Subscribe -> Active (subscription established, events flowing).
  SubscribeToActive     : ValidSubscriptionTransition Subscribe Active
  ||| Active -> Active (successive event received).
  ActiveEvent           : ValidSubscriptionTransition Active Active
  ||| Active -> Unsubscribe (client or server terminates subscription).
  ActiveToUnsubscribe   : ValidSubscriptionTransition Active Unsubscribe
  ||| Subscribe -> SubFailed (subscription setup failed).
  AbortSubscribe        : ValidSubscriptionTransition Subscribe SubFailed
  ||| Active -> SubFailed (event stream error).
  AbortActive           : ValidSubscriptionTransition Active SubFailed

---------------------------------------------------------------------------
-- Capability witnesses (request lifecycle)
---------------------------------------------------------------------------

||| Proof that a request is in a phase where field resolution can occur.
public export
data CanResolveFields : RequestPhase -> Type where
  ResolveCanResolve : CanResolveFields Resolve

||| Proof that a request is in a phase where serialization can occur.
public export
data CanSerialize : RequestPhase -> Type where
  SerializeCanSerialize : CanSerialize Serialize

---------------------------------------------------------------------------
-- Capability witnesses (subscription lifecycle)
---------------------------------------------------------------------------

||| Proof that a subscription is receiving events.
public export
data CanReceiveEvents : SubscriptionPhase -> Type where
  ActiveCanReceive : CanReceiveEvents Active

---------------------------------------------------------------------------
-- Impossibility proofs (request lifecycle)
---------------------------------------------------------------------------

||| Cannot leave Serialize — it is terminal.
public export
serializeIsTerminal : ValidRequestTransition Serialize s -> Void
serializeIsTerminal _ impossible

||| Cannot leave Failed — it is terminal.
public export
failedIsTerminal : ValidRequestTransition Failed s -> Void
failedIsTerminal _ impossible

||| Cannot skip from Parse directly to Resolve.
public export
cannotSkipToResolve : ValidRequestTransition Parse Resolve -> Void
cannotSkipToResolve _ impossible

||| Cannot skip from Parse directly to Serialize.
public export
cannotSkipToSerialize : ValidRequestTransition Parse Serialize -> Void
cannotSkipToSerialize _ impossible

||| Cannot go backwards from Resolve to Parse.
public export
cannotGoBackwardsResolveParse : ValidRequestTransition Resolve Parse -> Void
cannotGoBackwardsResolveParse _ impossible

||| Cannot resolve fields before execution begins.
public export
cannotResolveFromParse : CanResolveFields Parse -> Void
cannotResolveFromParse _ impossible

||| Cannot serialize from the Validate phase.
public export
cannotSerializeFromValidate : CanSerialize Validate -> Void
cannotSerializeFromValidate _ impossible

---------------------------------------------------------------------------
-- Impossibility proofs (subscription lifecycle)
---------------------------------------------------------------------------

||| Cannot leave Unsubscribe — it is terminal.
public export
unsubscribeIsTerminal : ValidSubscriptionTransition Unsubscribe s -> Void
unsubscribeIsTerminal _ impossible

||| Cannot leave SubFailed — it is terminal.
public export
subFailedIsTerminal : ValidSubscriptionTransition SubFailed s -> Void
subFailedIsTerminal _ impossible

||| Cannot skip from Subscribe directly to Unsubscribe.
public export
cannotSkipToUnsubscribe : ValidSubscriptionTransition Subscribe Unsubscribe -> Void
cannotSkipToUnsubscribe _ impossible

||| Cannot receive events before subscription is active.
public export
cannotReceiveBeforeActive : CanReceiveEvents Subscribe -> Void
cannotReceiveBeforeActive _ impossible

---------------------------------------------------------------------------
-- Transition validation (request)
---------------------------------------------------------------------------

||| Check whether a request lifecycle transition is valid.
public export
validateRequestTransition : (from : RequestPhase) -> (to : RequestPhase)
                          -> Maybe (ValidRequestTransition from to)
validateRequestTransition Parse    Validate  = Just ParseToValidate
validateRequestTransition Validate Execute   = Just ValidateToExecute
validateRequestTransition Execute  Resolve   = Just ExecuteToResolve
validateRequestTransition Resolve  Serialize = Just ResolveToSerialize
validateRequestTransition Parse    Failed    = Just AbortParse
validateRequestTransition Validate Failed    = Just AbortValidate
validateRequestTransition Execute  Failed    = Just AbortExecute
validateRequestTransition Resolve  Failed    = Just AbortResolve
validateRequestTransition _ _                = Nothing

---------------------------------------------------------------------------
-- Transition validation (subscription)
---------------------------------------------------------------------------

||| Check whether a subscription lifecycle transition is valid.
public export
validateSubscriptionTransition : (from : SubscriptionPhase) -> (to : SubscriptionPhase)
                               -> Maybe (ValidSubscriptionTransition from to)
validateSubscriptionTransition Subscribe Active      = Just SubscribeToActive
validateSubscriptionTransition Active    Active      = Just ActiveEvent
validateSubscriptionTransition Active    Unsubscribe = Just ActiveToUnsubscribe
validateSubscriptionTransition Subscribe SubFailed   = Just AbortSubscribe
validateSubscriptionTransition Active    SubFailed   = Just AbortActive
validateSubscriptionTransition _ _                   = Nothing
