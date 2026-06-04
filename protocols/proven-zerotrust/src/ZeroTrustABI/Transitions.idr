-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ZeroTrustABI.Transitions: Valid Zero Trust access evaluation state transitions.
--
-- Access evaluation pipeline (6 phases):
--
--   RequestReceived --> IdentityVerified --> DeviceChecked --> PolicyEvaluated
--                                                                  |
--                                                          +-------+-------+
--                                                          v               v
--                                                    AccessGranted   AccessDenied
--
-- With early-denial edges:
--   RequestReceived  --IdentityFailed--> AccessDenied
--   IdentityVerified --DeviceFailed-->   AccessDenied
--   DeviceChecked    --PolicyDenied-->   AccessDenied
--
-- Key invariant: AccessGranted and AccessDenied are terminal states.
-- Key invariant: Cannot skip phases (must verify identity before checking device).
-- Key invariant: Every non-terminal phase can reach AccessDenied.

module ZeroTrustABI.Transitions

import ZeroTrustABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidEvaluationTransition: exhaustive enumeration of legal phase transitions.
---------------------------------------------------------------------------

||| Proof witness that an access evaluation phase transition is valid.
public export
data ValidEvaluationTransition : EvaluationPhase -> EvaluationPhase -> Type where
  ||| RequestReceived -> IdentityVerified (identity successfully verified).
  VerifyIdentity     : ValidEvaluationTransition RequestReceived IdentityVerified
  ||| IdentityVerified -> DeviceChecked (device posture assessed).
  CheckDevice        : ValidEvaluationTransition IdentityVerified DeviceChecked
  ||| DeviceChecked -> PolicyEvaluated (all policies evaluated).
  EvaluatePolicy     : ValidEvaluationTransition DeviceChecked PolicyEvaluated
  ||| PolicyEvaluated -> AccessGranted (policy permits access).
  GrantAccess        : ValidEvaluationTransition PolicyEvaluated AccessGranted
  ||| PolicyEvaluated -> AccessDenied (policy denies access).
  DenyFromPolicy     : ValidEvaluationTransition PolicyEvaluated AccessDenied
  ||| RequestReceived -> AccessDenied (identity verification failed).
  DenyFromRequest    : ValidEvaluationTransition RequestReceived AccessDenied
  ||| IdentityVerified -> AccessDenied (device check failed).
  DenyFromIdentity   : ValidEvaluationTransition IdentityVerified AccessDenied
  ||| DeviceChecked -> AccessDenied (device posture insufficient).
  DenyFromDevice     : ValidEvaluationTransition DeviceChecked AccessDenied

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that an evaluation phase can advance to device checking.
||| Only IdentityVerified sessions may proceed to device checks.
public export
data CanCheckDevice : EvaluationPhase -> Type where
  IdentityVerifiedCanCheck : CanCheckDevice IdentityVerified

||| Proof that an evaluation phase can advance to policy evaluation.
||| Only DeviceChecked sessions may proceed to policy evaluation.
public export
data CanEvaluatePolicy : EvaluationPhase -> Type where
  DeviceCheckedCanEvaluate : CanEvaluatePolicy DeviceChecked

||| Proof that a phase can yield a final grant decision.
||| Only PolicyEvaluated sessions may be granted access.
public export
data CanGrant : EvaluationPhase -> Type where
  PolicyEvaluatedCanGrant : CanGrant PolicyEvaluated

||| Proof that a phase can yield a denial decision.
||| Any non-terminal phase can be denied.
public export
data CanDeny : EvaluationPhase -> Type where
  RequestCanDeny  : CanDeny RequestReceived
  IdentityCanDeny : CanDeny IdentityVerified
  DeviceCanDeny   : CanDeny DeviceChecked
  PolicyCanDeny   : CanDeny PolicyEvaluated

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot grant access from RequestReceived (must complete full pipeline).
public export
cannotGrantFromRequest : CanGrant RequestReceived -> Void
cannotGrantFromRequest _ impossible

||| Cannot grant access from IdentityVerified (must check device first).
public export
cannotGrantFromIdentity : CanGrant IdentityVerified -> Void
cannotGrantFromIdentity _ impossible

||| Cannot grant access from DeviceChecked (must evaluate policy first).
public export
cannotGrantFromDevice : CanGrant DeviceChecked -> Void
cannotGrantFromDevice _ impossible

||| AccessGranted is terminal: no outbound transitions.
public export
grantedIsTerminal : ValidEvaluationTransition AccessGranted s -> Void
grantedIsTerminal _ impossible

||| AccessDenied is terminal: no outbound transitions.
public export
deniedIsTerminal : ValidEvaluationTransition AccessDenied s -> Void
deniedIsTerminal _ impossible

||| Cannot skip from RequestReceived directly to DeviceChecked.
public export
cannotSkipToDevice : ValidEvaluationTransition RequestReceived DeviceChecked -> Void
cannotSkipToDevice _ impossible

||| Cannot skip from RequestReceived directly to PolicyEvaluated.
public export
cannotSkipToPolicy : ValidEvaluationTransition RequestReceived PolicyEvaluated -> Void
cannotSkipToPolicy _ impossible

||| Cannot skip from RequestReceived directly to AccessGranted.
public export
cannotSkipToGrant : ValidEvaluationTransition RequestReceived AccessGranted -> Void
cannotSkipToGrant _ impossible

||| Cannot skip from IdentityVerified directly to PolicyEvaluated.
public export
cannotSkipDeviceToPolicy : ValidEvaluationTransition IdentityVerified PolicyEvaluated -> Void
cannotSkipDeviceToPolicy _ impossible

||| Cannot skip from IdentityVerified directly to AccessGranted.
public export
cannotSkipDeviceToGrant : ValidEvaluationTransition IdentityVerified AccessGranted -> Void
cannotSkipDeviceToGrant _ impossible

||| Cannot skip from DeviceChecked directly to AccessGranted.
public export
cannotSkipPolicyToGrant : ValidEvaluationTransition DeviceChecked AccessGranted -> Void
cannotSkipPolicyToGrant _ impossible

||| AccessDenied cannot be denied again (already terminal).
public export
cannotDenyFromDenied : CanDeny AccessDenied -> Void
cannotDenyFromDenied _ impossible

||| AccessGranted cannot be denied (already terminal).
public export
cannotDenyFromGranted : CanDeny AccessGranted -> Void
cannotDenyFromGranted _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether an evaluation phase transition is valid.
public export
validateEvaluationTransition : (from : EvaluationPhase) -> (to : EvaluationPhase)
                             -> Maybe (ValidEvaluationTransition from to)
validateEvaluationTransition RequestReceived  IdentityVerified = Just VerifyIdentity
validateEvaluationTransition IdentityVerified DeviceChecked    = Just CheckDevice
validateEvaluationTransition DeviceChecked    PolicyEvaluated  = Just EvaluatePolicy
validateEvaluationTransition PolicyEvaluated  AccessGranted    = Just GrantAccess
validateEvaluationTransition PolicyEvaluated  AccessDenied     = Just DenyFromPolicy
validateEvaluationTransition RequestReceived  AccessDenied     = Just DenyFromRequest
validateEvaluationTransition IdentityVerified AccessDenied     = Just DenyFromIdentity
validateEvaluationTransition DeviceChecked    AccessDenied     = Just DenyFromDevice
validateEvaluationTransition _                _                = Nothing
