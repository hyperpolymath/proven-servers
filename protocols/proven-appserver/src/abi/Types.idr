-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AppserverABI.Types: C-ABI-compatible numeric representations of Appserver types.
--
-- Maps every constructor of the core Appserver sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/appserver.h) and the
-- Zig FFI enums (ffi/zig/src/appserver.zig) exactly.
--
-- Types covered:
--   RequestType    (4 constructors, tags 0-3)
--   LifecycleState (6 constructors, tags 0-5)
--   HealthCheck    (3 constructors, tags 0-2)
--   DeployStrategy (4 constructors, tags 0-3)
--   ErrorCategory  (5 constructors, tags 0-4)

module AppserverABI.Types

import Appserver.Types

%default total

---------------------------------------------------------------------------
-- RequestType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
requestTypeSize : Nat
requestTypeSize = 1

||| Encode a RequestType to its ABI tag value.
public export
requestTypeToTag : RequestType -> Bits8
requestTypeToTag HTTP      = 0
requestTypeToTag WebSocket = 1
requestTypeToTag GRPC      = 2
requestTypeToTag GraphQL   = 3

||| Decode an ABI tag to a RequestType.
public export
tagToRequestType : Bits8 -> Maybe RequestType
tagToRequestType 0 = Just HTTP
tagToRequestType 1 = Just WebSocket
tagToRequestType 2 = Just GRPC
tagToRequestType 3 = Just GraphQL
tagToRequestType _ = Nothing

||| Roundtrip proof: decoding an encoded RequestType yields the original.
public export
requestTypeRoundtrip : (r : RequestType) -> tagToRequestType (requestTypeToTag r) = Just r
requestTypeRoundtrip HTTP      = Refl
requestTypeRoundtrip WebSocket = Refl
requestTypeRoundtrip GRPC      = Refl
requestTypeRoundtrip GraphQL   = Refl

---------------------------------------------------------------------------
-- LifecycleState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
lifecycleStateSize : Nat
lifecycleStateSize = 1

||| Encode a LifecycleState to its ABI tag value.
public export
lifecycleStateToTag : LifecycleState -> Bits8
lifecycleStateToTag Initializing = 0
lifecycleStateToTag Starting     = 1
lifecycleStateToTag Running      = 2
lifecycleStateToTag Draining     = 3
lifecycleStateToTag Stopping     = 4
lifecycleStateToTag Stopped      = 5

||| Decode an ABI tag to a LifecycleState.
public export
tagToLifecycleState : Bits8 -> Maybe LifecycleState
tagToLifecycleState 0 = Just Initializing
tagToLifecycleState 1 = Just Starting
tagToLifecycleState 2 = Just Running
tagToLifecycleState 3 = Just Draining
tagToLifecycleState 4 = Just Stopping
tagToLifecycleState 5 = Just Stopped
tagToLifecycleState _ = Nothing

||| Roundtrip proof: decoding an encoded LifecycleState yields the original.
public export
lifecycleStateRoundtrip : (s : LifecycleState) -> tagToLifecycleState (lifecycleStateToTag s) = Just s
lifecycleStateRoundtrip Initializing = Refl
lifecycleStateRoundtrip Starting     = Refl
lifecycleStateRoundtrip Running      = Refl
lifecycleStateRoundtrip Draining     = Refl
lifecycleStateRoundtrip Stopping     = Refl
lifecycleStateRoundtrip Stopped      = Refl

---------------------------------------------------------------------------
-- HealthCheck (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
healthCheckSize : Nat
healthCheckSize = 1

||| Encode a HealthCheck to its ABI tag value.
public export
healthCheckToTag : HealthCheck -> Bits8
healthCheckToTag Liveness  = 0
healthCheckToTag Readiness = 1
healthCheckToTag Startup   = 2

||| Decode an ABI tag to a HealthCheck.
public export
tagToHealthCheck : Bits8 -> Maybe HealthCheck
tagToHealthCheck 0 = Just Liveness
tagToHealthCheck 1 = Just Readiness
tagToHealthCheck 2 = Just Startup
tagToHealthCheck _ = Nothing

||| Roundtrip proof: decoding an encoded HealthCheck yields the original.
public export
healthCheckRoundtrip : (h : HealthCheck) -> tagToHealthCheck (healthCheckToTag h) = Just h
healthCheckRoundtrip Liveness  = Refl
healthCheckRoundtrip Readiness = Refl
healthCheckRoundtrip Startup   = Refl

---------------------------------------------------------------------------
-- DeployStrategy (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
deployStrategySize : Nat
deployStrategySize = 1

||| Encode a DeployStrategy to its ABI tag value.
public export
deployStrategyToTag : DeployStrategy -> Bits8
deployStrategyToTag RollingUpdate = 0
deployStrategyToTag BlueGreen     = 1
deployStrategyToTag Canary        = 2
deployStrategyToTag Recreate      = 3

||| Decode an ABI tag to a DeployStrategy.
public export
tagToDeployStrategy : Bits8 -> Maybe DeployStrategy
tagToDeployStrategy 0 = Just RollingUpdate
tagToDeployStrategy 1 = Just BlueGreen
tagToDeployStrategy 2 = Just Canary
tagToDeployStrategy 3 = Just Recreate
tagToDeployStrategy _ = Nothing

||| Roundtrip proof: decoding an encoded DeployStrategy yields the original.
public export
deployStrategyRoundtrip : (d : DeployStrategy) -> tagToDeployStrategy (deployStrategyToTag d) = Just d
deployStrategyRoundtrip RollingUpdate = Refl
deployStrategyRoundtrip BlueGreen     = Refl
deployStrategyRoundtrip Canary        = Refl
deployStrategyRoundtrip Recreate      = Refl

---------------------------------------------------------------------------
-- ErrorCategory (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
errorCategorySize : Nat
errorCategorySize = 1

||| Encode an ErrorCategory to its ABI tag value.
public export
errorCategoryToTag : ErrorCategory -> Bits8
errorCategoryToTag ClientError = 0
errorCategoryToTag ServerError = 1
errorCategoryToTag Timeout     = 2
errorCategoryToTag CircuitOpen = 3
errorCategoryToTag RateLimited = 4

||| Decode an ABI tag to an ErrorCategory.
public export
tagToErrorCategory : Bits8 -> Maybe ErrorCategory
tagToErrorCategory 0 = Just ClientError
tagToErrorCategory 1 = Just ServerError
tagToErrorCategory 2 = Just Timeout
tagToErrorCategory 3 = Just CircuitOpen
tagToErrorCategory 4 = Just RateLimited
tagToErrorCategory _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorCategory yields the original.
public export
errorCategoryRoundtrip : (e : ErrorCategory) -> tagToErrorCategory (errorCategoryToTag e) = Just e
errorCategoryRoundtrip ClientError = Refl
errorCategoryRoundtrip ServerError = Refl
errorCategoryRoundtrip Timeout     = Refl
errorCategoryRoundtrip CircuitOpen = Refl
errorCategoryRoundtrip RateLimited = Refl
