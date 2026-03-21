-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ZerotrustABI.Types: C-ABI-compatible numeric representations of Zerotrust types.
--
-- Maps every constructor of the core Zerotrust sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/zerotrust.zig) exactly.
--
-- Types covered:
--   PolicyType                (4 constructors, tags 0-3)
--   IdentityConfidence        (5 constructors, tags 0-4)
--   DeviceTrustScore          (5 constructors, tags 0-4)
--   AccessDecision            (4 constructors, tags 0-3)
--   ContextSignalKind         (5 constructors, tags 0-4)
--   AuthFactor                (6 constructors, tags 0-5)
--   TrustLevel                (5 constructors, tags 0-4)
--   PolicyDecision            (5 constructors, tags 0-4)
--   SessionState              (5 constructors, tags 0-4)
--   EvaluationPhase           (6 constructors, tags 0-5)

module ZerotrustABI.Types

%default total

---------------------------------------------------------------------------
-- PolicyType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
policy_typeSize : Nat
policy_typeSize = 1

||| PolicyType sum type for ABI encoding.
public export
data PolicyType : Type where
  AlwaysVerify : PolicyType
  NeverTrust : PolicyType
  LeastPrivilege : PolicyType
  MicroSegmentation : PolicyType

||| Encode a PolicyType to its ABI tag value.
public export
policy_typeToTag : PolicyType -> Bits8
policy_typeToTag AlwaysVerify = 0
policy_typeToTag NeverTrust = 1
policy_typeToTag LeastPrivilege = 2
policy_typeToTag MicroSegmentation = 3

||| Decode an ABI tag to a PolicyType.
public export
tagToPolicyType : Bits8 -> Maybe PolicyType
tagToPolicyType 0 = Just AlwaysVerify
tagToPolicyType 1 = Just NeverTrust
tagToPolicyType 2 = Just LeastPrivilege
tagToPolicyType 3 = Just MicroSegmentation
tagToPolicyType _ = Nothing

||| Roundtrip proof: decoding an encoded PolicyType yields the original.
public export
policy_typeRoundtrip : (x : PolicyType) -> tagToPolicyType (policy_typeToTag x) = Just x
policy_typeRoundtrip AlwaysVerify = Refl
policy_typeRoundtrip NeverTrust = Refl
policy_typeRoundtrip LeastPrivilege = Refl
policy_typeRoundtrip MicroSegmentation = Refl

