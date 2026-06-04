-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ZeroTrustABI.Layout: C-ABI-compatible numeric representations of Zero Trust types.
--
-- Maps every constructor of the core Zero Trust sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/zerotrust.h) and the
-- Zig FFI enums (ffi/zig/src/zerotrust.zig) exactly.
--
-- Types covered:
--   PolicyType           (4 constructors, tags 0-3)
--   IdentityConfidence   (5 constructors, tags 0-4)
--   DeviceTrustScore     (5 constructors, tags 0-4)
--   AccessDecision       (4 constructors, tags 0-3)
--   ContextSignalKind    (5 constructors, tags 0-4)
--   AuthFactor           (6 constructors, tags 0-5)
--   TrustLevel           (5 constructors, tags 0-4)
--   PolicyDecision       (5 constructors, tags 0-4)
--   SessionState         (5 constructors, tags 0-4)
--   EvaluationPhase      (6 constructors, tags 0-5)

module ZeroTrustABI.Layout

import ZeroTrust.Types

%default total

---------------------------------------------------------------------------
-- PolicyType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| Zero Trust policy enforcement strategies.
||| These determine how access requests are evaluated at the policy engine level.
public export
data PolicyType : Type where
  ||| Always verify identity and device posture on every request.
  AlwaysVerify    : PolicyType
  ||| Never trust any entity regardless of network location.
  NeverTrust      : PolicyType
  ||| Grant minimum necessary privileges for the requested action.
  LeastPrivilege  : PolicyType
  ||| Enforce micro-perimeter boundaries between network segments.
  MicroSegmentation : PolicyType

public export
Eq PolicyType where
  AlwaysVerify    == AlwaysVerify    = True
  NeverTrust      == NeverTrust      = True
  LeastPrivilege  == LeastPrivilege  = True
  MicroSegmentation == MicroSegmentation = True
  _               == _               = False

public export
Show PolicyType where
  show AlwaysVerify    = "AlwaysVerify"
  show NeverTrust      = "NeverTrust"
  show LeastPrivilege  = "LeastPrivilege"
  show MicroSegmentation = "MicroSegmentation"

public export
policyTypeSize : Nat
policyTypeSize = 1

public export
policyTypeToTag : PolicyType -> Bits8
policyTypeToTag AlwaysVerify      = 0
policyTypeToTag NeverTrust        = 1
policyTypeToTag LeastPrivilege    = 2
policyTypeToTag MicroSegmentation = 3

public export
tagToPolicyType : Bits8 -> Maybe PolicyType
tagToPolicyType 0 = Just AlwaysVerify
tagToPolicyType 1 = Just NeverTrust
tagToPolicyType 2 = Just LeastPrivilege
tagToPolicyType 3 = Just MicroSegmentation
tagToPolicyType _ = Nothing

public export
policyTypeRoundtrip : (p : PolicyType) -> tagToPolicyType (policyTypeToTag p) = Just p
policyTypeRoundtrip AlwaysVerify      = Refl
policyTypeRoundtrip NeverTrust        = Refl
policyTypeRoundtrip LeastPrivilege    = Refl
policyTypeRoundtrip MicroSegmentation = Refl

---------------------------------------------------------------------------
-- IdentityConfidence (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| Confidence level in the verified identity of the requesting entity.
||| Higher confidence requires stronger or more recent authentication factors.
public export
data IdentityConfidence : Type where
  ||| No identity verification performed.
  Unverified : IdentityConfidence
  ||| Basic single-factor authentication (e.g., password only).
  BasicAuth  : IdentityConfidence
  ||| Multi-factor authentication completed.
  MFAVerified : IdentityConfidence
  ||| Strong authentication with hardware token or biometric.
  StrongAuth : IdentityConfidence
  ||| Continuous authentication with real-time behavioural analysis.
  ContinuousAuth : IdentityConfidence

public export
Eq IdentityConfidence where
  Unverified     == Unverified     = True
  BasicAuth      == BasicAuth      = True
  MFAVerified    == MFAVerified    = True
  StrongAuth     == StrongAuth     = True
  ContinuousAuth == ContinuousAuth = True
  _              == _              = False

public export
Show IdentityConfidence where
  show Unverified     = "Unverified"
  show BasicAuth      = "BasicAuth"
  show MFAVerified    = "MFAVerified"
  show StrongAuth     = "StrongAuth"
  show ContinuousAuth = "ContinuousAuth"

public export
identityConfidenceSize : Nat
identityConfidenceSize = 1

public export
identityConfidenceToTag : IdentityConfidence -> Bits8
identityConfidenceToTag Unverified     = 0
identityConfidenceToTag BasicAuth      = 1
identityConfidenceToTag MFAVerified    = 2
identityConfidenceToTag StrongAuth     = 3
identityConfidenceToTag ContinuousAuth = 4

public export
tagToIdentityConfidence : Bits8 -> Maybe IdentityConfidence
tagToIdentityConfidence 0 = Just Unverified
tagToIdentityConfidence 1 = Just BasicAuth
tagToIdentityConfidence 2 = Just MFAVerified
tagToIdentityConfidence 3 = Just StrongAuth
tagToIdentityConfidence 4 = Just ContinuousAuth
tagToIdentityConfidence _ = Nothing

public export
identityConfidenceRoundtrip : (c : IdentityConfidence) -> tagToIdentityConfidence (identityConfidenceToTag c) = Just c
identityConfidenceRoundtrip Unverified     = Refl
identityConfidenceRoundtrip BasicAuth      = Refl
identityConfidenceRoundtrip MFAVerified    = Refl
identityConfidenceRoundtrip StrongAuth     = Refl
identityConfidenceRoundtrip ContinuousAuth = Refl

---------------------------------------------------------------------------
-- DeviceTrustScore (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| Trust assessment of the device from which a request originates.
||| Based on device health, patch level, compliance status, and posture.
public export
data DeviceTrustScore : Type where
  ||| Unknown or unmanaged device.
  DeviceUnknown    : DeviceTrustScore
  ||| Device partially meets security requirements.
  DevicePartial    : DeviceTrustScore
  ||| Device meets baseline compliance requirements.
  DeviceCompliant  : DeviceTrustScore
  ||| Device is managed and fully up to date.
  DeviceManaged    : DeviceTrustScore
  ||| Device is hardened with endpoint protection and encryption.
  DeviceHardened   : DeviceTrustScore

public export
Eq DeviceTrustScore where
  DeviceUnknown   == DeviceUnknown   = True
  DevicePartial   == DevicePartial   = True
  DeviceCompliant == DeviceCompliant = True
  DeviceManaged   == DeviceManaged   = True
  DeviceHardened  == DeviceHardened  = True
  _               == _               = False

public export
Show DeviceTrustScore where
  show DeviceUnknown   = "DeviceUnknown"
  show DevicePartial   = "DevicePartial"
  show DeviceCompliant = "DeviceCompliant"
  show DeviceManaged   = "DeviceManaged"
  show DeviceHardened  = "DeviceHardened"

public export
deviceTrustScoreSize : Nat
deviceTrustScoreSize = 1

public export
deviceTrustScoreToTag : DeviceTrustScore -> Bits8
deviceTrustScoreToTag DeviceUnknown   = 0
deviceTrustScoreToTag DevicePartial   = 1
deviceTrustScoreToTag DeviceCompliant = 2
deviceTrustScoreToTag DeviceManaged   = 3
deviceTrustScoreToTag DeviceHardened  = 4

public export
tagToDeviceTrustScore : Bits8 -> Maybe DeviceTrustScore
tagToDeviceTrustScore 0 = Just DeviceUnknown
tagToDeviceTrustScore 1 = Just DevicePartial
tagToDeviceTrustScore 2 = Just DeviceCompliant
tagToDeviceTrustScore 3 = Just DeviceManaged
tagToDeviceTrustScore 4 = Just DeviceHardened
tagToDeviceTrustScore _ = Nothing

public export
deviceTrustScoreRoundtrip : (d : DeviceTrustScore) -> tagToDeviceTrustScore (deviceTrustScoreToTag d) = Just d
deviceTrustScoreRoundtrip DeviceUnknown   = Refl
deviceTrustScoreRoundtrip DevicePartial   = Refl
deviceTrustScoreRoundtrip DeviceCompliant = Refl
deviceTrustScoreRoundtrip DeviceManaged   = Refl
deviceTrustScoreRoundtrip DeviceHardened  = Refl

---------------------------------------------------------------------------
-- AccessDecision (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| Final access control decision from the zero trust policy engine.
||| This is the output of the full evaluation pipeline.
public export
data AccessDecision : Type where
  ||| Access granted with current credentials and context.
  Allow     : AccessDecision
  ||| Access denied; request does not meet policy requirements.
  Deny      : AccessDecision
  ||| Additional authentication challenge required (e.g., CAPTCHA, MFA).
  Challenge : AccessDecision
  ||| Step-up authentication required (stronger factor needed).
  StepUp    : AccessDecision

public export
Eq AccessDecision where
  Allow     == Allow     = True
  Deny      == Deny      = True
  Challenge == Challenge = True
  StepUp    == StepUp    = True
  _         == _         = False

public export
Show AccessDecision where
  show Allow     = "Allow"
  show Deny      = "Deny"
  show Challenge = "Challenge"
  show StepUp    = "StepUp"

public export
accessDecisionSize : Nat
accessDecisionSize = 1

public export
accessDecisionToTag : AccessDecision -> Bits8
accessDecisionToTag Allow     = 0
accessDecisionToTag Deny      = 1
accessDecisionToTag Challenge = 2
accessDecisionToTag StepUp    = 3

public export
tagToAccessDecision : Bits8 -> Maybe AccessDecision
tagToAccessDecision 0 = Just Allow
tagToAccessDecision 1 = Just Deny
tagToAccessDecision 2 = Just Challenge
tagToAccessDecision 3 = Just StepUp
tagToAccessDecision _ = Nothing

public export
accessDecisionRoundtrip : (d : AccessDecision) -> tagToAccessDecision (accessDecisionToTag d) = Just d
accessDecisionRoundtrip Allow     = Refl
accessDecisionRoundtrip Deny      = Refl
accessDecisionRoundtrip Challenge = Refl
accessDecisionRoundtrip StepUp    = Refl

---------------------------------------------------------------------------
-- ContextSignalKind (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| Kinds of environmental context signals used in trust score computation.
||| Each signal contributes a weighted factor to the aggregate trust score.
public export
data ContextSignalKind : Type where
  ||| Geographic location of the request origin.
  LocationSignal  : ContextSignalKind
  ||| Time-of-day and access pattern analysis.
  TimeSignal      : ContextSignalKind
  ||| Device health, posture, and compliance status.
  DeviceSignal    : ContextSignalKind
  ||| User behavioural biometrics and anomaly detection.
  BehaviorSignal  : ContextSignalKind
  ||| Network context: IP reputation, VPN status, segment.
  NetworkSignal   : ContextSignalKind

public export
Eq ContextSignalKind where
  LocationSignal == LocationSignal = True
  TimeSignal     == TimeSignal     = True
  DeviceSignal   == DeviceSignal   = True
  BehaviorSignal == BehaviorSignal = True
  NetworkSignal  == NetworkSignal  = True
  _              == _              = False

public export
Show ContextSignalKind where
  show LocationSignal = "LocationSignal"
  show TimeSignal     = "TimeSignal"
  show DeviceSignal   = "DeviceSignal"
  show BehaviorSignal = "BehaviorSignal"
  show NetworkSignal  = "NetworkSignal"

public export
contextSignalKindSize : Nat
contextSignalKindSize = 1

public export
contextSignalKindToTag : ContextSignalKind -> Bits8
contextSignalKindToTag LocationSignal = 0
contextSignalKindToTag TimeSignal     = 1
contextSignalKindToTag DeviceSignal   = 2
contextSignalKindToTag BehaviorSignal = 3
contextSignalKindToTag NetworkSignal  = 4

public export
tagToContextSignalKind : Bits8 -> Maybe ContextSignalKind
tagToContextSignalKind 0 = Just LocationSignal
tagToContextSignalKind 1 = Just TimeSignal
tagToContextSignalKind 2 = Just DeviceSignal
tagToContextSignalKind 3 = Just BehaviorSignal
tagToContextSignalKind 4 = Just NetworkSignal
tagToContextSignalKind _ = Nothing

public export
contextSignalKindRoundtrip : (s : ContextSignalKind) -> tagToContextSignalKind (contextSignalKindToTag s) = Just s
contextSignalKindRoundtrip LocationSignal = Refl
contextSignalKindRoundtrip TimeSignal     = Refl
contextSignalKindRoundtrip DeviceSignal   = Refl
contextSignalKindRoundtrip BehaviorSignal = Refl
contextSignalKindRoundtrip NetworkSignal  = Refl

---------------------------------------------------------------------------
-- AuthFactor Layout (6 constructors from ZeroTrust.Types, tags 0-5)
---------------------------------------------------------------------------

public export
authFactorSize : Nat
authFactorSize = 1

public export
authFactorToTag : AuthFactor -> Bits8
authFactorToTag Certificate = 0
authFactorToTag Token       = 1
authFactorToTag Biometric   = 2
authFactorToTag FIDO2       = 3
authFactorToTag TOTP        = 4
authFactorToTag Push        = 5

public export
tagToAuthFactor : Bits8 -> Maybe AuthFactor
tagToAuthFactor 0 = Just Certificate
tagToAuthFactor 1 = Just Token
tagToAuthFactor 2 = Just Biometric
tagToAuthFactor 3 = Just FIDO2
tagToAuthFactor 4 = Just TOTP
tagToAuthFactor 5 = Just Push
tagToAuthFactor _ = Nothing

public export
authFactorRoundtrip : (f : AuthFactor) -> tagToAuthFactor (authFactorToTag f) = Just f
authFactorRoundtrip Certificate = Refl
authFactorRoundtrip Token       = Refl
authFactorRoundtrip Biometric   = Refl
authFactorRoundtrip FIDO2       = Refl
authFactorRoundtrip TOTP        = Refl
authFactorRoundtrip Push        = Refl

---------------------------------------------------------------------------
-- TrustLevel Layout (5 constructors from ZeroTrust.Types, tags 0-4)
---------------------------------------------------------------------------

public export
trustLevelSize : Nat
trustLevelSize = 1

public export
trustLevelToTag : TrustLevel -> Bits8
trustLevelToTag None   = 0
trustLevelToTag Low    = 1
trustLevelToTag Medium = 2
trustLevelToTag High   = 3
trustLevelToTag Full   = 4

public export
tagToTrustLevel : Bits8 -> Maybe TrustLevel
tagToTrustLevel 0 = Just None
tagToTrustLevel 1 = Just Low
tagToTrustLevel 2 = Just Medium
tagToTrustLevel 3 = Just High
tagToTrustLevel 4 = Just Full
tagToTrustLevel _ = Nothing

public export
trustLevelRoundtrip : (t : TrustLevel) -> tagToTrustLevel (trustLevelToTag t) = Just t
trustLevelRoundtrip None   = Refl
trustLevelRoundtrip Low    = Refl
trustLevelRoundtrip Medium = Refl
trustLevelRoundtrip High   = Refl
trustLevelRoundtrip Full   = Refl

---------------------------------------------------------------------------
-- PolicyDecision Layout (5 constructors from ZeroTrust.Types, tags 0-4)
---------------------------------------------------------------------------

public export
policyDecisionSize : Nat
policyDecisionSize = 1

public export
policyDecisionToTag : PolicyDecision -> Bits8
policyDecisionToTag Allow      = 0
policyDecisionToTag Deny       = 1
policyDecisionToTag Challenge  = 2
policyDecisionToTag StepUp     = 3
policyDecisionToTag Quarantine = 4

public export
tagToPolicyDecision : Bits8 -> Maybe PolicyDecision
tagToPolicyDecision 0 = Just Allow
tagToPolicyDecision 1 = Just Deny
tagToPolicyDecision 2 = Just Challenge
tagToPolicyDecision 3 = Just StepUp
tagToPolicyDecision 4 = Just Quarantine
tagToPolicyDecision _ = Nothing

public export
policyDecisionRoundtrip : (d : PolicyDecision) -> tagToPolicyDecision (policyDecisionToTag d) = Just d
policyDecisionRoundtrip Allow      = Refl
policyDecisionRoundtrip Deny       = Refl
policyDecisionRoundtrip Challenge  = Refl
policyDecisionRoundtrip StepUp     = Refl
policyDecisionRoundtrip Quarantine = Refl

---------------------------------------------------------------------------
-- SessionState Layout (5 constructors from ZeroTrust.Types, tags 0-4)
---------------------------------------------------------------------------

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag Unauthenticated = 0
sessionStateToTag PartialAuth     = 1
sessionStateToTag Authenticated   = 2
sessionStateToTag Elevated        = 3
sessionStateToTag Locked          = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Unauthenticated
tagToSessionState 1 = Just PartialAuth
tagToSessionState 2 = Just Authenticated
tagToSessionState 3 = Just Elevated
tagToSessionState 4 = Just Locked
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Unauthenticated = Refl
sessionStateRoundtrip PartialAuth     = Refl
sessionStateRoundtrip Authenticated   = Refl
sessionStateRoundtrip Elevated        = Refl
sessionStateRoundtrip Locked          = Refl

---------------------------------------------------------------------------
-- EvaluationPhase (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| Phases of the Zero Trust access evaluation pipeline.
||| An access request progresses through these phases in order.
||| Used as indices in the Transitions.idr GADT.
public export
data EvaluationPhase : Type where
  ||| Initial state: access request received but not yet processed.
  RequestReceived  : EvaluationPhase
  ||| Identity of the requesting entity has been verified.
  IdentityVerified : EvaluationPhase
  ||| Device posture and health have been checked.
  DeviceChecked    : EvaluationPhase
  ||| All policies have been evaluated against current context.
  PolicyEvaluated  : EvaluationPhase
  ||| Access has been granted (terminal success state).
  AccessGranted    : EvaluationPhase
  ||| Access has been denied (terminal failure state).
  AccessDenied     : EvaluationPhase

public export
Eq EvaluationPhase where
  RequestReceived  == RequestReceived  = True
  IdentityVerified == IdentityVerified = True
  DeviceChecked    == DeviceChecked    = True
  PolicyEvaluated  == PolicyEvaluated  = True
  AccessGranted    == AccessGranted    = True
  AccessDenied     == AccessDenied     = True
  _                == _                = False

public export
Show EvaluationPhase where
  show RequestReceived  = "RequestReceived"
  show IdentityVerified = "IdentityVerified"
  show DeviceChecked    = "DeviceChecked"
  show PolicyEvaluated  = "PolicyEvaluated"
  show AccessGranted    = "AccessGranted"
  show AccessDenied     = "AccessDenied"

public export
evaluationPhaseSize : Nat
evaluationPhaseSize = 1

public export
evaluationPhaseToTag : EvaluationPhase -> Bits8
evaluationPhaseToTag RequestReceived  = 0
evaluationPhaseToTag IdentityVerified = 1
evaluationPhaseToTag DeviceChecked    = 2
evaluationPhaseToTag PolicyEvaluated  = 3
evaluationPhaseToTag AccessGranted    = 4
evaluationPhaseToTag AccessDenied     = 5

public export
tagToEvaluationPhase : Bits8 -> Maybe EvaluationPhase
tagToEvaluationPhase 0 = Just RequestReceived
tagToEvaluationPhase 1 = Just IdentityVerified
tagToEvaluationPhase 2 = Just DeviceChecked
tagToEvaluationPhase 3 = Just PolicyEvaluated
tagToEvaluationPhase 4 = Just AccessGranted
tagToEvaluationPhase 5 = Just AccessDenied
tagToEvaluationPhase _ = Nothing

public export
evaluationPhaseRoundtrip : (p : EvaluationPhase) -> tagToEvaluationPhase (evaluationPhaseToTag p) = Just p
evaluationPhaseRoundtrip RequestReceived  = Refl
evaluationPhaseRoundtrip IdentityVerified = Refl
evaluationPhaseRoundtrip DeviceChecked    = Refl
evaluationPhaseRoundtrip PolicyEvaluated  = Refl
evaluationPhaseRoundtrip AccessGranted    = Refl
evaluationPhaseRoundtrip AccessDenied     = Refl