---------------------------------------------------------------------------
-- IdentityConfidence (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
identity_confidenceSize : Nat
identity_confidenceSize = 1

||| IdentityConfidence sum type for ABI encoding.
public export
data IdentityConfidence : Type where
  Unverified : IdentityConfidence
  BasicAuth : IdentityConfidence
  MfaVerified : IdentityConfidence
  StrongAuth : IdentityConfidence
  ContinuousAuth : IdentityConfidence

||| Encode a IdentityConfidence to its ABI tag value.
public export
identity_confidenceToTag : IdentityConfidence -> Bits8
identity_confidenceToTag Unverified = 0
identity_confidenceToTag BasicAuth = 1
identity_confidenceToTag MfaVerified = 2
identity_confidenceToTag StrongAuth = 3
identity_confidenceToTag ContinuousAuth = 4

||| Decode an ABI tag to a IdentityConfidence.
public export
tagToIdentityConfidence : Bits8 -> Maybe IdentityConfidence
tagToIdentityConfidence 0 = Just Unverified
tagToIdentityConfidence 1 = Just BasicAuth
tagToIdentityConfidence 2 = Just MfaVerified
tagToIdentityConfidence 3 = Just StrongAuth
tagToIdentityConfidence 4 = Just ContinuousAuth
tagToIdentityConfidence _ = Nothing

||| Roundtrip proof: decoding an encoded IdentityConfidence yields the original.
public export
identity_confidenceRoundtrip : (x : IdentityConfidence) -> tagToIdentityConfidence (identity_confidenceToTag x) = Just x
identity_confidenceRoundtrip Unverified = Refl
identity_confidenceRoundtrip BasicAuth = Refl
identity_confidenceRoundtrip MfaVerified = Refl
identity_confidenceRoundtrip StrongAuth = Refl
identity_confidenceRoundtrip ContinuousAuth = Refl

---------------------------------------------------------------------------
-- DeviceTrustScore (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
device_trust_scoreSize : Nat
device_trust_scoreSize = 1

||| DeviceTrustScore sum type for ABI encoding.
public export
data DeviceTrustScore : Type where
  DeviceUnknown : DeviceTrustScore
  DevicePartial : DeviceTrustScore
  DeviceCompliant : DeviceTrustScore
  DeviceManaged : DeviceTrustScore
  DeviceHardened : DeviceTrustScore

||| Encode a DeviceTrustScore to its ABI tag value.
public export
device_trust_scoreToTag : DeviceTrustScore -> Bits8
device_trust_scoreToTag DeviceUnknown = 0
device_trust_scoreToTag DevicePartial = 1
device_trust_scoreToTag DeviceCompliant = 2
device_trust_scoreToTag DeviceManaged = 3
device_trust_scoreToTag DeviceHardened = 4

||| Decode an ABI tag to a DeviceTrustScore.
public export
tagToDeviceTrustScore : Bits8 -> Maybe DeviceTrustScore
tagToDeviceTrustScore 0 = Just DeviceUnknown
tagToDeviceTrustScore 1 = Just DevicePartial
tagToDeviceTrustScore 2 = Just DeviceCompliant
tagToDeviceTrustScore 3 = Just DeviceManaged
tagToDeviceTrustScore 4 = Just DeviceHardened
tagToDeviceTrustScore _ = Nothing

||| Roundtrip proof: decoding an encoded DeviceTrustScore yields the original.
public export
device_trust_scoreRoundtrip : (x : DeviceTrustScore) -> tagToDeviceTrustScore (device_trust_scoreToTag x) = Just x
device_trust_scoreRoundtrip DeviceUnknown = Refl
device_trust_scoreRoundtrip DevicePartial = Refl
device_trust_scoreRoundtrip DeviceCompliant = Refl
device_trust_scoreRoundtrip DeviceManaged = Refl
device_trust_scoreRoundtrip DeviceHardened = Refl

---------------------------------------------------------------------------
-- AccessDecision (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
access_decisionSize : Nat
access_decisionSize = 1

||| AccessDecision sum type for ABI encoding.
public export
data AccessDecision : Type where
  Allow : AccessDecision
  Deny : AccessDecision
  Challenge : AccessDecision
  StepUp : AccessDecision

||| Encode a AccessDecision to its ABI tag value.
public export
access_decisionToTag : AccessDecision -> Bits8
access_decisionToTag Allow = 0
access_decisionToTag Deny = 1
access_decisionToTag Challenge = 2
access_decisionToTag StepUp = 3

||| Decode an ABI tag to a AccessDecision.
public export
tagToAccessDecision : Bits8 -> Maybe AccessDecision
tagToAccessDecision 0 = Just Allow
tagToAccessDecision 1 = Just Deny
tagToAccessDecision 2 = Just Challenge
tagToAccessDecision 3 = Just StepUp
tagToAccessDecision _ = Nothing

||| Roundtrip proof: decoding an encoded AccessDecision yields the original.
public export
access_decisionRoundtrip : (x : AccessDecision) -> tagToAccessDecision (access_decisionToTag x) = Just x
access_decisionRoundtrip Allow = Refl
access_decisionRoundtrip Deny = Refl
access_decisionRoundtrip Challenge = Refl
access_decisionRoundtrip StepUp = Refl

---------------------------------------------------------------------------
-- ContextSignalKind (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
context_signal_kindSize : Nat
context_signal_kindSize = 1

||| ContextSignalKind sum type for ABI encoding.
public export
data ContextSignalKind : Type where
  Location : ContextSignalKind
  Time : ContextSignalKind
  Device : ContextSignalKind
  Behavior : ContextSignalKind
  Network : ContextSignalKind

||| Encode a ContextSignalKind to its ABI tag value.
public export
context_signal_kindToTag : ContextSignalKind -> Bits8
context_signal_kindToTag Location = 0
context_signal_kindToTag Time = 1
context_signal_kindToTag Device = 2
context_signal_kindToTag Behavior = 3
context_signal_kindToTag Network = 4

||| Decode an ABI tag to a ContextSignalKind.
public export
tagToContextSignalKind : Bits8 -> Maybe ContextSignalKind
tagToContextSignalKind 0 = Just Location
tagToContextSignalKind 1 = Just Time
tagToContextSignalKind 2 = Just Device
tagToContextSignalKind 3 = Just Behavior
tagToContextSignalKind 4 = Just Network
tagToContextSignalKind _ = Nothing

||| Roundtrip proof: decoding an encoded ContextSignalKind yields the original.
public export
context_signal_kindRoundtrip : (x : ContextSignalKind) -> tagToContextSignalKind (context_signal_kindToTag x) = Just x
context_signal_kindRoundtrip Location = Refl
context_signal_kindRoundtrip Time = Refl
context_signal_kindRoundtrip Device = Refl
context_signal_kindRoundtrip Behavior = Refl
context_signal_kindRoundtrip Network = Refl

---------------------------------------------------------------------------
-- AuthFactor (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
auth_factorSize : Nat
auth_factorSize = 1

||| AuthFactor sum type for ABI encoding.
public export
data AuthFactor : Type where
  Certificate : AuthFactor
  Token : AuthFactor
  Biometric : AuthFactor
  Fido2 : AuthFactor
  Totp : AuthFactor
  Push : AuthFactor

||| Encode a AuthFactor to its ABI tag value.
public export
auth_factorToTag : AuthFactor -> Bits8
auth_factorToTag Certificate = 0
auth_factorToTag Token = 1
auth_factorToTag Biometric = 2
auth_factorToTag Fido2 = 3
auth_factorToTag Totp = 4
auth_factorToTag Push = 5

||| Decode an ABI tag to a AuthFactor.
public export
tagToAuthFactor : Bits8 -> Maybe AuthFactor
tagToAuthFactor 0 = Just Certificate
tagToAuthFactor 1 = Just Token
tagToAuthFactor 2 = Just Biometric
tagToAuthFactor 3 = Just Fido2
tagToAuthFactor 4 = Just Totp
tagToAuthFactor 5 = Just Push
tagToAuthFactor _ = Nothing

||| Roundtrip proof: decoding an encoded AuthFactor yields the original.
public export
auth_factorRoundtrip : (x : AuthFactor) -> tagToAuthFactor (auth_factorToTag x) = Just x
auth_factorRoundtrip Certificate = Refl
auth_factorRoundtrip Token = Refl
auth_factorRoundtrip Biometric = Refl
auth_factorRoundtrip Fido2 = Refl
auth_factorRoundtrip Totp = Refl
auth_factorRoundtrip Push = Refl

---------------------------------------------------------------------------
-- TrustLevel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
trust_levelSize : Nat
trust_levelSize = 1

||| TrustLevel sum type for ABI encoding.
public export
data TrustLevel : Type where
  None : TrustLevel
  Low : TrustLevel
  Medium : TrustLevel
  High : TrustLevel
  Full : TrustLevel

||| Encode a TrustLevel to its ABI tag value.
public export
trust_levelToTag : TrustLevel -> Bits8
trust_levelToTag None = 0
trust_levelToTag Low = 1
trust_levelToTag Medium = 2
trust_levelToTag High = 3
trust_levelToTag Full = 4

||| Decode an ABI tag to a TrustLevel.
public export
tagToTrustLevel : Bits8 -> Maybe TrustLevel
tagToTrustLevel 0 = Just None
tagToTrustLevel 1 = Just Low
tagToTrustLevel 2 = Just Medium
tagToTrustLevel 3 = Just High
tagToTrustLevel 4 = Just Full
tagToTrustLevel _ = Nothing

||| Roundtrip proof: decoding an encoded TrustLevel yields the original.
public export
trust_levelRoundtrip : (x : TrustLevel) -> tagToTrustLevel (trust_levelToTag x) = Just x
trust_levelRoundtrip None = Refl
trust_levelRoundtrip Low = Refl
trust_levelRoundtrip Medium = Refl
trust_levelRoundtrip High = Refl
trust_levelRoundtrip Full = Refl

---------------------------------------------------------------------------
-- PolicyDecision (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
policy_decisionSize : Nat
policy_decisionSize = 1

||| PolicyDecision sum type for ABI encoding.
public export
data PolicyDecision : Type where
  Allow : PolicyDecision
  Deny : PolicyDecision
  Challenge : PolicyDecision
  StepUp : PolicyDecision
  Quarantine : PolicyDecision

||| Encode a PolicyDecision to its ABI tag value.
public export
policy_decisionToTag : PolicyDecision -> Bits8
policy_decisionToTag Allow = 0
policy_decisionToTag Deny = 1
policy_decisionToTag Challenge = 2
policy_decisionToTag StepUp = 3
policy_decisionToTag Quarantine = 4

||| Decode an ABI tag to a PolicyDecision.
public export
tagToPolicyDecision : Bits8 -> Maybe PolicyDecision
tagToPolicyDecision 0 = Just Allow
tagToPolicyDecision 1 = Just Deny
tagToPolicyDecision 2 = Just Challenge
tagToPolicyDecision 3 = Just StepUp
tagToPolicyDecision 4 = Just Quarantine
tagToPolicyDecision _ = Nothing

||| Roundtrip proof: decoding an encoded PolicyDecision yields the original.
public export
policy_decisionRoundtrip : (x : PolicyDecision) -> tagToPolicyDecision (policy_decisionToTag x) = Just x
policy_decisionRoundtrip Allow = Refl
policy_decisionRoundtrip Deny = Refl
policy_decisionRoundtrip Challenge = Refl
policy_decisionRoundtrip StepUp = Refl
policy_decisionRoundtrip Quarantine = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
session_stateSize : Nat
session_stateSize = 1

||| SessionState sum type for ABI encoding.
public export
data SessionState : Type where
  Unauthenticated : SessionState
  PartialAuth : SessionState
  Authenticated : SessionState
  Elevated : SessionState
  Locked : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Unauthenticated = 0
session_stateToTag PartialAuth = 1
session_stateToTag Authenticated = 2
session_stateToTag Elevated = 3
session_stateToTag Locked = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Unauthenticated
tagToSessionState 1 = Just PartialAuth
tagToSessionState 2 = Just Authenticated
tagToSessionState 3 = Just Elevated
tagToSessionState 4 = Just Locked
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Unauthenticated = Refl
session_stateRoundtrip PartialAuth = Refl
session_stateRoundtrip Authenticated = Refl
session_stateRoundtrip Elevated = Refl
session_stateRoundtrip Locked = Refl

---------------------------------------------------------------------------
-- EvaluationPhase (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
evaluation_phaseSize : Nat
evaluation_phaseSize = 1

||| EvaluationPhase sum type for ABI encoding.
public export
data EvaluationPhase : Type where
  RequestReceived : EvaluationPhase
  IdentityVerified : EvaluationPhase
  DeviceChecked : EvaluationPhase
  PolicyEvaluated : EvaluationPhase
  AccessGranted : EvaluationPhase
  AccessDenied : EvaluationPhase

||| Encode a EvaluationPhase to its ABI tag value.
public export
evaluation_phaseToTag : EvaluationPhase -> Bits8
evaluation_phaseToTag RequestReceived = 0
evaluation_phaseToTag IdentityVerified = 1
evaluation_phaseToTag DeviceChecked = 2
evaluation_phaseToTag PolicyEvaluated = 3
evaluation_phaseToTag AccessGranted = 4
evaluation_phaseToTag AccessDenied = 5

||| Decode an ABI tag to a EvaluationPhase.
public export
tagToEvaluationPhase : Bits8 -> Maybe EvaluationPhase
tagToEvaluationPhase 0 = Just RequestReceived
tagToEvaluationPhase 1 = Just IdentityVerified
tagToEvaluationPhase 2 = Just DeviceChecked
tagToEvaluationPhase 3 = Just PolicyEvaluated
tagToEvaluationPhase 4 = Just AccessGranted
tagToEvaluationPhase 5 = Just AccessDenied
tagToEvaluationPhase _ = Nothing

||| Roundtrip proof: decoding an encoded EvaluationPhase yields the original.
public export
evaluation_phaseRoundtrip : (x : EvaluationPhase) -> tagToEvaluationPhase (evaluation_phaseToTag x) = Just x
evaluation_phaseRoundtrip RequestReceived = Refl
evaluation_phaseRoundtrip IdentityVerified = Refl
evaluation_phaseRoundtrip DeviceChecked = Refl
evaluation_phaseRoundtrip PolicyEvaluated = Refl
evaluation_phaseRoundtrip AccessGranted = Refl
evaluation_phaseRoundtrip AccessDenied = Refl
